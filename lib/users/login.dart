import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'authservice.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  void signIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      User? user = await authService.signIn(email, password);
      if (user != null) {
        print("User Logged In: ${user.email}");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print("Login Failed");
      }
    }
  }

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
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signIn,
              child: Text("Login"),
            ),
            ElevatedButton(
              onPressed: () => handleGoogleSignIn(context),
              child: Text("Sign in with Google"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
