import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/components.dart';
import 'package:mindmate/top_bar.dart';

class ForumsWidget extends StatefulWidget {
  ForumsWidget({super.key});

  final CollectionReference discussions =
      FirebaseFirestore.instance.collection('discussions');

  @override
  State<ForumsWidget> createState() => _ForumsWidgetState();
}

class _ForumsWidgetState extends State<ForumsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'Discussion Forum'),
      drawer: DrawerWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('This is a forum page')],
        ),
      ),
    );
  }
}
