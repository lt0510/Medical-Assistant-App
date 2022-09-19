class MediaData {
  Future<void> sendChatMessage(String senderID, String receiverID) async {}
  Future<void> startAudioVideoConsultation(
      String doctorID, String patientID) async {}
  Future<void> uploadReport(String doctorID, String patientID) async {}
  Future<void> givePrescription(String doctorID, String patientID) async {}
}
