import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindmate/users/authservice.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController password1Controller = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();
  final AuthService authService = AuthService();
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  void signUp() async {
    String email = emailController.text.trim();
    String password1 = password1Controller.text.trim();
    String name = nameController.text.trim();
    String password2 = password2Controller.text.trim();

    if (email.isNotEmpty &&
        password1.isNotEmpty &&
        password2.isNotEmpty &&
        password1 == password2) {
      User? user = await authService.signUp(email, password1);

      if (user != null) {
        await users.add({
          'user_id': user.uid,
          'name': name,
          'email': email,
        });
        print("User Signed Up: ${user.email}");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print("Sign Up Failed");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: password1Controller,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: password2Controller,
              decoration: InputDecoration(labelText: "Re-write Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              child: Text("Sign Up"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text("Already have an account? Log In"),
            ),
          ],
        ),
      ),
    );
  }
}
