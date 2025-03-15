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
          stops: [0.2, 0.8], // Dark blue occupies 20% of the screen
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to full width
          children: [
            const Text(
              "WELCOME BACK",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255), // White text for better contrast
              ),
            ),
            const Text(
              "Log into Your Account",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 211, 211, 211), // White text for better contrast
              ),
            ),
            
            const SizedBox(height: 30),

            // Email Input
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Password Input
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Login Button with Border
           ElevatedButton(
              onPressed: signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5DA1),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50), // Full width, 50px height
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Bigger, bold text
              ),
            ),

            const SizedBox(height: 10),


            // Google Sign-In Button
            ElevatedButton(
              onPressed: () => handleGoogleSignIn(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 243, 243, 243),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                minimumSize: const Size(double.infinity, 50), // Width (full) and Height (60px)
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                  side: const BorderSide(
                            color: Color(0xFF2D5DA1), // Border color
                            width: 0.5, // Border thickness
                          ),
                ),
              ),
              // child: const Text("Sign in with Google",
              // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 20),

            // Sign Up Link
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: Text.rich(
                  TextSpan(
                    text: "Don't have an account? ", // Normal text
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    children: [
                      TextSpan(
                        text: "Sign Up", // Styled text
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
  );
}

}
