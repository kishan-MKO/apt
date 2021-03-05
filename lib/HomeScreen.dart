import 'package:finalPart/appointment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'EntryProvider.dart';
import 'MainFunctionality.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'OnClickAppointmentDetails.dart';

const kAccentBlueColor = Color(0xFF261362);
const kPrimaryBlueColor = Color(0xFF616BBE);
const kCalmBlueColor = Color(0xFF95A4B7);
const kAccentPinkColor = Color(0xFFE66A7E);
const kTransparentPinkColor = Color(0x70E66A7E);
const kPaleGreyColor = Color(0xFFF5F6FB);

class HomeScreen extends StatefulWidget {
  @override
  final Appointment entry;
  HomeScreen({this.entry});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterLocalNotificationsPlugin localNotification;

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Center(
            child: Text(
              'MY APPOINTMENT',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.36,
            child: Image(
                image: AssetImage("images/Reminder.jpeg"), fit: BoxFit.cover),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.yellowAccent[300],
            ),
          ),
          ScrollConfiguration(
            behavior: NoGlowBehavior(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5,
              child: StreamBuilder<List<Appointment>>(
                  stream: entryProvider.entries,
                  builder: (context, snapshot) {
                    if (snapshot.data.length == 0) {
                      return Container(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'You have no due appointments !',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.data.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: Container(
                                child: AppointmentCard(
                                  title: snapshot.data[index].appointmentType ==
                                          "Other"
                                      ? "Hospital"
                                      : snapshot.data[index].appointmentType,
                                  icon: myIcon(
                                      snapshot.data[index].appointmentType),
                                  time: snapshot.data[index].time,
                                  doctor: snapshot.data[index].doctorName,
                                  date: snapshot.data[index].date,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(HeroDialogRoute(
                                    builder: (context) => AppointmentDetails(
                                          time: snapshot.data[index].time,
                                          appointmentType: snapshot
                                              .data[index].appointmentType,
                                          date: snapshot.data[index].date,
                                          doctorName:
                                              snapshot.data[index].doctorName,
                                          entry: snapshot.data[index],
                                        )));
                              },
                              onLongPress: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) => AlertDialog(
                                          title: Text(
                                              'Do you want to delete this?'),
                                          actions: [
                                            FlatButton(
                                              child: Text('Yes'),
                                              onPressed: () {
                                                entryProvider.removeEntry(
                                                    snapshot
                                                        .data[index].entryId);
                                                Navigator.pop(context);

                                                removeNotif();
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('No'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                // showNotification();
                                              },
                                            ),
                                          ],
                                        ));
                              },
                            );
                          });
                    }
                  }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => EntryScreen()));
        },
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String doctor;
  final String date;

  AppointmentCard({this.icon, this.doctor, this.title, this.time, this.date});

  @override
  Widget build(BuildContext context) {
    return ReusableCard(
      colour: kPaleGreyColor,
      borderRadius: 20.0,
      childCard: Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Icon(
                icon,
                color: kPrimaryBlueColor,
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleTextStyle(
                    textString: title == null ? '(No title)' : title, //Dentist
                    textColor: kAccentBlueColor,
                    fontSize: 15.0,
                  ),
                  BodyTextStyle(
                    textString: time == null
                        ? '(No time registered)'
                        : 'time: $time', //'15:30 - 16:30'
                  ),
                  BodyTextStyle(
                    textString: date == null
                        ? '(no date)'
                        : 'Date $date', //'15:30 - 16:30'
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    BodyTextStyle(textString: 'Dr. $doctor'),
                    Icon(Icons.medical_services),
                  ]),
                ],
              ),
            ),
            Icon(
              FontAwesomeIcons.angleRight,
              color: kCalmBlueColor,
            ),
          ],
        ),
      ),
    );
  }
}

class TitleTextStyle extends StatelessWidget {
  final String textString;
  final Color textColor;
  final double fontSize;
  TitleTextStyle({this.textColor, this.textString, this.fontSize});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Text(
        textString,
        style: GoogleFonts.roboto(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class BodyTextStyle extends StatelessWidget {
  final String textString;
  final Color textColor;
  final double fontSize;
  BodyTextStyle({this.textColor, this.textString, this.fontSize});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.5),
      child: Text(
        textString,
        style: GoogleFonts.roboto(
          color: textColor,
          //fontWeight: FontWeight.w900,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class ReusableCard extends StatelessWidget {
  final Color colour;
  final Widget childCard;
  final double borderRadius;

  ReusableCard({this.colour, this.childCard, this.borderRadius}); //constructor

  @override
  Widget build(BuildContext context) {
    return Container(
      child: childCard,
      margin: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

IconData myIcon(String aptType) {
  switch (aptType) {
    case "Dentist":
      return FontAwesomeIcons.tooth;
      break;
    case "Clinical":
      return FontAwesomeIcons.clinicMedical;
      break;
    case "Gynecologist":
      return FontAwesomeIcons.vectorSquare;
      break;
    case "Dermatologist":
      return FontAwesomeIcons.smoking;
      break;
    default:
      return FontAwesomeIcons.hospital;
      break;
  }
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class HeroDialogRoute<T> extends PageRoute<T> {
  /// {@macro hero_dialog_route}
  HeroDialogRoute({
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool fullscreenDialog = false,
  })  : _builder = builder,
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.white54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}

Future removeNotif() async {
  await FlutterLocalNotificationsPlugin().cancel(0);
}
