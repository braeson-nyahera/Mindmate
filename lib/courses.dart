import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/components.dart';
import 'package:mindmate/top_bar.dart';

class CoursesList extends StatefulWidget {
  CoursesList({super.key});

  final CollectionReference courses =
      FirebaseFirestore.instance.collection('courses');

  @override
  State<CoursesList> createState() => _CoursesListState();
}

class _CoursesListState extends State<CoursesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'Available Courses'),
      drawer: DrawerWidget(),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.courses.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No courses yet!"));
          }

          var courseLists = snapshot.data!.docs;

          return ListView.builder(
            itemCount: courseLists.length,
            itemBuilder: (context, index) {
              var data = courseLists[index].data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    color: const Color.fromARGB(255, 110, 185, 223),
                    child: ListTile(
                      minTileHeight: 25,
                      hoverColor: const Color.fromARGB(255, 92, 198, 227),
                      title: Text(data['title'] ?? 'No message'),
                      subtitle: Text('Authored by ${data["Author"]}'),
                    ),
                  ),
                ),
              );
            },
          );
        },
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [Text('Courses page')],
        // ),
      ),
    );
  }
}
