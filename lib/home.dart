import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/course_detail.dart';
import 'notifications.dart';
import 'message_list.dart';
import 'package:mindmate/users/authservice.dart';

import 'package:mindmate/bottom_bar.dart';

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
        });
      } else {
        setState(() {
          _userData = {"name": "Unknown", "email": _user!.email};
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
  final AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         
      // centerTitle: true, 
      automaticallyImplyLeading: false,
      title: Image.asset(
        'assets/images/name.png', // Replace with the actual path to your logo
        height: 35, // Adjust height as needed
        fit: BoxFit.contain,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, size: 32),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationsWidget(),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.chat),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessageListScreen(),
              ),
            );
          },
        ),
        // IconButton(
        //   icon: Icon(Icons.logout),
        //   onPressed: () {
        //     authService.signOut();
        //     Navigator.pushReplacementNamed(context, '/login');
        //   },
        // ),
      ],
    
      ),
      bottomNavigationBar: Bottombar(currentIndex: 0), 
      
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userData == null
              ? Center(child: Text("No user data found"))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView(
                    children: [
                      // User Info Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Color(0xFF2D5DA1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundImage: _userData!["photoURL"] != null &&
                                            _userData!["photoURL"].isNotEmpty
                                        ? NetworkImage(_userData!["photoURL"])
                                        : null,
                                    child: _userData!["photoURL"] == null ||
                                            _userData!["photoURL"].isEmpty
                                        ? Icon(Icons.person, size: 40)
                                        : null,
                                  ),
                                ),
                                Center(
                                  child: SizedBox(
                                    width: 200,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${_userData!['name']}",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          "${_userData!['email']}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Featured Section Placeholder
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 250,
                          width: double.infinity,
                          color: const Color.fromARGB(255, 184, 199, 226),
                        ),
                      ),

                      SizedBox(height: 20),



                      // Recommended Courses Section (DYNAMIC FROM FIRESTORE)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 280,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Recommended Courses →",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 200, // Height for scrolling area
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('courses').limit(10).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(child: Text("No courses available!"));
                          }

              var courseLists = snapshot.data!.docs;

              return ListView.builder(
                scrollDirection: Axis.horizontal, // Horizontal scroll
                itemCount: courseLists.length,
                itemBuilder: (context, index) {
                  var data = courseLists[index].data() as Map<String, dynamic>;
                  var courseId = courseLists[index].id;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetail(
                            courseId: courseId,
                            userId: _auth.currentUser!.uid,
                          ),
                        ),
                      );
                    },
                    child: Container(
                          width: 150,
                          height: 210,
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10), // Add vertical margin
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(3, 3), // Only downward shadow
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                child: data['imageUrl'] != null
                                    ? Image.network(
                                        data['imageUrl'],
                                        width: 150,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/mmBareLogo.png',
                                        width: 150,
                                        height: 120,
                                        fit: BoxFit.fill,
                                      ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        data['title'] ?? "No Title",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                         maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        data['Author'] ?? "Unknown Author",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                       
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
