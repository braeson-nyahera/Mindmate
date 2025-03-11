import 'package:flutter/material.dart';
import 'package:mindmate/notifications.dart';
import 'chats.dart';
import 'package:mindmate/users/authservice.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
 final String title;
  
  
  final AuthService authService = AuthService();

  TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      // toolbarHeight: 180,
      actions: [
        // IconButton(
        //   icon:Icon(Icons.notifications_outlined,size: 32,),
        //    onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => NotificationsWidget(), // Replace with your actual page widget
        //       ),
        //     );
        //   },
        //   ),

          // IconButton(
          //   icon: Icon(Icons.chat),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ChatsWidget(),
          //       ),
          //     );
          //   },
          // ),

        //  IconButton(
        //    icon: Icon(Icons.logout),
        //   onPressed: () {
        //     authService.signOut();
        //     Navigator.pushReplacementNamed(context, '/login');
        //   },
        //  )

         
        
      ],
      // backgroundColor: const Color.fromARGB(255, 127, 194, 225),
      title: Center(
        child: Text(
          title,
         
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
           fontSize: 25, // Adjusts the font size
          fontWeight: FontWeight.bold,
           ),
        ),
      ),
      
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
