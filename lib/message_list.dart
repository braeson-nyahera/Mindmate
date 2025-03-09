import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/components.dart';
import 'package:mindmate/message_detail.dart';
import 'package:mindmate/top_bar.dart';
import 'package:rxdart/rxdart.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class MessageStream {
  static Stream<List<QueryDocumentSnapshot>> getMessages(String userId) {
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
        // Merge results and sort by 'CreatedAt'
        List<QueryDocumentSnapshot> mergedDocs = [
          ...senderSnapshot.docs,
          ...authorSnapshot.docs,
        ];

        mergedDocs.sort((a, b) {
          Timestamp aTime = a['CreatedAt'] ?? Timestamp(0, 0);
          Timestamp bTime = b['CreatedAt'] ?? Timestamp(0, 0);
          return bTime.compareTo(aTime);
        });

        return mergedDocs;
      },
    );
  }
}

class _MessageListScreenState extends State<MessageListScreen> {
  final String user = FirebaseAuth.instance.currentUser!.uid;

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
      appBar: TopBar(title: 'Messages'),
      drawer: DrawerWidget(),
      body: Column(children: [
        // Discussion question card
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Card(
        //     elevation: 4,
        //     child: Padding(
        //       padding: const EdgeInsets.all(16.0),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           const Text(
        //             'Messages',
        //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),

        // Comments section
        Expanded(
          child: StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: MessageStream.getMessages(user),
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
                  bool isAuthor = user == data['Author_Id'];

                  // Get ID of the other user to fetch their name
                  String otherUserId = isAuthor
                      ? data['Receiver_Id'] ?? "Unknown"
                      : data['Author_Id'] ?? "Unknown";

                  String createdAt =
                      (data['CreatedAt'] as Timestamp?)?.toDate().toString() ??
                          "Unknown time";

                  String messageContent = data['message'] ?? "No content";

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
                                    authorId: data['Author_Id'],
                                    receiverId: data['Receiver_Id']),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor:
                                isAuthor ? Colors.blue[100] : Colors.green[100],
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: isAuthor
                                    ? Colors.blue[800]
                                    : Colors.green[800],
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  userName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                isAuthor ? 'Sent' : 'Received',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isAuthor ? Colors.blue : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(messageContent),
                              SizedBox(height: 4),
                              Text(
                                createdAt,
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          isThreeLine: true,
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
    );
  }
}
