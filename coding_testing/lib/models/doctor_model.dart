class Doctor {
  final String fullName;
  final String userId;
  String symptom = "";
  String speciality = "";
  Doctor(
      {required this.fullName,
      required this.userId,
      required this.speciality,
      required this.symptom});
}
