import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'bottom_bar.dart';

class NoNetwork extends StatefulWidget {
  const NoNetwork({super.key});

  @override
  State<NoNetwork> createState() => _NoNetworkState();
}

class _NoNetworkState extends State<NoNetwork> {
  bool _isCheckingConnection = false;

  Future<void> _checkConnectionAndNavigate(BuildContext context) async {
    setState(() => _isCheckingConnection = true);
    
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      
      if (!mounted) return;
      
      if (result.contains(ConnectivityResult.none)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Still offline. Please check your connection"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Connection restored - navigate to home
        print('connection available');
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error checking connection: ${e.toString()}"),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCheckingConnection = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      //  bottomNavigationBar: Bottombar(currentIndex: 5),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 120,
                color: const Color(0xFF2D5DA1),
              ),
              const SizedBox(height: 32),
              Text(
                "Connection Lost",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Whoops! Looks like you're offline.",
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.blueGrey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Please check your internet connection and try again.",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 59, 77, 85),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: _isCheckingConnection
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh, size: 20, color: Colors.white),
                  label: Text(
                    _isCheckingConnection ? "CHECKING..." : "TRY AGAIN",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5DA1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isCheckingConnection
                      ? null
                      : () => _checkConnectionAndNavigate(context),
                ),
              ),
              const SizedBox(height: 20),
             
            ],
          ),
        ),
      ),
    );
  }
}