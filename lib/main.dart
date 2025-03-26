import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/chats.dart';
import 'package:mindmate/courses.dart';
import 'package:mindmate/firebase_options.dart';
import 'package:mindmate/forum.dart';
import 'package:mindmate/landing_page.dart';
import 'package:mindmate/notifications.dart';
import 'package:mindmate/profile.dart';
import 'package:mindmate/tutors.dart';
import 'package:mindmate/users/login.dart';
import 'package:mindmate/users/signup_screen.dart';
import 'package:mindmate/message_list.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Test Firestore connection
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  await firestore.collection('test').add({'message': 'Hello from Mindmate!'});
  print("Firebase Initialized Successfully");
  runApp(const MyApp());
}
class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return MyHomePage(title: 'Mindmate'); // User is logged in
        }
        return LandingWidget(); // User is not logged in
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 18, 156, 184)),
        useMaterial3: true,
      ),
       home: AuthCheck(), //MyHomePage(title: 'MindMate'),
      // initialRoute: '/landing_page',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => MyHomePage(title: 'Mindmate'),
        '/courses': (context) => CoursesList(),
        '/forum': (context) => ForumsWidget(),
        '/tutors': (context) => TutorsWidget(),
        '/profile': (context) => ProfileWidget(),
        '/notifications': (context) => NotificationsWidget(),
        '/landing_page': (context) => LandingWidget(),
        '/chats': (context) => ChatsWidget(),
        '/message_details': (context) => MessageListScreen(),
      },
    );
  }
}
