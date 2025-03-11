import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/bottom_bar.dart';

class CourseDetail extends StatefulWidget {
  const CourseDetail({super.key, required this.courseId, required this.userId});
  final String courseId;
  final String userId;

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  Map<String, dynamic>? courseData;
  List<Map<String, dynamic>> modules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourseDetails();
    fetchModules();
  }

  /// Fetch course details
  Future<void> fetchCourseDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> courseSnapshot =
          await FirebaseFirestore.instance.collection('courses').doc(widget.courseId).get();

      if (courseSnapshot.exists) {
        setState(() {
          courseData = courseSnapshot.data();
        });
      }
    } catch (e) {
      print("Error fetching course: $e");
    }
  }

  /// Fetch all modules linked to this course
  Future<List<Map<String, dynamic>>> getModulesByCourse(String courseId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('modules')
              .where('course_id', isEqualTo: courseId)
              .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching modules: $e");
      return [];
    }
  }

  Future<void> fetchModules() async {
    List<Map<String, dynamic>> fetchedModules = await getModulesByCourse(widget.courseId);
    setState(() {
      modules = fetchedModules;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title: Text(
          courseData?['title'] ?? 'Course',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      bottomNavigationBar: Bottombar(currentIndex: 5),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : modules.isEmpty
              ? const Center(child: Text("No modules found"))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Course Title Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          courseData?['title'] ?? 'No title',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// Modules List
                      Expanded(
                        child: ListView.builder(
                          
                          itemCount: modules.length,
                          itemBuilder: (context, index) {
                            return Padding(
                            
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DecoratedBox(
                                decoration :BoxDecoration(
                                boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                        offset: const Offset(3, 3),
                                      ),
                                    ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(
                                      modules[index]['title'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    subtitle: Text(
                                      modules[index]['description'] ?? 'No description',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Colors.black54,
                                    ),
                                    onTap: () {
                                      

                                    },
                                  ),
                                ),
                              ),
                            )
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
