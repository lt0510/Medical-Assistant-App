class ReviewModel {
  String patientId;
  String doctorId;
  int stars;
  String description;
  ReviewModel({required this.patientId, required this.doctorId, required this.stars, required this.description});
}