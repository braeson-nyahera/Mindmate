import 'package:flutter/material.dart';
import 'package:mindmate/users/authservice.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AuthService authService = AuthService();

  TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            authService.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
        )
      ],
      backgroundColor: const Color.fromARGB(255, 127, 194, 225),
      title: Center(
        child: Text(
          title,
          style: const TextStyle(color: Color.fromARGB(255, 251, 252, 253)),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
