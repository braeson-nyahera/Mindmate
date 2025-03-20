import 'package:flutter/material.dart';
import 'package:mindmate/top_bar.dart';
import 'bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorsWidget extends StatefulWidget {
  const TutorsWidget({super.key});

  @override
  State<TutorsWidget> createState() => _TutorsWidgetState();
}

class _TutorsWidgetState extends State<TutorsWidget> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth < 600 ? 0.7 : 0.9;
    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);

    return Scaffold(
      appBar: TopBar(title: 'Tutors'),
      bottomNavigationBar: Bottombar(currentIndex: 3),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No tutors yet!"));
          }

          var courseLists = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: aspectRatio,
              ),
              itemCount: courseLists.length,
              itemBuilder: (context, index) {
                var data = courseLists[index].data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(3, 3),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: data['photoURL'] != null &&
                                  data['photoURL'].isNotEmpty
                              ? Image.network(
                                  data['photoURL'],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                )
                              : Image.asset(
                                  'assets/images/holder.png',
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          data['name'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Main field: ${data['mainField'] ?? 'Not specidied'}",
                          style: TextStyle(color: Colors.black87),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
