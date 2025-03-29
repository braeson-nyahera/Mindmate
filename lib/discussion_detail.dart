import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DiscussionDetail extends StatefulWidget {
  DiscussionDetail({super.key, required this.discussionId});
  final String discussionId;
  final CollectionReference comments =
      FirebaseFirestore.instance.collection('comments'); // Fixed typo here

  @override
  State<DiscussionDetail> createState() => _DiscussionDetailState();
}

class _DiscussionDetailState extends State<DiscussionDetail> {
  Map<String, dynamic>? discussionData;
  List<Map<String, dynamic>> comments = [];
  bool hasError = false;
  String errorMessage = '';
  bool isLoading = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDiscussionQuestion();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> fetchDiscussionQuestion() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> discussionSnapshot =
          await FirebaseFirestore.instance
              .collection('discussions')
              .doc(widget.discussionId)
              .get();

      if (discussionSnapshot.exists) {
        setState(() {
          discussionData = discussionSnapshot.data();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = "Discussion not found";
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching discussion: $e");
      setState(() {
        hasError = true;
        errorMessage = "Failed to load discussion details";
        isLoading = false;
      });
    }
  }

  Future<void> addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await widget.comments.add({
        'comment': _commentController.text,
        'discussion_id': widget.discussionId,
        'createdAt': FieldValue.serverTimestamp(),
        'Author': FirebaseAuth.instance.currentUser!.uid,
        // Add user info here if needed
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Comment added!'),
        )),
      );
      _commentController.clear();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    }
  }

  String _extractUserName(DocumentSnapshot? doc) {
    if (doc == null || !doc.exists) {
      return "Unknown User";
    }

    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return "No Data";

      // Try different possible field names for user name
      final String? name = data['name'] ??
          data['displayName'] ??
          data['fullName'] ??
          data['username'] ??
          data['user_name'];

      if (name != null && name.isNotEmpty) {
        return name;
      } else {
        return "Unnamed User";
      }
    } catch (e) {
      return "Error";
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';

    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            hasError = false;
                          });
                          fetchDiscussionQuestion();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Discussion question card
                 SizedBox(
                    width: double.infinity, // Makes it take the full width
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      child: Card(
                        color: Colors.transparent, 
                        elevation: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              
                              
                              child: Text(
                                discussionData?['question'] ?? 'Error accessing the discussion question',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),



                    // Comments section
                   Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('comments')
                            .where('discussion_id', isEqualTo: widget.discussionId)
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && comments.isEmpty) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text("No comments yet!"));
                          }

                          var docs = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              var data = docs[index].data() as Map<String, dynamic>;

                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(data['Author'])
                                    .get(),
                                builder: (context, userSnapshot) {
                                  String userName = "Loading...";
                                  String timeString = "";

                                  if (userSnapshot.connectionState == ConnectionState.done) {
                                    userName = _extractUserName(userSnapshot.data);
                                  }

                                  Timestamp? timestamp = data['createdAt'] as Timestamp?;
                                  timeString = _formatTimestamp(timestamp);

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    child: ListTile(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            userName,
                                            style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 79, 79, 79)),
                                          ),
                                          Text(
                                            timeString,
                                            style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 79, 79, 79)),
                                          ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4), 
                                        child: Text(
                                          data['comment'] ?? 'No comment' ,
                                          textAlign: TextAlign.left, style: TextStyle(fontSize: 15,color: const Color.fromARGB(255, 0, 0, 0)),
                                          
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Comment input field
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: 'Add a comment...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: addComment,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
