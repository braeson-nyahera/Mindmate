import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/course_detail.dart';
import 'notifications.dart';
import 'message_list.dart';
import 'package:mindmate/users/authservice.dart';
import 'dart:math';
import 'package:intl/intl.dart';


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
  Set<String> enrolledCourses = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
    fetchEnrolledCourses();
  }

  

  Future<void> fetchEnrolledCourses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Get a direct reference to the enrolls collection
      final enrollsRef = FirebaseFirestore.instance.collection('enrolls');

      // Query all enrollments for this user
      final QuerySnapshot enrollSnapshot =
          await enrollsRef.where('user', isEqualTo: userId).get();

      // Extract course IDs from enrollment documents with null check
      final Set<String> enrolledIds = {};
      for (var doc in enrollSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['course'] != null) {
          enrolledIds.add(data['course'] as String);
        }
      }

      setState(() {
        enrolledCourses = enrolledIds;
        isLoading = false;
      });

      print('Enrolled courses: $enrolledCourses'); // Debug print
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

 Future<Map<String, dynamic>?> _getLatestAppointment() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return null;

  try {
    final DateTime now = DateTime.now();
    
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: currentUser.uid) // Only fetch current user's appointments
        .where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(now)) // Filter future dates
        .orderBy('date', descending: false) // Sort by earliest date first
        .orderBy('timeSlot', descending: false) // Sort by time if same date
        .limit(1) // Get the closest upcoming appointment
        .get();

    if (snapshot.docs.isEmpty) return null;

    return {
      'id': snapshot.docs.first.id,
      ...snapshot.docs.first.data() as Map<String, dynamic>,
    };
  } catch (e) {
    print("Error fetching closest appointment: $e");
    return null;
  }
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
        toolbarHeight: 80,
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
                                    backgroundImage: _userData!["photoURL"] !=
                                                null &&
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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

                      SizedBox(height: 10),

                      // Featured Section Placeholder
            ClipRRect(
  borderRadius: BorderRadius.circular(6),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Title outside the container but inside ClipRRect
      Padding(
        padding: const EdgeInsets.only(left: 7, bottom: 7),
        child: Text(
          "Coming Appointment",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      Container(
        height: 80,
        width: double.infinity,
         color: const Color(0xFFBBDEFB),// Light theme background
        padding: const EdgeInsets.all(7),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _getLatestAppointment(), // Fetch upcoming appointment
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("No upcoming appointments"));
            }

            final latest = snapshot.data!;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Subject & Notes
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latest['subject'] ?? "No subject",
                        style: TextStyle(fontSize: 18,
                       fontWeight: FontWeight.bold,),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        latest['notes'] ?? "No additional notes",
                        style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.bold,),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16), // Spacing between columns

                // Right Column: Date & Time
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        latest['date'] ?? "No date",
                        style: TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        latest['timeSlot'] ?? "No time",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ],
  ),
),

                      

                      // SizedBox(height: 10),



                      ClipRRect(
                        clipBehavior: Clip.none,
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "Your Courses →",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height:
                                    200, // Adjusted height for the new design
                                child: enrolledCourses.isEmpty
                                    ? Center(
                                        child: Text(
                                            "You haven't enrolled in any courses yet"))
                                    : StreamBuilder<QuerySnapshot>(
                                        stream: _firestore
                                            .collection('courses')
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return Center(
                                                child: Text(
                                                    "No courses available!"));
                                          }

                                          var allCourses = snapshot.data!.docs;
                                          var enrolledCourseDocs = allCourses
                                              .where((doc) => enrolledCourses
                                                  .contains(doc.id))
                                              .toList();

                                          if (enrolledCourseDocs.isEmpty) {
                                            return Center(
                                                child: Text(
                                                    "You haven't enrolled in any courses yet"));
                                          }

                                          enrolledCourseDocs.shuffle(Random());

                                          PageController pageController =
                                              PageController(
                                                  viewportFraction: 1.0);

                                          return SizedBox(
                                            width: double.infinity,
                                            child: PageView.builder(
                                              controller: pageController,
                                              physics: PageScrollPhysics(),
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  enrolledCourseDocs.length,
                                              itemBuilder: (context, index) {
                                                var data =
                                                    enrolledCourseDocs[index]
                                                            .data()
                                                        as Map<String, dynamic>;
                                                var courseId =
                                                    enrolledCourseDocs[index]
                                                        .id;

                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CourseDetail(
                                                          courseId: courseId,
                                                          userId: _auth
                                                              .currentUser!.uid,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.85,
                                                    height: 140,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),

                                                      // border: Border.all(
                                                      //   color: const Color.fromARGB(255, 39, 39, 39),
                                                      //   width: 1,
                                                      // ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black12,
                                                          blurRadius: 5,
                                                          spreadRadius: 2,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              14.0),
                                                      child: Row(
                                                        // Changed from Column to Row
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                            ),
                                                            child: data['imageUrl'] !=
                                                                        null &&
                                                                    data['imageUrl']
                                                                        .toString()
                                                                        .isNotEmpty
                                                                ? Image.network(
                                                                    data[
                                                                        'imageUrl'],
                                                                    width:
                                                                        150, // Adjusted width for better fit
                                                                    height: 140,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : Image.asset(
                                                                    'assets/images/mmBareLogo.png',
                                                                    width: 150,
                                                                    height: 140,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                  ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    data['title'] ??
                                                                        "No Title",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          5),
                                                                  Text(
                                                                    data['Author'] ??
                                                                        "Unknown Author",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .black87,
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
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      // Recommended Courses Section (DYNAMIC FROM FIRESTORE)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 270,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "Recommended Courses →",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 200, // Height for scrolling area
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: _firestore
                                      .collection('courses')
                                      .limit(10)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return Center(
                                          child: Text("No courses available!"));
                                    }

                                    var courseLists = snapshot.data!.docs;

                                    return ListView.builder(
                                      scrollDirection:
                                          Axis.horizontal, // Horizontal scroll
                                      itemCount: courseLists.length,
                                      itemBuilder: (context, index) {
                                        var data = courseLists[index].data()
                                            as Map<String, dynamic>;
                                        var courseId = courseLists[index].id;

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CourseDetail(
                                                  courseId: courseId,
                                                  userId:
                                                      _auth.currentUser!.uid,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 150,
                                            height: 210,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical:
                                                    10), // Add vertical margin
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: Offset(3,
                                                      3), // Only downward shadow
                                                ),
                                              ],
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                  ),
                                                  child:
                                                      data['imageUrl'] != null
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
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          data['title'] ??
                                                              "No Title",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          data['Author'] ??
                                                              "Unknown Author",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black87,
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
