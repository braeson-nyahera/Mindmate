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
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2D5DA1), // Dark blue (Top)
              Color.fromARGB(255, 231, 231, 231), // Light gray (Bottom)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.8], // Adjust the proportion of blue
          ),
        ),
        child: Center( // Centers everything vertically
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Makes the column wrap content
              children: [
                const Text(
                  "Hello, Register to get Started",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Full Name Field
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(11)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Email Field
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(11)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                
                TextField(
                  controller: password1Controller,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(11)),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                
                TextField(
                  controller: password2Controller,
                  decoration: const InputDecoration(
                    labelText: "Re-write Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                       borderRadius: BorderRadius.all(Radius.circular(11)),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),

               
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5DA1),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 10),

                
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: handleGoogleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                                side: const BorderSide(color: Color(0xFF2D5DA1), width: 1),
                              ),
                            ),
                            // child: const Text(
                            //   "Sign Up with Google",
                            //   style: TextStyle(fontSize: 18),
                            // ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/googleIcon.png', height: 24), // Google logo
                                const SizedBox(width: 10),
                                const Text(
                                  "Continue with Google",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ", // Normal text
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      children: [
                        TextSpan(
                          text: "Log in", // Styled text
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold, // Different weight
                            fontStyle: FontStyle.italic, // Optional italic
                            fontFamily: 'CustomFont', // Change font if needed
                            color: Color(0xFF2D5DA1), // Optional different color
                          ),
                        ),
                      ],
                    ),
                  ),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
