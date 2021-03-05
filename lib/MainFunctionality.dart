import 'package:flutter/material.dart';
import 'EntryProvider.dart';
import 'appointment.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class EntryScreen extends StatefulWidget {
  final Appointment entry;

  EntryScreen({this.entry});

  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  FlutterLocalNotificationsPlugin localNotification;
  String valueChoose;
  String _date;
  String _dropdownErrorDate;
  String _dropdownErrorTime;
  String _dropdownErrorApt;
  String _tempTime;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List AppointmentType = [
    "Dentist",
    "Clinical",
    "Gynecologist",
    "Dermatologist",
    "Other"
  ];

  // displayError(String error) {
  //   return AlertDialog(
  //     title: Text(error),
  //   );
  // }
  _validateForm(EntryProvider entryProvider) {
    bool _isValid = _formKey.currentState.validate();

    if (valueChoose == null) {
      setState(() => _dropdownErrorApt = "Please select an option!");
      _isValid = false;
    }
    if (_date == null) {
      setState(() => _dropdownErrorDate = "Choose a date !");
      _isValid = false;
    }
    if (_tempTime == null) {
      setState(() => _dropdownErrorTime = "select a time !");
      _isValid = false;
    }

    if (_isValid) {
      entryProvider.saveEntry();
      scheduleNotification(entryProvider);
      Navigator.of(context).pop();
    }
  }

  final entryControllerApt = TextEditingController();

  final entryControllerDoctor = TextEditingController();

  @override
  void dispose() {
    entryControllerApt.dispose();
    entryControllerDoctor.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var androidInitialise = new AndroidInitializationSettings('ic_stat_name');
    var iOSInitialise = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitialise, iOS: iOSInitialise);

    localNotification = new FlutterLocalNotificationsPlugin();
    localNotification.initialize(initializationSettings);
  }

  Future<void> scheduleNotification(EntryProvider entryProvider) async {
    var scheduleNotificationDateTime;
    int year = int.parse(entryProvider.date[6] +
        entryProvider.date[7] +
        entryProvider.date[8] +
        entryProvider.date[9]);
    int month = int.parse(entryProvider.date[0] + entryProvider.date[1]);
    int day = int.parse(entryProvider.date[3] + entryProvider.date[4]);

    if (DateTime.now().day < day) {
      scheduleNotificationDateTime =
          DateTime(year, month, day - 1).add(Duration(seconds: 2));
    } else {
      scheduleNotificationDateTime = DateTime.now().add(Duration(seconds: 2));
    }

    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 1',
      'CHANNEL_NAME 1',
      "CHANNEL_DESCRIPTION 1",
      icon: 'ic_stat_name',
      largeIcon: DrawableResourceAndroidBitmap('ic_stat_name'),
      enableLights: true,
      color: Color.fromARGB(255, 255, 0, 0),
      ledColor: Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      styleInformation: DefaultStyleInformation(true, true),
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
    );

    // ignore: deprecated_member_use
    await localNotification.schedule(
      0,
      "Don't miss your appointment with",
      'of id 0',
      scheduleNotificationDateTime,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }

  String convertTime(String minutes) {
    if (minutes.length == 1) {
      return "0" + minutes;
    } else {
      return minutes;
    }
  }

  String convertDay(String day) {
    if (day.length == 1) {
      return "0" + day;
    } else {
      return day;
    }
  }

  String convertMonth(String month) {
    if (month.length == 1) {
      return "0" + month;
    } else {
      return month;
    }
  }

  TimeOfDay _time = TimeOfDay(hour: 0, minute: 00);
  bool _clicked = false;

  Future<TimeOfDay> _selectTime(
      BuildContext context, EntryProvider entryProvider) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _tempTime = "ok";
        _time = picked;
        _dropdownErrorTime = null;
        entryProvider.changeTime =
            "${convertTime(picked.hour.toString())}:${convertTime(picked.minute.toString())}";
        _clicked = true;
      });
    }

    return picked;
  }

  Future<DateTime> _pickDate(
      BuildContext context, EntryProvider entryProvider) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2050));

    if (picked != null) 
    _dropdownErrorDate = null;
    _date =
        "${convertDay(picked.month.toString())}-${convertMonth(picked.day.toString())}-${picked.year.toString()}";
    entryProvider.changeDate =
        "${convertDay(picked.month.toString())}-${convertMonth(picked.day.toString())}-${picked.year.toString()}";

    return picked;
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Doctor Name',
                          hintText: 'DOCTOR',
                          filled: true,
                          fillColor: Colors.amber),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: entryControllerDoctor,
                      validator: (val) {
                        return RegExp("^[a-zA-Z]+").hasMatch(val)
                            ? null
                            : "Please enter a valid name";
                      },
                      maxLines: 2,
                      minLines: 1,
                      onChanged: (String value) =>
                          entryProvider.changeDoctor = value,
                    ),
                  ),
                  Container(
                    child: MaterialButton(
                      child:
                          _date == null ? Text('Pick a date') : Text('$_date'),
                      onPressed: () {
                        _pickDate(context, entryProvider);
                      },
                    ),
                  ),
                  _dropdownErrorDate == null
                      ? SizedBox.shrink()
                      : Text(
                          _dropdownErrorDate ?? "",
                          style: TextStyle(color: Colors.red),
                        ),

                  // IconButton(
                  //   icon: Icon(Icons.calendar_today),
                  //   onPressed: () {
                  //     if (_pickDate(context, entryProvider) == null) {
                  //       dateSelect = false;
                  //       selectErrorDate(dateSelect);
                  //     } else {
                  //       _pickDate(context, entryProvider);
                  //       dateSelect = true;
                  //     }
                  //   },
                  // ),
                  // ignore: deprecated_member_use
                  FlatButton(
                    color: Color(0xFF3EB16F),
                    shape: StadiumBorder(),
                    onPressed: () {
                      _selectTime(context, entryProvider);
                    },
                    child: Center(
                      child: Text(
                        _clicked == false
                            ? "Pick Time"
                            : "${convertTime(_time.hour.toString())}:${convertTime(_time.minute.toString())}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  _dropdownErrorTime == null
                      ? SizedBox.shrink()
                      : Text(
                          _dropdownErrorTime ?? "",
                          style: TextStyle(color: Colors.red),
                        ),
                  Container(
                    child: DropdownButton(
                      hint: Text('Select the appointment Type: '),
                      dropdownColor: Colors.white,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 30,
                      value: valueChoose,
                      onChanged: (newValue) {
                        setState(() {
                          valueChoose = newValue;
                          entryProvider.changeAptType = newValue;
                          _dropdownErrorApt = null;
                        });
                      },
                      items: AppointmentType.map(
                        (valueItem) {
                          return DropdownMenuItem(
                            value: valueItem,
                            child: Text(valueItem),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  _dropdownErrorApt == null
                      ? SizedBox.shrink()
                      : Text(
                          _dropdownErrorApt ?? "",
                          style: TextStyle(color: Colors.red),
                        ),
                  // ignore: deprecated_member_use
                  RaisedButton(
                    onPressed: () => _validateForm(entryProvider),
                    child: Text("Submit"),
                  ),
                ],
              ),
              // Container(
              //   height: MediaQuery.of(context).size.height * 0.1,
              //   // ignore: deprecated_member_use
              //   child: RaisedButton(
              //       color: Theme.of(context).accentColor,
              //       child: Text('Save', style: TextStyle(color: Colors.white)),
              //       onPressed: () {

              //         if(_formKey.currentState.validate() ){
              //           entryProvider.saveEntry();
              //         scheduleNotification(entryProvider);
              //         Navigator.of(context).pop();
              //         }

              //       }),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
