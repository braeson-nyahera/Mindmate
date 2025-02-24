import 'package:flutter/material.dart';
import 'package:mindmate/components.dart';
import 'package:mindmate/home.dart';

class NotesWidget extends StatefulWidget {
  const NotesWidget({super.key});

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'Notes'),
      drawer: DrawerWidget(),
    );
  }
}
