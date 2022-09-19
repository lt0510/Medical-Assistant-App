import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/data_stores/appointment_data.dart';
import 'package:medical_app/data_stores/user_data.dart';
import 'package:medical_app/models/appointment_model.dart';
import 'package:medical_app/ui/consultation.dart';
import 'package:medical_app/ui/search_doctor/search_by_name.dart';
import 'package:medical_app/ui/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class PatientHome extends StatelessWidget {
  const PatientHome({Key? key}) : super(key: key);
  // Future<void> tryDoctorAppointments() async{
  //   List<AppointmentModel> l = await AppointmentData().getDoctorAppointments("fy5eB3pDljUPNVratPT2");
  //   l.forEach((element) {print("Found Appointment ${element.appointmentID}");});
  // }
  @override
  Widget build(BuildContext context) {
    // tryDoctorAppointments();
    return Scaffold(
        body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Hello ${context.read<UserData>().fullName}",
                    style: TextStyle(fontSize: 20),
                  ),
                  Center(
                      child: CustomButton(
                          onTap: () => Navigator.pushNamed(
                              context, SearchByName.routeName),
                          text: "Search by Name")),
                  CustomButton(onTap: () {}, text: "Search by Speciality"),
                  CustomButton(onTap: () {}, text: "Search by Symptoms"),
                  Text("Your Approved Appointments",textScaleFactor: 1.3,),
                  Scheduled(),
                  CustomButton(
                      onTap: () => context.read<UserData>().signOut(context),
                      text: "Sign Out")
                ],
              ),
            )));
  }
}


class Scheduled extends StatelessWidget {
  const Scheduled({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("AppointmentData").where("PatientID",isEqualTo: context.read<UserData>().user.uid).where("Approved",isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.length == 0) {
            return Text("No scheduled appointments");
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context,index) {
                DocumentSnapshot doc = snapshot.data!.docs[index];
                return ScheduledAppointmentTile(doc:doc);
              });
        }
        return Text("No scheduled appointments");
      },
    ));
  }
}

class ScheduledAppointmentTile extends StatelessWidget {
  final DocumentSnapshot<Object?> doc;
  const ScheduledAppointmentTile({required this.doc,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.4)),
        child: Column(
          children: [
            FutureBuilder<String>(
                future: context
                    .read<UserData>()
                    .getPatientNameFromID(doc["DoctorID"]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data ?? "Patient",
                      textScaleFactor: 1.4,
                    );
                  }
                  return Container(
                    height: 20,
                  );
                }),
            Text(
              "Hours: ${doc["Hours"]} \t Minutes: ${doc["Minutes"]}",
              textScaleFactor: 1.3,
            ),
            IconButton(onPressed: (){
              String meetingURL = "meet.jit.si/"+doc["PatientID"]+"_"+doc["DoctorID"];
              Navigator.push(context, MaterialPageRoute(builder: (context)=>MeetingWebView(meetingUrl: meetingURL)));
            }, icon: Icon(Icons.video_call),iconSize: 40,)
          ],
        ),
      ),
    );
  }
}