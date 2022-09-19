import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/data_stores/doctor_data.dart';
import 'package:medical_app/data_stores/user_data.dart';
import 'package:medical_app/ui/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  static String routeName = '/register';
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController specialityController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();

  String? userType;

  void signUpUser() async {
    await context.read<UserData>().signUpWithEmail(
          email: emailController.text,
          password: passwordController.text,
        );
    String userID = context.read<User?>()!.uid;
    print("USER ID = $userID");
    await context
        .read<UserData>()
        .addUser(userID, nameController.text, userType ?? "Patient");
    if (userType == "Doctor") {
      await DoctorData().addDoctor(userID, nameController.text,
          specialityController.text, symptomsController.text);
    }
    await context.read<UserData>().loginWithEmail(
        email: emailController.text, password: passwordController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              const Text(
                "Sign Up",
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomTextField(
                  controller: nameController,
                  hintText: 'Enter your name',
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomTextField(
                  controller: emailController,
                  hintText: 'Enter your email',
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomTextField(
                  controller: passwordController,
                  hintText: 'Enter your password',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownButton<String>(
                value: userType,
                hint: const Text("Are you a doctor or patient?"),
                items: <String>['Doctor', 'Patient'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (type) {
                  setState(() {
                    userType = type;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              userType == "Doctor"
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomTextField(
                          controller: specialityController,
                          hintText: "Enter your speciality"))
                  : Container(),
              const SizedBox(
                height: 20,
              ),
              userType == "Doctor"
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomTextField(
                          controller: symptomsController,
                          hintText: "Enter the symptoms you treat"))
                  : Container(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: signUpUser,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(color: Colors.white),
                  ),
                  minimumSize: MaterialStateProperty.all(
                    Size(MediaQuery.of(context).size.width / 2.5, 50),
                  ),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
