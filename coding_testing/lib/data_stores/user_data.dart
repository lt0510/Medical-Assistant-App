import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserData {
  final FirebaseAuth _auth;
  UserData(this._auth);

  User get user => _auth.currentUser!;

  String fullName = "";
  String type = "";

  // STATE PERSISTENCE STREAM
  Stream<User?> get authState => FirebaseAuth.instance.authStateChanges();

  // EMAIL SIGN UP
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // if you want to display your own custom error message
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      print(e.message!); // Displaying the usual firebase error message
    }
  }

  // EMAIL LOGIN
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print(e.message!); // Displaying the error message
    }
  }

  // SIGN OUT
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      print(e.message!); // Displaying the error message
    }
  }

  Future<void> addUser(String userID, String fullName, String type) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('UserData');
    await users.doc(userID).set({"UserType": type, "Name": fullName});
  }

  Future<String> get userType async {
    String userID = _auth.currentUser!.uid;
    var docRef = await FirebaseFirestore.instance
        .collection('UserData')
        .doc(userID)
        .get();
    var userType = docRef.data()!["UserType"];
    this.type = userType;
    this.fullName = docRef.data()!["Name"];
    print("Name is ${FirebaseAuth.instance.currentUser!.uid}");
    return userType;
  }

  Future<String> getPatientNameFromID(String id) async {
    var docRef =
        await FirebaseFirestore.instance.collection("UserData").doc(id).get();
    return docRef.data()!["Name"];
  }
}
