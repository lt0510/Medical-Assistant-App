import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/data_stores/user_data.dart';
import 'package:medical_app/firebase_options.dart';
import 'package:medical_app/ui/home_screen.dart';
import 'package:medical_app/ui/login.dart';
import 'package:medical_app/ui/register.dart';
import 'package:medical_app/ui/search_doctor/search_by_name.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<UserData>(
            create: (_) => UserData(FirebaseAuth.instance),
          ),
          StreamProvider(
              create: (context) => context.read<UserData>().authState,
              initialData: null)
        ],
        child: MaterialApp(
          title: "Medical Assistance App",
          home: const AuthWrapper(),
          routes: {
            Register.routeName: (context) => const Register(),
            SearchByName.routeName: (context) => const SearchByName()
          },
        ));
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}
