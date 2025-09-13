import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Config
import 'package:mindmate/config/firebase_options.dart';

// Screens - Auth
import 'package:mindmate/screens/auth/landing_page.dart';
import 'package:mindmate/screens/auth/login.dart';
import 'package:mindmate/screens/auth/signup_screen.dart';

// Screens - Main
import 'package:mindmate/screens/main/home.dart';
import 'package:mindmate/screens/main/profile.dart';
import 'package:mindmate/screens/main/notifications.dart';

// Screens - Courses
import 'package:mindmate/screens/courses/courses.dart';

// Screens - Forum
import 'package:mindmate/screens/forum/forum.dart';

// Screens - Tutors
import 'package:mindmate/screens/tutors/tutors.dart';
import 'package:mindmate/screens/tutors/tutor_details.dart';

// Screens - Messaging
import 'package:mindmate/screens/messaging/chats.dart';
import 'package:mindmate/screens/messaging/message_list.dart';

// Utils
import 'package:mindmate/utils/no_network.dart';
//import 'package:connectivity_plus/connectivity_plus.dart';

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
  const AuthCheck({super.key});

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
        '/tutor_details': (context) => TutorDetails(),
        '/no_network': (context) => NoNetwork(),
      },
    );
  }
}
