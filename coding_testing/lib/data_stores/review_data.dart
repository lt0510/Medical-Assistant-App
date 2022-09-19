import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/models/appointment_model.dart';
import 'package:medical_app/models/review_model.dart';

class ReviewData {
  final String currentUserID;
  String reviewId= "";

  ReviewData({required this.currentUserID});

  Future<bool> giveRating(String doctorId, int stars) async {
    // Check if input is invalid
    if (stars < 1 || stars > 5) {
      throw Exception("Invalid number of stars");
    }
    // Get all past appointments of patient
    List<AppointmentModel> allAppointments = await getAllPatientAppointments();
    bool patientConsultedDoctor = false;
    // Check if patient has ever consulted the doctor
    // If yes, allow patient to give rating else do not
    for (int index = 0; index < allAppointments.length; index++) {
      if (allAppointments[index].doctorID == doctorId) {
        patientConsultedDoctor = true;
        // Write rating into datastore
        await writeRating(doctorId, stars);
      }
    }
    // Returns true if review is written else false
    return patientConsultedDoctor;
  }

  Future<bool> giveReviewDescription(String doctorId, String text) async {
    print("Updating review for $reviewId");
    await FirebaseFirestore.instance.collection("ReviewData").doc(reviewId).update(
        {"Description":text});
    return true;
  }

  Future<List<AppointmentModel>> getAllPatientAppointments() async {
    List<AppointmentModel> list = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("AppointmentData")
        .where("PatientID", isEqualTo: currentUserID)
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

  Future<void> writeRating(String docID, stars) async {
    var doc = await FirebaseFirestore.instance.collection("ReviewData").add({"DoctorID":docID,"PatientID":currentUserID,"Stars":stars,"Description":""});
    reviewId = doc.id;
    print("Just put rating for reviewid = $reviewId");
  }

  Future<List<ReviewModel>> getAllPatientReviews() async {
    List<ReviewModel> list = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("ReviewData").where("DoctorID",isEqualTo: currentUserID).get();
    list = querySnapshot.docs.map((e) => ReviewModel(patientId: e["PatientID"], doctorId: e["DoctorID"], stars: e["Stars"], description: e["Description"])).toList();
    return list;
  }

  Future<List<ReviewModel>> getDoctorReviews(String docID) async {
    List<ReviewModel> list = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("ReviewData").where("DoctorID",isEqualTo: docID).get();
    list = querySnapshot.docs.map((e) => ReviewModel(patientId: e["PatientID"], doctorId: e["DoctorID"], stars: e["Stars"], description: e["Description"])).toList();
    return list;
  }

  Future<bool> hasPatientReviewedDoctor(String doctorId) async {
   var querySnapshot = await FirebaseFirestore.instance.collection("ReviewData").where("PatientID",isEqualTo: currentUserID).where("DoctorID",isEqualTo: doctorId).get();
   if (querySnapshot.docs.length == 0) {
     return false;
   }
   return true;
  }


}
