import 'package:flutter/material.dart';
import 'package:mindmate/components.dart';
import 'package:mindmate/top_bar.dart';

class TutorsWidget extends StatefulWidget {
  const TutorsWidget({super.key});

  @override
  State<TutorsWidget> createState() => _TutorsWidgetState();
}

class _TutorsWidgetState extends State<TutorsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'Tutors'),
      drawer: DrawerWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('This is Tutors page')],
        ),
      ),
    );
  }
}
