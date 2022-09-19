import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/data_stores/appointment_data.dart';
import 'package:medical_app/data_stores/review_data.dart';
import 'package:medical_app/data_stores/user_data.dart';
import 'package:medical_app/ui/consultation.dart';
import 'package:medical_app/ui/doctor_reviews.dart';
import 'package:medical_app/ui/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class DoctorHome extends StatelessWidget {
  const DoctorHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          Text(
            "Hello ${context.read<UserData>().fullName}",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Your Appointment Requests",
            textScaleFactor: 1.5,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Requests(),
          SizedBox(
            height: 10,
          ),
          Text(
            "Your Scheduled Appointments",
            textScaleFactor: 1.5,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Scheduled(),
          SizedBox(
            height: 10,
          ),
            CustomButton(onTap: () async {
              var reviews = await ReviewData(currentUserID: context.read<UserData>().user.uid).getDoctorReviews(context.read<UserData>().user.uid);
              Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorReviews(reviews: reviews)));
            }, text: "Patient Reviews"),
          SizedBox(height: 10,),
          CustomButton(
              onTap: () => context.read<UserData>().signOut(context),
              text: "Sign Out"),

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
      stream: FirebaseFirestore.instance.collection("AppointmentData").where("DoctorID",isEqualTo: context.read<UserData>().user.uid).where("Approved",isEqualTo: true).snapshots(),
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


class Requests extends StatelessWidget {
  const Requests({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("AppointmentData")
              .where("DoctorID", isEqualTo: context.read<UserData>().user.uid)
              .where("Approved", isEqualTo: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.docs.length == 0) {
                return Text("No requests for today");
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    return AppointmentTile(doc: doc);
                  });
            }
            return Text("No Requests");
          }),
    );
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
                    .getPatientNameFromID(doc["PatientID"]),
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


class AppointmentTile extends StatelessWidget {
  const AppointmentTile({
    Key? key,
    required this.doc,
  }) : super(key: key);

  final DocumentSnapshot<Object?> doc;

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
                    .getPatientNameFromID(doc["PatientID"]),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    var dataStore = AppointmentData(doctorID: context.read<UserData>().user.uid);
                    dataStore.approveAppointment(doc.id, context);
                  },
                  icon: Icon(Icons.check_circle),
                  iconSize: 40,
                ),
                IconButton(
                  onPressed: () {
                    var dataStore = AppointmentData(doctorID: context.read<UserData>().user.uid);
                    dataStore.declineAppointment(doc.id);
                  },
                  icon: Icon(Icons.cancel),
                  iconSize: 40,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
