import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mindmate/discussion_detail.dart';

import 'package:mindmate/bottom_bar.dart';

class ForumsWidget extends StatefulWidget {
  ForumsWidget({super.key});

  final CollectionReference discussions =
      FirebaseFirestore.instance.collection('discussions');

  @override
  State<ForumsWidget> createState() => _ForumsWidgetState();
}
class _ForumsWidgetState extends State<ForumsWidget> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';


   // Function to show the dialog
 void _showNewDiscussionDialog() {
  showDialog(
    context: context,
    builder: (context) {
      // double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      return Transform.translate( // Moves the dialog upwards
        offset: Offset(0, -screenHeight * 0.19), 
      child:  Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          // height: 400,
          // width: 800,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Start a New Discussion",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D5DA1),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: "Enter your question...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _postDiscussion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5DA1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text("Post",style: TextStyle(color: Color(0XFFFFFFFF)),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ));
    },
  );
}


  // Function to post the question to Firestore
  Future<void> _postDiscussion() async {
    String question = _questionController.text.trim();

    if (question.isNotEmpty) {
      await widget.discussions.add({
        "question": question,
        "createdAt": FieldValue.serverTimestamp(),
      });

      _questionController.clear();
      Navigator.pop(context); // Close the dialog
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: "Search discussions...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(
                color: Color(0xFF2D5DA1),
                width: 0.5,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 0),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2D5DA1),
              ),
              child: IconButton(
                icon: Icon(Icons.add,color: Color(0xFFFFFFFF),),
                onPressed: _showNewDiscussionDialog,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Bottombar(currentIndex: 2),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.discussions.orderBy("createdAt", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No discussions yet!"));
          }

          var discussionsList = snapshot.data!.docs;

          // Filter the discussions based on the search query
          var filteredDiscussions = discussionsList.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String question = (data['question'] ?? '').toLowerCase();
            return question.contains(searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: filteredDiscussions.length,
            itemBuilder: (context, index) {
              var data = filteredDiscussions[index].data() as Map<String, dynamic>;
              var discussionId = filteredDiscussions[index].id;
              var dateTime = data["createdAt"]?.toDate() ?? DateTime.now();
              var timestamp = DateFormat('MMM d, yyyy \'at\' h:mm a').format(dateTime);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                       color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                        offset: const Offset(3, 3),
                    )
                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: 90,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiscussionDetail(discussionId: discussionId),
                          ),
                        );
                      },
                      title: Text(data['question'] ?? 'Cannot view the discussion question'),
                      subtitle: Text('Created at $timestamp'),
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
