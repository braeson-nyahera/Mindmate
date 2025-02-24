import 'package:flutter/material.dart';
import 'package:mindmate/components.dart';
import 'package:mindmate/home.dart';

class CoursesList extends StatefulWidget {
  const CoursesList({super.key});

  @override
  State<CoursesList> createState() => _CoursesListState();
}

class _CoursesListState extends State<CoursesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'Available Courses'),
      drawer: DrawerWidget(),
    );
  }
}
