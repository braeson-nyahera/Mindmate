import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/module_detail.dart';
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
  bool hasError = false;
  String errorMessage = "";

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
      } else {
        setState(() {
          hasError = true;
          errorMessage = "Course not found";
        });
      }
    } catch (e) {
      print("Error fetching course: $e");
      setState(() {
        hasError = true;
        errorMessage = "Failed to load course details";
      });
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

      // Add document ID to each module data
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id; // Add the document ID to the data
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching modules: $e");
      return [];
    }
  }

  Future<void> fetchModules() async {
    try {
      List<Map<String, dynamic>> fetchedModules =
          await getModulesByCourse(widget.courseId);
      setState(() {
        modules = fetchedModules;
        isLoading = false;
      });
    } catch (e) {
      print("Error in fetchModules: $e");
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = "Failed to load modules";
      });
    }
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
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            hasError = false;
                          });
                          fetchCourseDetails();
                          fetchModules();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseData?['title'] ?? 'No title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Course Author: ${courseData?['Author'] ?? 'Unknown'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            courseData?['description'] ?? 'No description',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          textAlign: TextAlign.start,
                          'Modules',
                          style: TextStyle(
                            color: const Color(0xFF2D5DA1),
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                      ),
                    ),
                    modules.isEmpty
                        ? const Expanded(
                            child: Center(
                              child: Text(
                                "No modules found for this course",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: modules.length,
                              itemBuilder: (context, index) {
                                final module = modules[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child:DecoratedBox(decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                         color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                        offset: const Offset(2, 2),
                                 
                                      )
                                    ]
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: double.infinity,
                                      height: 90,
                                      color: const Color.from(alpha: 1, red: 1, green: 1, blue: 1),
                                      child: ListTile(
                                        onTap: () {
                                          final user =
                                              FirebaseAuth.instance.currentUser;
                                          if (user != null &&
                                              module['id'] != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ModuleDetail(
                                                  moduleId: module['id'],
                                                  userId: user.uid,
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Unable to open module. Please try again.'),
                                              ),
                                            );
                                          }
                                        },
                                        title: Text(module['title'] ??
                                            'Untitled Module',style: TextStyle(
                                              fontSize: 18,
                                              color: Color.fromARGB(255, 0, 0, 0)
                                            ),),
                                        subtitle: Text(
                                          module['description'] ??
                                              'No description',style: TextStyle(
                                                fontSize: 14,
                                                color: const Color.fromARGB(215, 0, 0, 0),
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                         trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                      ),
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
