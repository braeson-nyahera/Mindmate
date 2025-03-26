import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageDetail extends StatefulWidget {
  MessageDetail({super.key, required this.authorId, required this.receiverId});
  final CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');

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
  final TextEditingController _messageController = TextEditingController();

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
        // ignore: invalid_return_type_for_catch_error
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

  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();

    if (message.isNotEmpty) {
      await widget.messages.add({
        "message": message,
        "CreatedAt": FieldValue.serverTimestamp(),
        "Author_Id": FirebaseAuth.instance.currentUser!.uid,
        "Receiver_Id": widget.receiverId,
      });

      _messageController.clear();
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown time";

    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();

    // If it's today, just show the time
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }

    // If it's yesterday, show "Yesterday"
    DateTime yesterday = now.subtract(const Duration(days: 1));
    if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return "Yesterday";
    }

    // Otherwise show the date
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
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
                  bool isAuthor = currentUserId == data['Author_Id'];
                  String createdAt = _formatTimestamp(data['CreatedAt']);
                  String messageContent = data['message'] ?? "No content";

                  print(
                      "Message: ${data['message']}, isAuthor: $isAuthor, Author_Id: ${data['Author_Id']},Receiver_Id: ${data['Receiver_Id']}, currentUserId: $currentUserId");

                  // Check if the next message is from a different sender
                  bool isLastFromUser = index == messages.length - 1 ||
                      (messages[index + 1].data()
                              as Map<String, dynamic>)['Author_Id'] !=
                          data['Author_Id'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisAlignment:
                          isAuthor ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        // Avatar for received messages (including invisible placeholders)
                        if (!isAuthor)
                          Opacity(
                            opacity: isLastFromUser ? 1.0 : 0.0, // Show only for last message
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.green[100],
                              child: Text(
                                "?",
                                style: TextStyle(color: Colors.green[800]),
                              ),
                            ),
                          ),

                        if (!isAuthor) const SizedBox(width: 8),

                        // Chat Bubble
                        Container(
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxWidth: 250),
                          decoration: BoxDecoration(
                            color: isAuthor ? Colors.blue[100] : const Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isAuthor
                                  ? const Radius.circular(12)
                                  : const Radius.circular(0),
                              bottomRight: isAuthor
                                  ? const Radius.circular(0)
                                  : const Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                messageContent,
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                createdAt,
                                style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),

                        if (isAuthor) const SizedBox(width: 8),

                        // Avatar for sent messages (including invisible placeholders)
                        if (isAuthor)
                          Opacity(
                            opacity: isLastFromUser ? 1.0 : 0.0, // Show only for last message
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                "Me",
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
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
                  controller: _messageController,
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
                  _sendMessage();
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
