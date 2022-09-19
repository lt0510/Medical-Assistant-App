import 'package:flutter/material.dart';
import 'package:medical_app/data_stores/user_data.dart';
import 'package:medical_app/ui/register.dart';
import 'package:medical_app/ui/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = '/login-email-password';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void loginUser() {
    context.read<UserData>().loginWithEmail(
          email: emailController.text,
          password: passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Login",
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
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
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: loginUser,
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
              "Login",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              "Don't have an account? Click on the button below to register as Patient/Doctor",
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, Register.routeName),
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
              "Register",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
