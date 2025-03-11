import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/course_detail.dart';
import 'package:mindmate/bottom_bar.dart';

class CoursesList extends StatefulWidget {
  CoursesList({super.key});

  final CollectionReference courses =
      FirebaseFirestore.instance.collection('courses');

  @override
  State<CoursesList> createState() => _CoursesListState();
}

class _CoursesListState extends State<CoursesList> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth < 600 ? 0.7 : 0.9;
    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);
    // double aspectRatio = screenWidth < 600 ? 0.8 : 0.9; // Adjust size per device

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
      body: StreamBuilder<QuerySnapshot>(
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
            var courseTitle = (data['title'] ?? "").toString().toLowerCase();
            return courseTitle.contains(searchQuery);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Adjusted dynamically
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: aspectRatio,
              ),
              itemCount: courseLists.length,
              itemBuilder: (context, index) {
                var data = courseLists[index].data() as Map<String, dynamic>;
                var courseDoc = courseLists[index];
                var courseId = courseDoc.id;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetail(
                            courseId: courseId,
                            userId: FirebaseAuth.instance.currentUser!.uid),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2), // Shadow color with transparency
                            spreadRadius: 2, // How much the shadow spreads
                            blurRadius: 5, // Softness of the shadow
                            offset: Offset(3, 3), // Position: (X, Y)
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
                          child: data['imageUrl'] != null && data['imageUrl'].isNotEmpty
                              ? Image.network(
                                  data['imageUrl'],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                )
                              : Image.asset(
                                  'assets/images/holder.png', // Default image
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
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "By ${data['Author'] ?? 'Unknown'}",
                          style: TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
                          textAlign: TextAlign.left,
                        ),
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
