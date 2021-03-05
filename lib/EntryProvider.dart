import 'package:flutter/material.dart';
import 'firestore_service.dart'; 
import 'appointment.dart';
import 'package:uuid/uuid.dart';

class EntryProvider with ChangeNotifier {
  final firestoreService = FirestoreService();

  String _date;
  String _entry;
  String _aptType;
  String _time;
  String _doctorName;
  String _entryId;

  var uuid = Uuid();

  //Getters
  String get date => _date;
  String get aptType => _aptType;
  String get entry => _entry;
  String get time => _time;
  String get doctorName => _doctorName;
 
  Stream<List<Appointment>> get entries => firestoreService.getEntries();

  //Setters
  set changeDate(String date) {
    _date = date;
    notifyListeners();
  }

  set changeAptType(String apt) {
    _aptType = apt;
    notifyListeners();
  }

  set changeDoctor(String doctor) {
    _doctorName = doctor;
    notifyListeners();
  }

  set changeTime(String time) {
    _time = time;
    notifyListeners();
  }

 

  //Functions
  loadAll(Appointment entry) {
    if (entry != null) {
      _date = entry.date;
      _aptType = entry.appointmentType;
      _entryId = entry.entryId;
      _doctorName = entry.doctorName;
      _time = entry.time;
    } else {
      _aptType = null;
      _date = null;
      _entry = null;
      _entryId = null;
      _time = null;
      _doctorName = null;
    }
  }

  saveEntry() {
    if (_entryId == null) {
      //Add
      var newEntry = Appointment(
        date: _date,
        entryId: uuid.v1(),
        doctorName: _doctorName,
        time: _time,
        appointmentType: _aptType,
    
      );

      firestoreService.setEntry(newEntry);
    } else {
      //Edit
      var updatedEntry = Appointment(
        date: _date,
        entryId: uuid.v1(),
        doctorName: _doctorName,
        time: _time,
        appointmentType: _aptType,
      );
      firestoreService.setEntry(updatedEntry);
    }
  }

  removeEntry(String entryId) {
    firestoreService.removeEntry(entryId);
  }
}
