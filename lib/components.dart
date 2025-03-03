import 'package:flutter/material.dart';
import 'package:mindmate/courses.dart';
import 'package:mindmate/firebase_test.dart';
import 'package:mindmate/forum.dart';
import 'package:mindmate/home.dart';
import 'package:mindmate/notes.dart';
import 'package:mindmate/tutors.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Drawer(
        width: 120,
        child: ListView(
          children: [
            SizedBox(
              height: 65,
              child: const DrawerHeader(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 127, 194, 225)),
                child: Text('Mindmate'),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(2, 0, 2, 0),
              leading: Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      title: 'Home',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(2, 0, 2, 0),
              leading: Icon(Icons.library_add_check_rounded),
              title: const Text('Courses'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoursesList()),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(2, 0, 2, 0),
              leading: Icon(Icons.my_library_books),
              title: const Text('Notes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotesWidget()),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(2, 0, 2, 0),
              leading: Icon(Icons.person_3_outlined),
              title: const Text('Tutor'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TutorsWidget()),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(2, 0, 2, 0),
              leading: Icon(Icons.group_rounded),
              title: const Text('Forum'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForumsWidget()),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(2, 0, 2, 0),
              leading: Icon(Icons.group_rounded),
              title: const Text('Firebase_Test'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FirestoreListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
