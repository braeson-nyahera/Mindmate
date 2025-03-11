import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindmate/components.dart';
import 'package:mindmate/discussion_detail.dart';
import 'package:mindmate/top_bar.dart';
import 'package:mindmate/bottom_bar.dart';

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
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.discussions.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No discussions yet!"));
          }

          var discussionsList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: discussionsList.length,
            itemBuilder: (context, index) {
              var data = discussionsList[index].data() as Map<String, dynamic>;
              var discussionDoc = discussionsList[index];
              var discussionId = discussionDoc.id;
              var dateTime = data["createdAt"].toDate();
              var timestamp =
                  DateFormat('MMM d, yyyy \'at\' h:mm a').format(dateTime);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    color: const Color.fromARGB(255, 110, 185, 223),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DiscussionDetail(discussionId: discussionId),
                          ),
                        );
                      },
                      minTileHeight: 25,
                      hoverColor: const Color.fromARGB(255, 92, 198, 227),
                      title: Text(data['question'] ??
                          'Cannot view the discussion question'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Created at $timestamp'),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
