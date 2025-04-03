import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mindmate/no_network.dart';

class LandingWidget extends StatefulWidget {
  const LandingWidget({super.key});

  @override
  State<LandingWidget> createState() => _LandingWidgetState();
}

class _LandingWidgetState extends State<LandingWidget> {
  bool _isCheckingConnection = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription; // Updated type

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        _redirectToNoNetwork();
      }
    });
  }

  Future<void> _checkInternetConnection() async {
    final connectivity = Connectivity();
    final results = await connectivity.checkConnectivity();
    
    if (!mounted) return;
    
    if (results.contains(ConnectivityResult.none)) {
      _redirectToNoNetwork();
    } else {
      setState(() => _isCheckingConnection = false);
    }
  }

  void _redirectToNoNetwork() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NoNetwork()),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingConnection) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

     double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Rest of your build method...
     return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2D5DA1),
              Color.fromARGB(255, 231, 231, 231),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.8],
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
                  Image.asset(
                    'assets/images/perfectlogo.png',
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.4,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 50),
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
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                            color: Color(0xFF2D5DA1),
                            width: 0.5,
                          ),
                        ),
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