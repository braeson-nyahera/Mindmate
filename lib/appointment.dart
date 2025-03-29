import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TutorAppointmentForm extends StatefulWidget {
  const TutorAppointmentForm({super.key});

  @override
  State<TutorAppointmentForm> createState() => _TutorAppointmentFormState();
}

class _TutorAppointmentFormState extends State<TutorAppointmentForm> {
  // Form controllers
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Selected values
  String? _selectedTutor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  // Loading states
  bool _loadingTutors = true;
  bool _loadingTimeSlots = false;
  bool _submitting = false;

  // Data lists
  List<Map<String, dynamic>> _tutors = [];
  List<String> _availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  // Load all tutors from Firestore
  Future<void> _loadTutors() async {
    setState(() {
      _loadingTutors = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('tutors').get();

      final List<Map<String, dynamic>> tutorsList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'];

        // Get user details
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          tutorsList.add({
            'id': doc.id,
            'userId': userId,
            'name': userData['name'] ?? 'Unknown',
            'photoUrl': userData['photoUrl'] ?? '',
          });
        }
      }

      setState(() {
        _tutors = tutorsList;
        _loadingTutors = false;
      });
    } catch (e) {
      setState(() {
        _loadingTutors = false;
      });
      _showErrorSnackBar('Failed to load tutors: $e');
    }
  }

  // Load available time slots for selected tutor and date
  Future<void> _loadAvailableTimeSlots(String tutorId, DateTime date) async {
    setState(() {
      _loadingTimeSlots = true;
      _selectedTimeSlot = null;
      _availableTimeSlots = [];
    });

    try {
      // Format date to YYYY-MM-DD for Firestore query
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Get tutor document to find their available timings
      final DocumentSnapshot tutorDoc = await FirebaseFirestore.instance
          .collection('tutors')
          .doc(tutorId)
          .get();

      if (!tutorDoc.exists) {
        throw Exception('Tutor not found');
      }

      final tutorData = tutorDoc.data() as Map<String, dynamic>;

      // Get tutor's available timings
      final List<dynamic> availableTimings = tutorData['timings'] ?? [];

      // Get existing appointments for this tutor on this date
      final QuerySnapshot existingAppointments = await FirebaseFirestore
          .instance
          .collection('appointments')
          .where('tutorId', isEqualTo: tutorId)
          .where('date', isEqualTo: formattedDate)
          .get();

      // Extract booked time slots
      final List<String> bookedSlots = existingAppointments.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['timeSlot'] as String)
          .toList();

      setState(() {
        // Filter out already booked slots
        _availableTimeSlots = availableTimings
            .map((slot) => slot.toString())
            .where((slot) => !bookedSlots.contains(slot))
            .toList();
        _loadingTimeSlots = false;
      });
    } catch (e) {
      setState(() {
        _loadingTimeSlots = false;
      });
      _showErrorSnackBar('Failed to load available time slots: $e');
    }
  }

  
  Future<void> _submitAppointment() async {
  if (_subjectController.text.isEmpty ||
      _selectedTutor == null ||
      _selectedDate == null ||
      _selectedTimeSlot == null) {
    _showErrorSnackBar('Please fill in all required fields');
    return;
  }

  setState(() {
    _submitting = true;
  });

  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    // Fetch student's name
    DocumentSnapshot studentDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    String studentName = studentDoc.exists ? studentDoc['name'] ?? 'Unknown Student' : 'Unknown Student';

    // Fetch tutor details
    DocumentSnapshot tutorDoc = await FirebaseFirestore.instance.collection('tutors').doc(_selectedTutor).get();
    String tutorName = 'Unknown Tutor'; // Default in case tutor is not found
    String tutorUserId = '';

    if (tutorDoc.exists) {
      final tutorData = tutorDoc.data() as Map<String, dynamic>;
      tutorUserId = tutorData['userId']; // Ensure this field exists

      // Fetch tutor's actual name from 'users' collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(tutorUserId).get();
      if (userDoc.exists && userDoc.data() != null) {
      final userData = userDoc.data() as Map<String, dynamic>; // Explicit cast
      tutorName = userData['name'] ?? 'Unknown Tutor';
    }

    }

    // Create appointment document
    await FirebaseFirestore.instance.collection('appointments').add({
      'userId': currentUser.uid,
      'tutorId': _selectedTutor,
      'subject': _subjectController.text.trim(),
      'date': formattedDate,
      'timeSlot': _selectedTimeSlot,
      'notes': _notesController.text,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp()
    });

    
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': currentUser.uid,
      'message': 'Your appointment with $tutorName for ${_subjectController.text.trim()} on $formattedDate at $_selectedTimeSlot has been requested.',
      'timestamp': Timestamp.now(),
    });

    
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': tutorUserId,
      'message': 'You have been booked for ${_subjectController.text.trim()} on $formattedDate at $_selectedTimeSlot by $studentName.',
      'timestamp': Timestamp.now(),
    });

    // Reset form and show success message
    setState(() {
      _subjectController.clear();
      _selectedTutor = null;
      _selectedDate = null;
      _selectedTimeSlot = null;
      _notesController.clear();
      _submitting = false;
    });

    _showSuccessSnackBar('Appointment requested successfully');
  } catch (e) {
    setState(() {
      _submitting = false;
    });
    _showErrorSnackBar('Failed to submit appointment: $e');
  }
}



  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Tutor Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject input field
            Text(
              'What do you want to learn?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Enter subject (e.g., Math, Physics, Programming)',
              ),
            ),

            const SizedBox(height: 24),

            // Tutor selection
            Text(
              'Select Tutor',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_loadingTutors)
              const Center(child: CircularProgressIndicator())
            else if (_tutors.isEmpty)
              const Text('No tutors available')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tutors.length,
                itemBuilder: (context, index) {
                  final tutor = _tutors[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: _selectedTutor == tutor['id']
                        ? Colors.blue.shade50
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _selectedTutor == tutor['id']
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTutor = tutor['id'];
                          _selectedDate = null;
                          _selectedTimeSlot = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: tutor['photoUrl'].isNotEmpty
                                  ? NetworkImage(tutor['photoUrl'])
                                  : null,
                              child: tutor['photoUrl'].isEmpty
                                  ? Text(tutor['name'][0])
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tutor['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Radio<String>(
                              value: tutor['id'],
                              groupValue: _selectedTutor,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedTutor = value;
                                  _selectedDate = null;
                                  _selectedTimeSlot = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

            if (_selectedTutor != null) ...[
              const SizedBox(height: 24),

              // Date selection
              Text(
                'Select Date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                onDateChanged: (DateTime date) {
                  setState(() {
                    _selectedDate = date;
                  });
                  _loadAvailableTimeSlots(_selectedTutor!, date);
                },
              ),

              if (_selectedDate != null) ...[
                const SizedBox(height: 24),

                // Time slot selection
                Text(
                  'Select Time Slot',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_loadingTimeSlots)
                  const Center(child: CircularProgressIndicator())
                else if (_availableTimeSlots.isEmpty)
                  const Text('No available time slots for this date'),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTimeSlots.map((timeSlot) {
                    return ChoiceChip(
                      label: Text(timeSlot),
                      selected: _selectedTimeSlot == timeSlot,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedTimeSlot = selected ? timeSlot : null;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Notes field
                Text(
                  'Additional Notes (Optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Enter any specific topics or questions...',
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submitAppointment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Book Appointment',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
