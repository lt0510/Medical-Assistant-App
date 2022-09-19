import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:medical_app/data_stores/appointment_data.dart';
import 'package:medical_app/data_stores/review_data.dart';
import 'package:medical_app/data_stores/user_data.dart';
import 'package:medical_app/models/doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/ui/doctor_reviews.dart';
import 'package:medical_app/ui/widgets/custom_button.dart';
import 'package:medical_app/ui/widgets/custom_multilinetext.dart';
import 'package:medical_app/ui/widgets/custom_textfield.dart';
import 'package:medical_app/ui/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class DoctorProfile extends StatelessWidget {
  final Doctor selectedDoc;
  const DoctorProfile({required this.selectedDoc, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Doctor: ${selectedDoc.fullName}",
                textScaleFactor: 2,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Speciality: ${selectedDoc.speciality}",
                textScaleFactor: 1.8,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Symptoms Treated:",
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 1.6,
              ),
              Text(
                selectedDoc.symptom,
                textScaleFactor: 1.5,
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                  child: RequestAppointmentButton(selectedDoc: selectedDoc))
            ],
          ),
        ),
      ),
    );
  }
}

class RequestAppointmentButton extends StatefulWidget {
  RequestAppointmentButton({
    Key? key,
    required this.selectedDoc,
  }) : super(key: key);

  final Doctor selectedDoc;

  @override
  State<RequestAppointmentButton> createState() =>
      _RequestAppointmentButtonState();
}

class _RequestAppointmentButtonState extends State<RequestAppointmentButton> {
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController minsController = TextEditingController();
  bool sentRequest = false;

  @override
  Widget build(BuildContext context) {
    if (sentRequest == false) {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: CustomTextField(
                        controller: hoursController, hintText: "Enter hours")),
                Expanded(
                    child: CustomTextField(
                        controller: minsController, hintText: "Enter minutes"))
              ],
            ),
            CustomButton(
                onTap: () async {
                  final appointmentStore =
                      AppointmentData(doctorID: widget.selectedDoc.userId);
                  if (hoursController.text == "" || minsController.text == "") {
                    showSnackBar(context, "Don't leave hours/mins blank");
                  } else {
                    int hours = int.parse(hoursController.text);
                    int mins = int.parse(minsController.text);
                    await appointmentStore.requestAppointment(
                        widget.selectedDoc.userId,
                        context.read<UserData>().user.uid);
                    await appointmentStore.setAppointmentTime(hours, mins);
                    showSnackBar(context, "Request sent");
                    setState(() {
                      sentRequest = true;
                    });
                  }
                },
                text: "Request Appointment"),
            SizedBox(height: 20,),
            GiveRating(selectedDoc: widget.selectedDoc,),
            SizedBox(height: 20,),
            CustomButton(onTap: ()async{
              var reviews = await ReviewData(currentUserID: context.read<UserData>().user.uid).getDoctorReviews(widget.selectedDoc.userId);
              Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorReviews(reviews: reviews)));
            }, text: "View All Rreviews")
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}

class GiveRating extends StatefulWidget {
  GiveRating({
    required this.selectedDoc,
    Key? key,
  }) : super(key: key);
  Doctor selectedDoc;

  @override
  State<GiveRating> createState() => _GiveRatingState();
}

class _GiveRatingState extends State<GiveRating> {
  TextEditingController description = TextEditingController();
  int stars = 3;
  bool gaveRating = false;
  @override
  Widget build(BuildContext context) {
    if (gaveRating) {
      return Container();
    }

    return FutureBuilder<bool>(
      future: ReviewData(currentUserID: context.read<UserData>().user.uid).hasPatientReviewedDoctor(widget.selectedDoc.userId),
      builder: (context,snapshot){
        if (snapshot.hasData) {
          if (snapshot.data == true) {
            return Text("You have already rated this doctor",textScaleFactor: 1.5,);
          } else {
            return Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text("Give your rating",textScaleFactor: 1.6,),
                    RatingBar.builder(
                      initialRating: 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        int rate = rating.round();
                        setState(() {
                          stars = rate;
                        });
                        print(rate);
                      },
                    ),
                    CustomMultiLineTextField(controller: description, hintText: "Enter your review description"),
                    CustomButton(onTap: ()async{
                      try{
                        var dataStore =ReviewData(currentUserID: context.read<UserData>().user.uid);
                        bool canRate = await dataStore.giveRating(widget.selectedDoc.userId, stars);
                        if (canRate == false) {
                          throw Exception("Can't rate");
                        }
                        await dataStore.giveReviewDescription(widget.selectedDoc.userId, description.text);
                        setState(() {
                          gaveRating = true;
                        });
                      } on Exception{
                        showSnackBar(context, "You can't post the review.");
                      }
                    }, text: "Submit Review")
                  ],
                ),
              ),
            );
          }
        }
        return CircularProgressIndicator();
      },
    );
  }
}
