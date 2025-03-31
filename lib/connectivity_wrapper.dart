import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:mindmate/no_network.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isOffline = false;
  Timer? _connectionTimer;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((result) {
      final hasConnection = result.isNotEmpty && !result.contains(ConnectivityResult.none);

      // Delay for 2 seconds before marking as offline to prevent flickering
      if (!hasConnection) {
        _connectionTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isOffline = true);
        });
      } else {
        _connectionTimer?.cancel();
        setState(() => _isOffline = false);
      }
    });
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child, // The main content
          if (_isOffline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.redAccent,
                padding: const EdgeInsets.all(10),
                child: const Center(
                  child: Text(
                    "No Internet Connection",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
