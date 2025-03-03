import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/firebase_options.dart';
import 'package:mindmate/users/login.dart';
import 'package:mindmate/users/signup_screen.dart';
import 'home.dart';

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
      home: MyHomePage(title: 'MindMate'),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => MyHomePage(title: 'Mindmate'),
      },
    );
  }
}
