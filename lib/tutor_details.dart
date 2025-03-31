import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindmate/course_add.dart';

class TutorDetails extends StatefulWidget {
  const TutorDetails({super.key});

  @override
  State<TutorDetails> createState() => _TutorDetailsState();
}

class _TutorDetailsState extends State<TutorDetails> {
  late Future<Map<String, dynamic>?> _tutorData;
  late Future<List<Map<String, dynamic>>> _appointments;

  @override
  void initState() {
    super.initState();
    _tutorData = fetchTutorDetails();
  }

  Future<Map<String, dynamic>?> fetchTutorDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // Step 1: Fetch tutor details
    final tutorQuery = await FirebaseFirestore.instance
        .collection('tutors')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (tutorQuery.docs.isEmpty) return null;

    var tutorData = tutorQuery.docs.first.data();
    String tutorId = tutorQuery.docs.first.id;
    tutorData['id'] = tutorId;

    // Step 2: Fetch user name from users collection
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // tutorData['name'] = userDoc.exists ? userDoc.data()?['name'] ?? 'No Name' : 'No Name';
    if (userDoc.exists) {
      tutorData['name'] = userDoc.data()?['name'] ?? 'No Name';
    } else {
      tutorData['name'] = 'No Name';
    }

    // Step 3: Fetch appointments and attach student names
    _appointments = fetchAppointments(tutorId);

    return tutorData;
  }

  Future<List<Map<String, dynamic>>> fetchAppointments(String tutorId) async {
    final appointmentsQuery = await FirebaseFirestore.instance
        .collection('appointments')
        .where('tutorId', isEqualTo: tutorId)
        .get();

    List<Map<String, dynamic>> appointments = [];

    for (var doc in appointmentsQuery.docs) {
      var appointmentData = doc.data();
      String studentId = appointmentData['userId'];

      // Fetch student name from users collection
      final studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .get();

      String studentName = studentDoc.exists && studentDoc.data() != null
          ? (studentDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown'
          : 'Unknown';

      appointmentData['studentName'] = studentName;
      appointments.add(appointmentData);
    }

    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _tutorData,
        builder: (context, tutorSnapshot) {
          if (tutorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!tutorSnapshot.hasData || tutorSnapshot.data == null) {
            return const Center(child: Text("No tutor details found."));
          }

          var tutorData = tutorSnapshot.data!;

          return Container(
            // padding: const EdgeInsets.all(16.0),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFFFFFFF),  // Background color
            //     borderRadius: BorderRadius.circular(12),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black26,  // Shadow color
            //         blurRadius: 6,  // Softness of the shadow
            //         spreadRadius: 2,  // How much the shadow spreads
            //         offset: Offset(2, 4),  // Shadow position
            //       ),
            //     ],
            //   ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tutor Details Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20), // Space below
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF687B96),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black12, // Lighter color for a soft effect
                          blurRadius: 20, // Higher blur for a smooth fade
                          spreadRadius: 1, // Minimal spread to keep it subtle
                          offset: Offset(2, 2), // Gentle positioning
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tutor Name
                        Text(
                          "Tutor: ${tutorData['name'] ?? 'No Name'}",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),

                        const SizedBox(height: 10),

                        // Specialty
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Specialty: ",
                                style: TextStyle(
                                  fontSize: 19,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily:
                                      'Montserrat', // Use any custom font
                                ),
                              ),
                              TextSpan(
                                text: tutorData['specialty'] ?? 'Not specified',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subjects
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Subjects: ",
                                style: TextStyle(
                                  fontSize: 19,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              TextSpan(
                                text: tutorData['subjects'] != null
                                    ? (tutorData['subjects'] as List).join(', ')
                                    : 'Not specified',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Available Timings
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Available Timings:\n ",
                                style: TextStyle(
                                  fontSize: 19,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              TextSpan(
                                text: tutorData['timings'] != null
                                    ? (tutorData['timings'] as List).join(', ')
                                    : 'Not specified',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseCreationWidget(),
                          ),
                        );
                      },
                      icon: Icon(Icons.add)),

                  // Booked Appointments Title
                  const Text(
                    "Booked Appointments:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Appointments List
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _appointments,
                      builder: (context, appointmentSnapshot) {
                        if (appointmentSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!appointmentSnapshot.hasData ||
                            appointmentSnapshot.data!.isEmpty) {
                          return const Center(
                              child: Text("No appointments found."));
                        }

                        var appointments = appointmentSnapshot.data!;

                        return ListView.builder(
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            var appointment = appointments[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 12.0), // More horizontal spacing
                              elevation: 6, // Soft elevation
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12), // Rounded edges
                              ),
                              shadowColor: const Color.fromARGB(
                                  213, 0, 0, 0), // Soft shadow color
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.blue.shade50
                                    ], // Soft gradient background
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                padding: const EdgeInsets.all(
                                    12), // Internal padding
                                child: ListTile(
                                  title: Text(
                                    "Student: ${appointment['studentName']}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  subtitle: Text(
                                    "📅 Date: ${appointment['date'] ?? 'N/A'}\n"
                                    "⏰ Time: ${appointment['timeSlot'] ?? 'N/A'}\n"
                                    "📌 Status: ${appointment['status'] ?? 'Pending'}",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                  trailing: const Icon(Icons.calendar_today,
                                      color: Colors.blueAccent),
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
          );
        },
      ),
    );
  }
}
