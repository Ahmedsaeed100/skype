import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skype/resources/firebase_repository.dart';
import 'package:skype/screens/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseRepository _repository = FirebaseRepository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("login Screen"),
      ),
      body: Center(child: loginButton()),
    );
  }

  Widget loginButton() {
    return ElevatedButton(
      onPressed: () {
        PerformLogin();
      },
      child: const Text("Login"),
    );
  }

  // ignore: non_constant_identifier_names
  void PerformLogin() {
    _repository.googleSignUp().then((value) {
      if (value != null) {
        authenticateUser(value);
      } else {
        debugPrint("error");
      }
    });
  }

  void authenticateUser(User user) {
    _repository.authenticateUser(user).then(
      (isNewUser) {
        if (isNewUser) {
          _repository.addDataToDb(user).then(
            (value) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const HomeScreen();
                  },
                ),
              );
            },
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const HomeScreen();
              },
            ),
          );
        }
      },
    );
  }
}
