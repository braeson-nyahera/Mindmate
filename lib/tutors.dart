import 'package:flutter/material.dart';
import 'package:mindmate/appointment.dart';
import 'package:mindmate/top_bar.dart';
import 'bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindmate/message_detail.dart';


class TutorsWidget extends StatefulWidget {
  const TutorsWidget({super.key});

  @override
  State<TutorsWidget> createState() => _TutorsWidgetState();
}




void _viewTutorPopup(BuildContext context, Map<String, dynamic> tutorData, String tutorName, ) {

  showDialog(
    
    context: context,
    builder: (context) {
      double screenHeight = MediaQuery.of(context).size.height;
      

      return Transform.translate(
        offset: Offset(0, -screenHeight * 0.03),
        child: Dialog(
          // backgroundColor:  const Color(0xFF687B96),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView( // Prevents overflow issues
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20), // Space below
                      width: double.infinity,
                      decoration: BoxDecoration(
                        // color: const Color(0xFF687B96),
                        color: const Color.fromARGB(0, 0, 0, 0),
                        borderRadius: BorderRadius.circular(12),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black12,  // Lighter color for a soft effect
                        //     blurRadius: 20,         // Higher blur for a smooth fade
                        //     spreadRadius: 1,        // Minimal spread to keep it subtle
                        //     offset: Offset(2, 2),   // Gentle positioning
                        //   ),
                        // ],

                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: tutorData['photoURL'] != null &&
                                    tutorData['photoURL'].isNotEmpty
                                ? Image.network(
                                    tutorData['photoURL'],
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/holder.png',
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(height: 10),

                          // Tutor Name
                          Text(
                              tutorName.isNotEmpty ? tutorName : "Unknown Tutor",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Color(0xFF2D5DA1)),
                            ),
                          
                          const SizedBox(height: 10),

                          // Specialty
                         RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Specialty: ",
                                  style: TextStyle(
                                    fontSize: 19, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontFamily: 'Montserrat', // Use any custom font
                                  ),
                                ),
                                TextSpan(
                                  text: tutorData['specialty'] ?? 'Not specified',
                                  style: const TextStyle(
                                    fontSize: 18, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 10),

                                                  // Subjects
                           RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Subjects: ",
                                  style: TextStyle(
                                    fontSize: 19, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontFamily: 'Montserrat',
                                  ),
                                ),
                                TextSpan(
                                  text: tutorData['subjects'] != null
                                      ? (tutorData['subjects'] as List).join(', ')
                                      : 'Not specified',
                                  style: const TextStyle(
                                    fontSize: 18, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                         // Available Timings
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Available Timings:\n ",
                                  style: TextStyle(
                                    fontSize: 19, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontFamily: 'Montserrat',
                                  ),
                                ),
                                TextSpan(
                                  text: tutorData['timings'] != null
                                      ? (tutorData['timings'] as List).join(', ')
                                      : 'Not specified',
                                  style: const TextStyle(
                                    fontSize: 18, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        ],
                      ),
                    ),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Close",
                          style: TextStyle(fontSize: 18,color: const Color.fromARGB(255, 254, 0, 0), fontWeight: FontWeight.normal),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessageDetail(
                                authorId: FirebaseAuth.instance.currentUser!.uid,
                                receiverId: tutorData['userId'],
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(
                          Icons.message,
                          color: Color(0xFF2D5DA1),
                          size: 28,
                        ),
                      )
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


// void _bookTutor(){
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => TutorAppointmentForm(selectedTutorId: tutorId),
//   ),
// );

// }


class _TutorsWidgetState extends State<TutorsWidget> {
  String searchQuery = ""; // searchQuery state variable
  String selectedFilter = "All";
  List<String> availableFilters = ["All"];

  @override
  void initState() {
    super.initState();
    _fetchFilters();
  }
  

 Future<void> _fetchFilters() async {
  try {
    var tutorsSnapshot = await FirebaseFirestore.instance.collection('tutors').get();

    // Use a Set to store unique values
    Set<String> allFiltersSet = {};

    for (var doc in tutorsSnapshot.docs) {
      var tutorData = doc.data() as Map<String, dynamic>;

      // Extract subjects if available
      if (tutorData.containsKey('subjects') && tutorData['subjects'] is List) {
        allFiltersSet.addAll(List<String>.from(tutorData['subjects']));
      }

      // Extract specialty if available
      if (tutorData.containsKey('specialty') && tutorData['specialty'] is String) {
        allFiltersSet.add(tutorData['specialty']);
      }
    }

    List<String> sortedFilters = allFiltersSet.toList()..sort(); // Convert to list & sort alphabetically

    setState(() {
      availableFilters.clear();
      availableFilters.add("All"); // Default option
      availableFilters.addAll(sortedFilters);
    });

    print("Available Filters: $availableFilters"); // Debugging

  } catch (e) {
    print("Error fetching filters: $e");
  }
}



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth < 600 ? 0.7 : 0.9;
    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        automaticallyImplyLeading: false,
        // title: TextField(
        //   onChanged: (value) {
        //     setState(() {
        //       searchQuery = value.toLowerCase(); // Update searchQuery on text change
        //     });
        //   },
        //   decoration: const InputDecoration(
        //     hintText: "Search by subject...",
        //     prefixIcon: Icon(Icons.search),
        //   ),
        // ),
        title: 

// Assuming you have availableFilters and selectedFilter defined in your state

 PopupMenuButton<String>(
  onSelected: (String value) {
    setState(() {
      selectedFilter = value;
    });
  },
  itemBuilder: (BuildContext context) {
    return [
      PopupMenuItem<String>(
        enabled: false, // Prevents this wrapper item from being selectable
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 290, // Dropdown grows dynamically but stops at . . .
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableFilters.map((String filter) {
                return PopupMenuItem<String>(
                  value: filter,
                  child: SizedBox( 
                    width: 300, //  Set dropdown width here
                    child: Text(
                      filter,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    ];
  },
  constraints: const BoxConstraints(
    minWidth: 300, //  Controls the minimum width of the dropdown
    maxWidth: 350, //  Limits maximum width
  ),
  offset: const Offset(0, 0), // Positions dropdown properly
  position: PopupMenuPosition.under,
  child: Container(
    width: 400, //  Button width remains independent
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey, width: 1.5),
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          selectedFilter == "All" ? "Select a subject..." : selectedFilter,
          // selectedFilter.isEmpty ? "Select a subject..." : selectedFilter,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Icon(Icons.arrow_drop_down, color: Color(0xFF2D5DA1), size: 30),
      ],
    ),
  ),
),

  


        actions: [
          // DropdownButton<String>(
          //   value: selectedFilter,
          //   onChanged: (newValue) {
          //     setState(() {
          //       selectedFilter = newValue!;
          //     });
          //   },
          //   items: availableFilters.map((filter) {
          //     return DropdownMenuItem(
          //       value: filter,
          //       child: Text(filter),
          //     );
          //   }).toList(),
          // ),
        ]
      ),
      bottomNavigationBar: Bottombar(currentIndex: 3),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tutors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tutors yet!"));
          }

          // var tutorsList = snapshot.data!.docs;

          var tutorsList = snapshot.data!.docs.where((doc) {
            var tutorData = doc.data() as Map<String, dynamic>;
            bool matchesSearch = searchQuery.isEmpty ||
                (tutorData['subjects'] as List)
                    .any((subject) => subject.toLowerCase().contains(searchQuery)) ||
                (tutorData['specialty']?.toLowerCase().contains(searchQuery) ?? false);

            bool matchesFilter = selectedFilter == "All" ||
                (tutorData['subjects'] as List).contains(selectedFilter) ||
                tutorData['specialty'] == selectedFilter;

            return matchesSearch && matchesFilter;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: aspectRatio,
              ),
              itemCount: tutorsList.length,
              itemBuilder: (context, index) {
                 var tutorData = tutorsList[index].data() as Map<String, dynamic>;
                // var tutorDoc = tutorsList[index]; // Get the full document
                // var tutorData = tutorDoc.data() as Map<String, dynamic>;
                // String tutorId = tutorDoc.id; // Extract document ID


                // Fetch the tutor's name from the users collection
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(tutorData['userId']) // Get name using tutor's userId
                      .get(),
                  builder: (context, userSnapshot) {
                    String tutorName = "Unknown";
                    if (userSnapshot.connectionState == ConnectionState.done &&
                        userSnapshot.hasData &&
                        userSnapshot.data!.exists) {
                      var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                      tutorName = userData['name'] ?? "Unknown";
                    }

                    return GestureDetector(
                      onTap: () {
                          // _viewTutorPopup(context, tutorData, tutorName,tutorID); // Pass tutorData and tutorName
                           _viewTutorPopup(context, tutorData, tutorName); 
                        },

                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(3, 3),
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: tutorData['photoURL'] != null &&
                                      tutorData['photoURL'].isNotEmpty
                                  ? Image.network(
                                      tutorData['photoURL'],
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
                            const SizedBox(height: 8),
                            Text(
                              "Tutor: $tutorName",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Main field: ${tutorData['specialty'] ?? 'Not specified'}",
                              style: const TextStyle(color: Colors.black87),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TutorAppointmentForm(),
            ),
          );
        },
        label: const Text(
          "Make Appointment",
          style: TextStyle(
            color: Color.fromARGB(255, 135, 61, 61),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
