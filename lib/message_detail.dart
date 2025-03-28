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
  final ScrollController _scrollController = ScrollController();

  // Cache for user data to avoid redundant fetches
  final Map<String, Future<DocumentSnapshot>> _userCache = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

   void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
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

      Future.delayed(Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0.0,
        title: FutureBuilder<DocumentSnapshot>(
          future: _getUserDetails(widget.authorId == currentUserId
              ? widget.receiverId
              : widget.authorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...");
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Text("Unknown User");
            }

            String userName = _extractUserName(snapshot.data);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, color: Colors.blue[700]),
                ),
                SizedBox(width: 8), 
                Text(userName, style: TextStyle(color: Colors.black)),
              ],
            );
          },
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: MessageStream.getMessages(widget.authorId, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No messages found"));
                }

                var messages = snapshot.data!;
                messages = messages.reversed.toList(); // Reverse the messages list

                return ListView.builder(
                  controller: _scrollController, 
                  reverse: true, // Make the list start from the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var data = messages[index].data() as Map<String, dynamic>;
                    bool isAuthor = currentUserId == data['Author_Id'];
                    String createdAt = _formatTimestamp(data['CreatedAt']);
                    String messageContent = data['message'] ?? "No content";
                    
      //               bool isLastFromUser = index == messages.length - 1 ||
      // (messages[index + 1].data() as Map<String, dynamic>)['Author_Id'] != data['Author_Id'];

 bool isLastFromUser = index == 0 ||  // First item in reversed list (latest message)
      (messages[index - 1].data() as Map<String, dynamic>)['Author_Id'] != data['Author_Id'];

                    return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  child: Row(
    mainAxisAlignment: isAuthor ? MainAxisAlignment.end : MainAxisAlignment.start,
    children: [
      // Receiver avatar (only visible if it's the last message from that user)
      Opacity(
        opacity: !isAuthor && isLastFromUser ? 1.0 : 0.0,
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.green[100],
          child: Text(
            "?",
            style: TextStyle(color: Colors.green[800]),
          ),
        ),
      ),
      if (!isAuthor) SizedBox(width: 8),

      // Chat Bubble
      Container(
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isAuthor ? Colors.blue[100] : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isAuthor ? Radius.circular(12) : Radius.circular(0),
            bottomRight: isAuthor ? Radius.circular(0) : Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              messageContent,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 4),
            Text(
              createdAt,
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          ],
        ),
      ),

      if (isAuthor) SizedBox(width: 8),

      // Author avatar (only visible if it's the last message from the author)
      Opacity(
        opacity: isAuthor && isLastFromUser ? 1.0 : 0.0,
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

