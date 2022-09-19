import 'package:firebase_auth/firebase_auth.dart';

// EMAIL SIGN UP
Future<void> signUpWithEmail({
  required String email,
  required String password,
}) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    print(e.message!); // Displaying the error message
  }
}

//FORGOT  PASSWORD
Future<void> forgotPassword({required String email}) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  } on FirebaseAuthException catch (e) {
    print(e.message!); //Displaying the error message
  }
}
