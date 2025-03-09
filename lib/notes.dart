import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/components.dart';
import 'package:mindmate/top_bar.dart';

class NotesWidget extends StatefulWidget {
  NotesWidget({super.key});

  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'Notes'),
      drawer: DrawerWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('This is Notes page')],
        ),
      ),
    );
  }
}
