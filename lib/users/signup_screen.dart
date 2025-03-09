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
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void signUp() async {
    String email = emailController.text.trim();
    String password1 = password1Controller.text.trim();
    String name = nameController.text.trim();
    String password2 = password2Controller.text.trim();

    if (email.isNotEmpty &&
        name.isNotEmpty &&
        password1.isNotEmpty &&
        password2.isNotEmpty &&
        password1 == password2) {
      User? user = await authService.signUp(email, password1);

      if (user != null) {
        await _saveUserToFirestore(user);
        print("User Signed Up: ${user.email}");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print("Sign Up Failed");
      }
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    final userDoc = _firestore.collection("users").doc(user.uid);

    final userData = {
      "uid": user.uid,
      "name": user.displayName ?? "No Name",
      "email": user.email ?? "No Email",
      "photoURL": user.photoURL ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    };

    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set(userData);
      print("User saved to Firestore");
    } else {
      print("User already exists in Firestore");
    }
  }

  void handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    User? user = await authService.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      print("Google Sign-Up Successful: ${user.email}");
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print("Google Sign-Up Failed");
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
            Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: handleGoogleSignUp,
                      child: Text("Sign Up with Google"),
                    ),
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
