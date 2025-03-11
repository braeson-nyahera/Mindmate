import 'package:flutter/material.dart';
import 'bottom_bar.dart';


class ChatsWidget extends StatefulWidget {
  const ChatsWidget({super.key});

  @override
  State<ChatsWidget> createState() => _ChatsWidgetState();
}

class _ChatsWidgetState extends State<ChatsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       bottomNavigationBar: Bottombar(currentIndex: 5), 
       appBar: AppBar(
          toolbarHeight: 80,
        // backgroundColor: const Color(0xFF2D5DA1),
        title: const Text("Chats",
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

    );
  }
}