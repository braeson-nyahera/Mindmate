import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/course_detail.dart';
import 'package:mindmate/bottom_bar.dart';

class CoursesList extends StatefulWidget {
  CoursesList({super.key});
  final CollectionReference enrolls =
      FirebaseFirestore.instance.collection('enrolls');

  final CollectionReference courses =
      FirebaseFirestore.instance.collection('courses');

  @override
  State<CoursesList> createState() => _CoursesListState();
}

class _CoursesListState extends State<CoursesList> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  // Store enrolled course IDs for current user
  Set<String> enrolledCourses = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEnrolledCourses();
  }

  // Fetch all courses the current user has enrolled in
  Future<void> fetchEnrolledCourses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Get a direct reference to the enrolls collection
      final enrollsRef = FirebaseFirestore.instance.collection('enrolls');

      // Query all enrollments for this user - VERIFY FIELD NAMES!
      final QuerySnapshot enrollSnapshot =
          await enrollsRef.where('user', isEqualTo: userId).get();

      // Extract course IDs from enrollment documents
      final Set<String> enrolledIds = enrollSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // VERIFY the field name you use for course ID!
        return data['course'] as String;
      }).toSet();

      setState(() {
        enrolledCourses = enrolledIds;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth < 600 ? 0.7 : 0.9;
    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: "Search courses...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(
                color: Color(0xFF2D5DA1),
                width: 0.5,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
      bottomNavigationBar: Bottombar(currentIndex: 1),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: widget.courses.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No courses yet!"));
                }

                var courseLists = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  var courseTitle =
                      (data['title'] ?? "").toString().toLowerCase();
                  return courseTitle.contains(searchQuery);
                }).toList();

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: aspectRatio,
                    ),
                    itemCount: courseLists.length,
                    itemBuilder: (context, index) {
                      var data =
                          courseLists[index].data() as Map<String, dynamic>;
                      var courseDoc = courseLists[index];
                      var courseId = courseDoc.id;
                      bool isEnrolled = enrolledCourses.contains(courseId);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetail(
                                  courseId: courseId,
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(3, 3),
                              ),
                            ],
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: data['imageUrl'] != null &&
                                        data['imageUrl'].isNotEmpty
                                    ? Image.network(
                                        data['imageUrl'],
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.fill,
                                      )
                                    : Image.asset(
                                        'assets/images/holder.png',
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.fill,
                                      ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                data['title'] ?? 'No Title',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 0, 0, 0)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "By ${data['Author'] ?? 'Unknown'}",
                                style: TextStyle(
                                    color: const Color.fromARGB(179, 0, 0, 0)),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 5),
                              isEnrolled
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 52, 152, 219),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      width: 80,
                                      height: 30,
                                      child: Center(
                                        child: Text(
                                          "Enrolled",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        try {
                                          // VERIFY field names match exactly what you check for
                                          await widget.enrolls.add({
                                            'course':
                                                courseId, // Must match field name in query
                                            'user': FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid, // Must match field name in query
                                            'time_enrolled': Timestamp.now(),
                                          });

                                          // Update local state to reflect new enrollment
                                          setState(() {
                                            enrolledCourses.add(courseId);
                                          });

                                          // Show success message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Successfully enrolled in course!')),
                                          );
                                        } catch (e) {
                                          print('Error enrolling: $e');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to enroll: $e')),
                                          );
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 48, 208, 64),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        width: 60,
                                        height: 30,
                                        child: Center(
                                          child: Text(
                                            "Enroll",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
