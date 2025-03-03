import 'package:flutter/material.dart';
import 'package:mindmate/components.dart';
import 'package:mindmate/top_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'Home'),
      drawer: DrawerWidget(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.amber,
                    child: SizedBox(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(size: 64, Icons.person),
                          ),
                          Center(
                            child: SizedBox(
                              width: 300,
                              child: Column(children: [
                                Text(
                                  'This is home',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Email is here')
                              ]),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
