class AppointmentModel {
  final String appointmentID;
  final String doctorID;
  final String userID;
  final bool status;
  final int hours;
  final int mins;

  AppointmentModel(
      {required this.appointmentID,
      required this.doctorID,
      required this.userID,
      required this.status,
      required this.hours,
      required this.mins});
}
