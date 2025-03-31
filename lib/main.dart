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
import 'package:mindmate/tutor_details.dart';
import 'package:mindmate/no_network.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart'; 
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Checking connectivity...');
  final connectivity = Connectivity();
  final connectivityResult = await connectivity.checkConnectivity();
  print('Connectivity result: $connectivityResult');
  
  if (connectivityResult == ConnectivityResult.none) {
    print('No network detected - showing NoNetwork screen');
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NoNetwork(),
    ));
    return;
  }
  
  try {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('test').add({'message': 'Hello from Mindmate!'});
    print("Firebase Initialized Successfully");
    runApp(const MyApp());
  } catch (e) {
    print('Firebase initialization failed: $e');
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NoNetwork(),
    ));
  }
}


class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        // color: const Color(0xFF2D5DA1),
        color: const Color.fromARGB(255, 45, 93, 161),
        width: double.infinity,
        child: const Center(
          child: Text(
            "You are offline",
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final bool isInitialCheck;
  
  const ConnectivityWrapper({
    super.key, 
    required this.child,
    this.isInitialCheck = false,
  });
  
  
  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  // bool _showBanner = false;
  Timer? _connectionTimer;
  bool _initialCheckCompleted = false;

  @override
  // void initState() {
  //   super.initState();
  //   _checkInitialConnection();
  // }
  void initState() {
  super.initState();
  // Add this workaround for web
  if (kIsWeb) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialConnection();
    });
  } else {
    _checkInitialConnection();
  }
}

  Future<void> _checkInitialConnection() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    final hasConnection = result.isNotEmpty && !result.contains(ConnectivityResult.none);
    
    if (!hasConnection && widget.isInitialCheck) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/no_network');
      }
    } else {
      _initialCheckCompleted = true;
    }
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active && _initialCheckCompleted) {
          final result = snapshot.data;
          final hasConnection = result != null && 
                              result.isNotEmpty && 
                              !result.contains(ConnectivityResult.none);
          
          _connectionTimer?.cancel();
          
          if (!hasConnection) {
            _connectionTimer = Timer(const Duration(seconds: 2), () {
              if (mounted) MyApp.of(context)?.setOffline(true);
            });
          } 
          else {
            // Delay setOffline until after build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) MyApp.of(context)?.setOffline(false);
            });

            if (MyApp.of(context)?.offline == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // if (mounted) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(
                //       content: Text("Connection restored!"),
                //       duration: Duration(seconds: 2),
                //     ),
                //   );
                // }
              });
            }
          }
        }

        return widget.child;
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      isInitialCheck: true, // Redirects to NoNetwork only on app startup
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return MyHomePage(title: 'Mindmate');
          }
          return LandingWidget();
        },
      ),
    );
  }
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  bool offline = false;

  void setOffline(bool value) {
    setState(() {
      offline = value;
    });
  }

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
      home: Column(
        children: [
          if (offline) const OfflineBanner(),
          Expanded(child: AuthCheck()),
        ],
      ),
      routes: {
        '/login': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: LoginScreen()))]),
        '/signup': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: SignUpScreen()))]),
        '/home': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: MyHomePage(title: 'Mindmate')))]),
        '/courses': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: CoursesList()))]),
        '/forum': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: ForumsWidget()))]),
        '/tutors': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: TutorsWidget()))]),
        '/profile': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: ProfileWidget()))]),
        '/notifications': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: NotificationsWidget()))]),
        '/landing_page': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: LandingWidget()))]),
        '/chats': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: ChatsWidget()))]),
        '/message_details': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: MessageListScreen()))]),
        '/tutor_details': (context) => Column(children: [if (offline) const OfflineBanner(), Expanded(child: ConnectivityWrapper(child: TutorDetails()))]),
        '/no_network': (context) => NoNetwork(),
      },
    );
  }
}