import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/models/appointment_model.dart';
import 'package:medical_app/ui/widgets/snackbar.dart';

class AppointmentData {
  final String doctorID;
  String newAppointmentID = "";

  AppointmentData({required this.doctorID});
  Future<List<AppointmentModel>> getDoctorAppointments() async {
    print("HELLO");
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("AppointmentData")
        .where("DoctorID", isEqualTo: doctorID)
        .where("Approved", isEqualTo: true)
        .get();
    return querySnapshot.docs.map((e) {
      var appointment = e.data() as Map<String, dynamic>;
      return AppointmentModel(
          appointmentID: e.id,
          doctorID: appointment["DoctorID"],
          userID: appointment["PatientID"],
          status: appointment["Approved"],
          hours: appointment["Hours"],
          mins: appointment["Minutes"]);
    }).toList();
  }

  Future<void> approveAppointment(String appointmentID,BuildContext context) async {
    var docSnapshot = await FirebaseFirestore.instance.collection("AppointmentData").doc(appointmentID).get();
    Map<String,dynamic> appointmentData = docSnapshot.data()!;
    bool validAppointment = await confirmAppointment(appointmentData["Hours"],appointmentData["Minutes"]);
    if (validAppointment) {
      await FirebaseFirestore.instance.collection("AppointmentData").doc(appointmentID).update({"Approved":true});
      showSnackBar(context, "Appointment confirmed");
    }else {
      await FirebaseFirestore.instance.collection("AppointmentData").doc(appointmentID).delete();
      showSnackBar(context, "Appointment can't be confirmed. It is not valid");
    }
  }

  Future<void> declineAppointment(String appointmentID) async {
    await FirebaseFirestore.instance.collection("AppointmentData").doc(appointmentID).delete();
  }

  Future<bool> confirmAppointment(int hours, int mins) async {
    // Test if entered time is invalid
    if (hours < 0 || hours > 23 || mins < 0 || mins > 59) {
      throw Exception(
          "Invalid hours/mins"); // Exit function by raising exception
    }
    // Fetch all appointments confirmed by doctor for today
    List<AppointmentModel> allConfirmedAppointments =
        await getDoctorAppointments();
    // Check if entered time conflicts with any of the already scheduled appointments
    if (scheduleConflict(allConfirmedAppointments, hours, mins)) {
      return false;
    }
    return true;
  }

  bool scheduleConflict(List<AppointmentModel> list, int hour, int min) {
    // This function checks if (hour,min) conflicts with any approved appointment in list
    DateTime requestTime = DateTime(0, 0, 0, hour, min);
    bool foundConflict = false;
    for (int i = 0; i < list.length; i++) {
      // Check if (hour,min) is within upper and lower bound
      DateTime appointmentTime = DateTime(0, 0, 0, list[i].hours, list[i].mins);
      DateTime lowerBound = appointmentTime.subtract(Duration(minutes: 30));
      DateTime upperBound = appointmentTime.add(Duration(minutes: 30));
      if (requestTime.compareTo(upperBound) <= 0 &&
          requestTime.compareTo(lowerBound) >= 0) {
        foundConflict = true;
        break;
      }
    }
    return foundConflict;
  }

  Future<void> requestAppointment(String doctorId, String patientID) async {
    CollectionReference appointmentDataStore =
        await FirebaseFirestore.instance.collection("AppointmentData");
    DocumentReference newRequest = await appointmentDataStore
        .add({"DoctorID": doctorId, "PatientID": patientID, "Approved": false});
    this.newAppointmentID = newRequest.id;
  }

  Future<void> setAppointmentTime(int hours, int mins) async {
    CollectionReference appointmentDataStore =
        await FirebaseFirestore.instance.collection("AppointmentData");
    await appointmentDataStore
        .doc(newAppointmentID)
        .update({"Hours": hours, "Minutes": mins});
  }

  Future<List<AppointmentModel>> getAllPatientAppointments(String uid) async {
    List<AppointmentModel> list = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("AppointmentData")
        .where("PatientID", isEqualTo: uid)
        .where("Approved", isEqualTo: true)
        .get();
    list = querySnapshot.docs
        .map((e) => AppointmentModel(
        appointmentID: e.id,
        doctorID: e["DoctorID"],
        userID: e["PatientID"],
        status: e["Approved"],
        hours: e["Hours"],
        mins: e["Minutes"]))
        .toList();
    return list;
  }
}
