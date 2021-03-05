import 'package:flutter/material.dart';

class Appointment {
  final String entryId;
  final String date;
  final String appointmentType;
  final String doctorName;
  final String time;

  Appointment(
      {@required this.date,
      this.appointmentType,
      @required this.entryId,
      @required this.doctorName,
      @required this.time});

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
        date: json['date'],
        entryId: json['entryId'],
        time: json['time'],
        doctorName: json['doctorName'],
        appointmentType: json['AppointmentType']);
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'entryId': entryId,
      'doctorName': doctorName,
      'time': time,
      "AppointmentType": appointmentType
    };
  }
}
