import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreListScreen extends StatelessWidget {
  FirestoreListScreen({super.key});
  final CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mindmate Firestore UI")),
      body: StreamBuilder<QuerySnapshot>(
        stream: messages.snapshots(), // Listen for real-time updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No messages yet!"));
          }

          // Convert Firestore documents into a list
          var docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['message'] ?? 'No message'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a new document when the button is clicked
          messages.add({'message': 'New message at ${DateTime.now()}'});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
