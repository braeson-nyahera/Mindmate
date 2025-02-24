import 'package:flutter/material.dart';
import 'package:mindmate/components.dart';
import 'package:mindmate/top_bar.dart';

class ForumsWidget extends StatefulWidget {
  const ForumsWidget({super.key});

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
