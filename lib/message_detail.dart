import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageDetail extends StatefulWidget {
  const MessageDetail(
      {super.key, required this.authorId, required this.receiverId});

  final String authorId;
  final String receiverId;

  @override
  State<MessageDetail> createState() => _MessageDetailState();
}

class MessageStream {
  static Stream<List<QueryDocumentSnapshot>> getMessages(
      String authorId, String receiverId) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get messages where current user is either sender or receiver with the specific other person
    return firestore
        .collection('messages')
        .where(Filter.or(
          Filter.and(
            Filter('Author_Id', isEqualTo: authorId),
            Filter('Receiver_Id', isEqualTo: receiverId),
          ),
          Filter.and(
            Filter('Author_Id', isEqualTo: receiverId),
            Filter('Receiver_Id', isEqualTo: authorId),
          ),
        ))
        .orderBy('CreatedAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}

class _MessageDetailState extends State<MessageDetail> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Cache for user data to avoid redundant fetches
  final Map<String, Future<DocumentSnapshot>> _userCache = {};

  @override
  void initState() {
    super.initState();
  }

  // Fetch user details from Firestore
  Future<DocumentSnapshot> _getUserDetails(String userId) {
    // Check cache first
    if (!_userCache.containsKey(userId)) {
      _userCache[userId] = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .catchError((error) {
        return null;
      });
    }
    return _userCache[userId]!;
  }

  // Extract user name from document
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: _getUserDetails(widget.authorId == currentUserId
              ? widget.receiverId
              : widget.authorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...");
            }

            String userName = _extractUserName(snapshot.data);
            return Text(userName);
          },
        ),
      ),
      body: Column(children: [
        // Messages section
        Expanded(
          child: StreamBuilder<List<QueryDocumentSnapshot>>(
            stream:
                MessageStream.getMessages(widget.authorId, widget.receiverId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No messages found"),
                );
              }

              var messages = snapshot.data!;

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var data = messages[index].data() as Map<String, dynamic>;

                  // Determine if the current user is author or receiver
                  bool isAuthor = currentUserId == data['Author_Id'];

                  String createdAt =
                      (data['CreatedAt'] as Timestamp?)?.toDate().toString() ??
                          "Unknown time";

                  String messageContent = data['message'] ?? "No content";

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      // Position messages sent by current user to the right
                      leading: isAuthor
                          ? null
                          : CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Text(
                                "?",
                                style: TextStyle(
                                  color: Colors.green[800],
                                ),
                              ),
                            ),
                      trailing: isAuthor
                          ? CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                "Me",
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 10,
                                ),
                              ),
                            )
                          : null,
                      title: Text(
                        isAuthor ? "You" : "",
                        textAlign: isAuthor ? TextAlign.right : TextAlign.left,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: isAuthor
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  isAuthor ? Colors.blue[50] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(messageContent),
                          ),
                          SizedBox(height: 4),
                          Text(
                            createdAt,
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Message input field
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  // TODO: Implement sending message
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
