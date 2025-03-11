import 'package:flutter/material.dart';

import 'bottom_bar.dart';
class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          centerTitle: true,
        // backgroundColor: const Color(0xFF2D5DA1),
        title: const Text("Notifications",
        style: TextStyle(
           fontSize: 25, // Adjusts the font size
            fontWeight: FontWeight.bold, // Makes the text bold
            color: Colors.black,
                ),
          ),
         leading: IconButton(icon: const Icon(Icons.arrow_back), 
         onPressed: () {
          Navigator.pop(context);
          }),
          
      ),
       body: Text("Notifications Page"),
       bottomNavigationBar: Bottombar(currentIndex: 5), 
    );
  }
}