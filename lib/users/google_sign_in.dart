import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/users/authservice.dart';

class SignInScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  SignInScreen({super.key});

  void handleGoogleSignIn(BuildContext context) async {
    User? user = await authService.signInWithGoogle();
    if (user != null) {
      print("Google Sign-In Successful: ${user.email}");
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print("Google Sign-In Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => handleGoogleSignIn(context),
          child: Text("Sign in with Google"),
        ),
      ),
    );
  }
}
