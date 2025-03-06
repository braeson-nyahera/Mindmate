import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/components.dart';
import 'package:mindmate/top_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _userData = {"name": "Unknown", "email": _user!.email};
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'Home'),
      drawer: DrawerWidget(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userData == null
              ? Center(child: Text("No user data found"))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                            height: 100,
                            width: double.infinity,
                            color: const Color.fromARGB(255, 231, 195, 97),
                            child: SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage:
                                            _userData!["photoURL"] != null &&
                                                    _userData!["photoURL"]
                                                        .isNotEmpty
                                                ? NetworkImage(
                                                    _userData!["photoURL"])
                                                : null,
                                        child: _userData!["photoURL"] == null ||
                                                _userData!["photoURL"].isEmpty
                                            ? Icon(Icons.person,
                                                size:
                                                    40) // Show an icon instead
                                            : null,
                                      ),
                                    ),
                                    Center(
                                      child: SizedBox(
                                        width: 200,
                                        child: Column(children: [
                                          Text(
                                            "${_userData!['name']}",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${_userData!['email']}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: const Color.fromARGB(
                                                  255, 64, 127, 222),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 250,
                          width: double.infinity,
                          color: const Color.fromARGB(255, 184, 199, 226),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 250,
                          width: double.infinity,
                          color: const Color.fromARGB(255, 184, 199, 226),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
