import 'package:flutter/material.dart';
import 'package:mindmate/services/authservice.dart';

class SignInScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  SignInScreen({super.key});

  void handleGoogleSignIn(BuildContext context) async {
    try {
      final result = await authService.signInWithGoogle();
      if (result.isSuccess && result.user != null) {
        print("Google Sign-In Successful: ${result.user!.email}");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print("Google Sign-In Failed: ${result.message}");
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
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
