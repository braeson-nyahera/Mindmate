import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/top_bar.dart';

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
          await FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.courseId)
              .get();

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
    List<Map<String, dynamic>> fetchedModules =
        await getModulesByCourse(widget.courseId);
    setState(() {
      modules = fetchedModules;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: courseData?['title'] ?? 'Course Page'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : modules.isEmpty
              ? const Center(child: Text("No modules found"))
              : Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 20,
                      child: Text(courseData?['title'] ?? 'No title'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                color: const Color.fromARGB(255, 110, 185, 223),
                                child: ListTile(
                                  title: Text(modules[index]['title']),
                                  subtitle: Text(modules[index]
                                          ['description'] ??
                                      'No description'),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
