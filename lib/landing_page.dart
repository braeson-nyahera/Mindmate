import 'package:flutter/material.dart';

class LandingWidget extends StatelessWidget {
  const LandingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
            stops: [0.2, 0.8], // Dark blue takes up 20% of the top
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  const SizedBox(height: 50),

                  // App Logo or Image
                  Image.asset(
                    'assets/images/perfectlogo.png',
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.4,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 50),


                
                  // Sign In Button
                  SizedBox(
                    width: screenWidth * 0.85,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5DA1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                           
                        ),
                        
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54, // Slightly faded black
                    ),
                  ),
                   const SizedBox(height: 10),
                  // Log In Button
                   SizedBox(
                    width: screenWidth * 0.85,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 234, 234, 234),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                          side: const BorderSide(
                            color: Color(0xFF2D5DA1), // Border color
                            width: 0.5, // Border thickness
                          ),
                        ),
                        // shadowColor: Colors.black,
                        //  elevation: 8,
                      ),
                      child: const Text(
                        "Log In",
                        style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                 
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
