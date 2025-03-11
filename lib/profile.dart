import 'package:flutter/material.dart';
import 'package:mindmate/bottom_bar.dart';
import 'package:mindmate/users/authservice.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});
  

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
           IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            authService.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        ],
      ),
      bottomNavigationBar: Bottombar(currentIndex: 4), 
      body: Text("THis is profile page"),
    );
  }
}