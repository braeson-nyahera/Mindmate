import 'package:flutter/material.dart';
import 'package:mindmate/bottom_bar.dart';
import 'package:mindmate/tutor_registration.dart';
import 'package:mindmate/tutor_details.dart';
import 'package:mindmate/users/authservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mindmate/course_detail.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final AuthService authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Set<String> enrolledCourses = {};
  List<Map<String, dynamic>> userAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
    fetchEnrolledCourses();
    fetchUserAppointments();
  }

  Future<void> _getUserData() async {
    try {
      var user = authService.getCurrentUser(); // Fetch user data
      if (user != null) {
        setState(() {
          _userData = {
            "name": user.displayName ?? "Unknown",
            "email": user.email ?? "No Email",
            "photoURL": user.photoURL ?? "",
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text("Log out of your Account?", style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(fontSize: 15)),
            ),
            TextButton(
              onPressed: () {
                authService.signOut();
                Navigator.pushReplacementNamed(context, '/landing_page');
              },
              child: Text("Logout",
                  style: TextStyle(color: Colors.red, fontSize: 15)),
            ),
          ],
        );
      },
    );
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





Future<void> fetchUserAppointments() async {
  setState(() {
    isLoading = true;
  });

  try {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final now = DateTime.now(); // Current date and time

    // Query all appointments for this user, ordered by date in descending order
    final QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    List<Map<String, dynamic>> filteredAppointments = [];

    for (var doc in appointmentsSnapshot.docs) {
      final appointmentData = doc.data() as Map<String, dynamic>;
      final appointmentDate = DateFormat('yyyy-MM-dd').parse(appointmentData['date']);
      final appointmentTimeSlot = appointmentData['timeSlot'];

      // Combine date and time to create a full DateTime for comparison
      DateTime appointmentDateTime;

      // Parse the time slot and create a full DateTime object
      try {
        final timeFormat = DateFormat('HH:mm'); // Adjust format as needed
        final parsedTime = timeFormat.parse(appointmentTimeSlot);
        appointmentDateTime = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      } catch (e) {
        print('Error parsing time slot: $e');
        // If time parsing fails, exclude the appointment (or handle differently)
        continue;
      }

      // Check if the appointment is in the future
      if (appointmentDateTime.isAfter(now)) {
        filteredAppointments.add({
          'id': doc.id,
          ...appointmentData,
          'appointmentDateTime': appointmentDateTime, // Add for sorting
        });
      }
    }

    // Sort the filtered appointments by appointmentDateTime in ascending order
    filteredAppointments.sort((a, b) =>
        (a['appointmentDateTime'] as DateTime).compareTo(b['appointmentDateTime'] as DateTime));

    // Remove the appointmentDateTime field after sorting (if not needed)
    filteredAppointments.forEach((appointment) {
      appointment.remove('appointmentDateTime');
    });

    setState(() {
      userAppointments = filteredAppointments;
      isLoading = false;
    });

    print('User appointments: $userAppointments'); // Debug print
  } catch (e) {
    print('Error fetching user appointments: $e');
    setState(() {
      isLoading = false;
    });
  }
}
  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    DateTime appointmentDate =
        appointment['appointmentDate']?.toDate() ?? DateTime.now();
    String formattedDate =
    "${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}";
    // String formattedTime =
    //     "${appointmentDate.hour}:${appointmentDate.minute.toString().padLeft(2, '0')}";
    final Future<QuerySnapshot<Map<String, dynamic>>> tutor = FirebaseFirestore
        .instance
        .collection('users')
        .where('uid', isEqualTo: appointment['tutorId'])
        .get();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: tutor,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text("Loading..."),
                content: Center(child: CircularProgressIndicator()),
              );
            }
            final timeSlot = appointment['timeSlot'];
            final date = appointment['date'];

            final tutorName = snapshot.hasData && snapshot.data!.docs.isNotEmpty
                ? snapshot.data!.docs[0].data()['name'] ?? 'Unknown'
                : 'Unknown';
            return AlertDialog(
              title: Text("Appointment Details"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Tutor: ${tutorName ?? 'Unknown'}"),
                    SizedBox(height: 8),
                    Text("Date: $date"),
                    SizedBox(height: 4),
                    Text("Time: $timeSlot"),
                    SizedBox(height: 8),
                    Text(
                        "Course: ${appointment['subject'] ?? 'Not specified'}"),
                    SizedBox(height: 8),
                    Text("Status: ${appointment['status'] ?? 'pending'}"),
                    SizedBox(height: 8),
                    if (appointment['notes'] != null &&
                        appointment['notes'].isNotEmpty)
                      Text("Notes: ${appointment['notes']}"),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close"),
                ),
                if (appointment['status'] != 'cancelled')
                  TextButton(
                    onPressed: () {
                      _cancelAppointment(appointment['id']);
                      Navigator.pop(context);
                    },
                    child: Text("Cancel Appointment",
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _cancelAppointment(String appointmentId) async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("User not authenticated");

    // Fetch appointment details
    final appointmentDoc = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .get();

    if (!appointmentDoc.exists) throw Exception("Appointment not found");

    final appointmentData = appointmentDoc.data() as Map<String, dynamic>;

    // Get tutor info
    final tutorDoc = await FirebaseFirestore.instance
        .collection('tutors')
        .doc(appointmentData['tutorId'])
        .get();

    String tutorName = "Unknown Tutor";
    if (tutorDoc.exists) {
      final tutorData = tutorDoc.data() as Map<String, dynamic>;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(tutorData['userId'])
          .get();
      if (userDoc.exists) {
        tutorName = userDoc.data()?['name'] ?? "Unknown Tutor";
      }
    }

    // Update appointment status to "cancelled"
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': 'cancelled'});

    // Create a cancellation notification
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'message':
          "Your appointment with $tutorName on ${appointmentData['date']} at ${appointmentData['timeSlot']} has been cancelled.",
      'timestamp': Timestamp.now(),
    });

    // Refresh the appointment list
    fetchUserAppointments();

    print("Appointment successfully cancelled.");
  } catch (e) {
    print("Error cancelling appointment: $e");
  }
}

  

  Widget _buildAppointmentsSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 277,
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "My Appointments →",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: userAppointments.isEmpty
                  ? Center(
                      child: Text("You don't have any scheduled appointments"))
                  : ListView.builder(
                      itemCount: userAppointments.length,
                      itemBuilder: (context, index) {
                        var appointment = userAppointments[index];

                        // Convert Firestore timestamp to DateTime
                        // DateTime appointmentDate =
                        //     appointment['appointmentDate']?.toDate() ??
                        //         DateTime.now();
                        // String formattedDate =
                        //     "${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}";
                        // String formattedTime =
                        //     "${appointmentDate.hour}:${appointmentDate.minute.toString().padLeft(2, '0')}";
                        final date = appointment['date'];
                        final time = appointment['timeSlot'];
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color.fromARGB(255, 39, 39, 39),
                              width: 0.5,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFF2D5DA1),
                              child: Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              appointment['tutorName'] ?? "Unknown Tutor",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date: $date"),
                                Text("Time: $time"),
                                Text(
                                    "Course: ${appointment['subject'] ?? 'Not specified'}"),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: appointment['status'] == 'confirmed'
                                    ? Colors.green.shade100
                                    : appointment['status'] == 'pending'
                                        ? Colors.orange.shade100
                                        : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                appointment['status'] ?? "pending",
                                style: TextStyle(
                                  color: appointment['status'] == 'confirmed'
                                      ? Colors.green.shade800
                                      : appointment['status'] == 'pending'
                                          ? Colors.orange.shade800
                                          : Colors.red.shade800,
                                ),
                              ),
                            ),
                            onTap: () {
                              _showAppointmentDetails(appointment);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 45, 93, 161),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Color(0xFFFFFFFF),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      bottomNavigationBar: Bottombar(currentIndex: 4),
      body: _isLoading || isLoading
          ? Center(child: CircularProgressIndicator())
          : _userData == null
              ? Center(child: Text("No user data found"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                   
                      ClipRRect(
                              borderRadius: BorderRadius.circular(0),
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF2D5DA1),
                                  const Color.fromARGB(255, 255, 255, 255),
                                ],
                              ),
                                  borderRadius: BorderRadius.circular(0),
                                  // border: Border(
                                  //   bottom: BorderSide(
                                  //     color:
                                  //         const Color.fromARGB(255, 39, 39, 39),
                                  //     width: 0.5,
                                  //   ),
                                  // ),
                                ),
                                // width: double.infinity,
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
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
                                          child: _userData!["photoURL"] ==
                                                      null ||
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
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                              ),
                                              Text(
                                                "${_userData!['email']}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: const Color.fromARGB(
                                                      179, 0, 0, 0),
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
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 250,
                                margin: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  //  color: const Color.fromARGB(255, 251, 0, 0)
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        "My Courses →",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 200,
                                    
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
                                                    snapshot
                                                        .data!.docs.isEmpty) {
                                                  return Center(
                                                      child: Text(
                                                          "No courses available!"));
                                                }

                                                // Filter courses to only show enrolled ones
                                                var allCourses =
                                                    snapshot.data!.docs;
                                                var enrolledCourseDocs =
                                                    allCourses
                                                        .where((doc) =>
                                                            enrolledCourses
                                                                .contains(
                                                                    doc.id))
                                                        .toList();

                                                if (enrolledCourseDocs
                                                    .isEmpty) {
                                                  return Center(
                                                      child: Text(
                                                          "You haven't enrolled in any courses yet"));
                                                }

                                                return ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount:
                                                      enrolledCourseDocs.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var data =
                                                        enrolledCourseDocs[
                                                                    index]
                                                                .data()
                                                            as Map<String,
                                                                dynamic>;
                                                    var courseId =
                                                        enrolledCourseDocs[
                                                                index]
                                                            .id;

                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                CourseDetail(
                                                              courseId:
                                                                  courseId,
                                                              userId: _auth
                                                                  .currentUser!
                                                                  .uid,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        width: 140,
                                                        height: 220,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                              boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.black12,
                                                                    blurRadius: 5,
                                                                    spreadRadius: 2,
                                                                  ),
                                                                ],
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.circular(8),
                                                                //  border:Border.all(
                                                                //   color: const Color .fromARGB(  255, 39, 39,39),
                                                                //   width: 1,

                                                                // )
                                                                ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius .only(
                                                                    topLeft: Radius.circular(
                                                                        10),
                                                                    topRight: Radius.circular(10),
                                                              ),
                                                              child: data['imageUrl'] !=
                                                                          null &&
                                                                      data['imageUrl']
                                                                          .toString()
                                                                          .isNotEmpty
                                                                  ? Image
                                                                      .network(
                                                                      data[
                                                                          'imageUrl'],
                                                                      width:
                                                                          140,
                                                                      height:
                                                                          110,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : Image.asset(
                                                                      'assets/images/mmBareLogo.png',
                                                                      width:
                                                                          140,
                                                                      height:
                                                                          110,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                    ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      data['title'] ??
                                                                          "No Title",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    Text(
                                                                      data['Author'] ??
                                                                          "Unknown Author",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
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
                            // Add the appointments section here
                            _buildAppointmentsSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => TutorRegistrationForm(),
      //       ),
      //     );
      //   },
      //   label: const Text(
      //     "Become a Tutor",
      //     style: TextStyle(
      //       color: Color.fromARGB(255, 135, 61, 61),
      //       fontWeight: FontWeight.bold,
      //       fontSize: 14,
      //     ),
      //   ),
      //   icon: const Icon(Icons.border_color_outlined),
      // ),
     floatingActionButton: FutureBuilder(
  future: FirebaseFirestore.instance
      .collection('tutors')
      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const FloatingActionButton.extended(
        onPressed: null,
        label: Text("Loading..."),
        icon: Icon(Icons.hourglass_empty),
      );
    }

    bool isTutor = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

    return FloatingActionButton.extended(
      onPressed: () async {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in first.')),
          );
          return;
        }

        if (isTutor) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TutorDetails()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TutorRegistrationForm()),
          );
        }
      },
      label: Text(
        isTutor ? "View Tutor Profile" : "Become a Tutor",
        style: const TextStyle(
          color: Color.fromARGB(255, 135, 61, 61),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      icon: Icon(isTutor ? Icons.person : Icons.border_color_outlined),
    );
  },
),


    );
  }
}
