import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'package:mindmate/message_detail.dart';

import 'package:rxdart/rxdart.dart';

class MessageListScreen extends StatefulWidget {
  MessageListScreen({super.key});
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class ConversationStream {
  static Stream<List<Map<String, dynamic>>> getConversations(String userId) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    Stream<QuerySnapshot> senderStream = firestore
        .collection('messages')
        .where('Receiver_Id', isEqualTo: userId)
        .orderBy('CreatedAt', descending: true)
        .snapshots();

    Stream<QuerySnapshot> authorStream = firestore
        .collection('messages')
        .where('Author_Id', isEqualTo: userId)
        .orderBy('CreatedAt', descending: true)
        .snapshots();

    return CombineLatestStream.combine2(
      senderStream,
      authorStream,
      (QuerySnapshot senderSnapshot, QuerySnapshot authorSnapshot) {
        // Merge results
        List<QueryDocumentSnapshot> allMessages = [
          ...senderSnapshot.docs,
          ...authorSnapshot.docs,
        ];

        // Create a map to store the most recent message for each conversation
        Map<String, Map<String, dynamic>> conversations = {};

        for (var doc in allMessages) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String authorId = data['Author_Id'] ?? '';
          String receiverId = data['Receiver_Id'] ?? '';

          // Determine the other user in the conversation
          String otherUserId = (authorId == userId) ? receiverId : authorId;

          // Create a conversation key that uniquely identifies this conversation
          // regardless of who is sender or receiver
          String conversationKey = {userId, otherUserId}.join('_');

          // If this conversation doesn't exist in our map yet, or if this message
          // is more recent than the one we have, update it
          if (!conversations.containsKey(conversationKey) ||
              (data['CreatedAt'] as Timestamp).compareTo(
                      conversations[conversationKey]!['CreatedAt']
                          as Timestamp) >
                  0) {
            // Add the otherUserId to the data map for easy reference
            data['otherUserId'] = otherUserId;
            data['documentId'] = doc.id;

            conversations[conversationKey] = data;
          }
        }

        // Convert map to list and sort by creation time
        List<Map<String, dynamic>> conversationList =
            conversations.values.toList();
        conversationList.sort((a, b) {
          Timestamp aTime = a['CreatedAt'] ?? Timestamp(0, 0);
          Timestamp bTime = b['CreatedAt'] ?? Timestamp(0, 0);
          return bTime.compareTo(aTime);
        });

        return conversationList;
      },
    );
  }
}

class _MessageListScreenState extends State<MessageListScreen> {
  final String user = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> users = [];
  String errorMessage = "";

  // Cache for user data to avoid redundant fetches
  final Map<String, Future<DocumentSnapshot>> _userCache = {};

  Future<List<Map<String, dynamic>>> getUsernames(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('uid', isNotEqualTo: userId)
              .get();

      // Add document ID to each module data
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id; // Add the document ID to the data
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching modules: $e");
      return [];
    }
  }

  Future<void> fetchUsers() async {
    try {
      List<Map<String, dynamic>> fetchedUsers = await getUsernames(user);
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      print("Error in fetchModules: $e");
      setState(() {
        errorMessage = "Failed to load usernames";
      });
    }
  }

  void _showNewMessageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double screenHeight = MediaQuery.of(context).size.height;

        return Align(
          alignment: Alignment.center,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: 350, // Adaptive width
              height: screenHeight * 0.5, // Adjust height based on screen
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose the recipient",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5DA1),
                      ),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: users.isEmpty
                          ? Center(
                              child: Text(
                                "No users available",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final userslist = users[index];
                                return Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      final user =
                                          FirebaseAuth.instance.currentUser;
                                      if (user != null &&
                                          userslist['id'] != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MessageDetail(
                                              authorId: user.uid,
                                              receiverId: userslist['id'],
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Unable to load users. Please try again.'),
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.blue[100],
                                            child: Icon(Icons.person,
                                                color: Colors.blue[700]),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              userslist['name'] ??
                                                  'Unknown User',
                                              style: TextStyle(
                                                fontSize: 18,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
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

  // Format timestamp to a readable date and time
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
      bottomNavigationBar: Bottombar(currentIndex: 0),
      appBar: AppBar(
        toolbarHeight: 80,
        // backgroundColor: const Color(0xFF2D5DA1),
        title: const Text(
          "Chats",
          style: TextStyle(
            fontSize: 25, // Adjusts the font size
            fontWeight: FontWeight.bold, // Makes the text bold
            color: Colors.black,
          ),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: ConversationStream.getConversations(user),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No conversations found"),
                );
              }

              var conversations = snapshot.data!;

              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  var data = conversations[index];

                  // Get the ID of the other user in the conversation
                  String otherUserId = data['otherUserId'];

                  // Determine if the current user is author or receiver of the latest message
                  bool isAuthor = user == data['Author_Id'];

                  String messageContent = data['message'] ?? "No content";
                  Timestamp createdAt = data['CreatedAt'] ?? Timestamp(0, 0);
                  String formattedTime = _formatTimestamp(createdAt);

                  return FutureBuilder<DocumentSnapshot>(
                    future: _getUserDetails(otherUserId),
                    builder: (context, userSnapshot) {
                      // Extract user name, handle loading and errors
                      String userName = "Loading...";

                      if (userSnapshot.connectionState ==
                          ConnectionState.done) {
                        userName = _extractUserName(userSnapshot.data);
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessageDetail(
                                    authorId: isAuthor ? user : otherUserId,
                                    receiverId: isAuthor ? otherUserId : user),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  userName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                formattedTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              // Show a send/receive icon
                              isAuthor
                                  ? const Icon(Icons.arrow_outward,
                                      size: 14, color: Colors.blue)
                                  : const Icon(Icons.arrow_downward,
                                      size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              // Show message preview
                              Expanded(
                                child: Text(
                                  messageContent,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
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
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewMessageDialog();
        },
        child: Icon(Icons.message),
      ),
    );
  }
}
