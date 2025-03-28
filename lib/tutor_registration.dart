import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:mindmate/profile.dart';

class TutorRegistrationForm extends StatefulWidget {
  const TutorRegistrationForm({super.key});

  @override
  State<TutorRegistrationForm> createState() => _TutorRegistrationFormState();
}

class _TutorRegistrationFormState extends State<TutorRegistrationForm> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _moreController = TextEditingController();

  // Selected values
  final List<String> _selectedSubjects = [];
  final List<String> _selectedTimeSlots = [];
  File? _profileImage;

  // Form state
  bool _submitting = false;
  bool _hasSubmitted = false;

  // Available subjects
  final List<String> _availableSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'IT',
    'Computer Science',
    'Law',
    'Pharmacy',
    'Telecommunication',
    'Forensics',
    'Economics',
    'Business',
    'Art',
    'Music',
    'Physical Education',
    'Others'
  ];

  // Available time slots
  final List<String> _availableTimeSlots = [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
    '19:00 - 20:00'
  ];

  @override
  void dispose() {
    _specialtyController.dispose();
    _moreController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadProfileImage(String userId) async {
    if (_profileImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('tutor_profiles')
          .child('$userId.jpg');

      await storageRef.putFile(_profileImage!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      _showErrorSnackBar('Failed to upload profile image: $e');
      return null;
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubjects.isEmpty) {
      _showErrorSnackBar('Please select at least one subject');
      return;
    }

    if (_selectedTimeSlots.isEmpty) {
      _showErrorSnackBar('Please select at least one available time slot');
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

      // Check if user already exists in the users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'name': userDoc['name'] ?? 'Unknown',
          'email': currentUser.email,
          'photoUrl': currentUser.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Upload profile image if selected
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await _uploadProfileImage(currentUser.uid);

        // Update user document with new profile image
        if (profileImageUrl != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({
            'photoUrl': profileImageUrl,
          });
        }
      }

      // Check if user is already registered as a tutor
      final tutorQuerySnapshot = await FirebaseFirestore.instance
          .collection('tutors')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      if (tutorQuerySnapshot.docs.isNotEmpty) {
        // Update existing tutor document
        await FirebaseFirestore.instance
            .collection('tutors')
            .doc(tutorQuerySnapshot.docs.first.id)
            .update({
          'specialty': _specialtyController.text.trim(),
          'more': _moreController.text.trim(),
          'subjects': _selectedSubjects,
          'timings': _selectedTimeSlots,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new tutor document
        await FirebaseFirestore.instance.collection('tutors').add({
          'userId': currentUser.uid,
          'specialty': _specialtyController.text.trim(),
          'more': _moreController.text.trim(),
          'subjects': _selectedSubjects,
          'timings': _selectedTimeSlots,
          'isActive': true,
          'rating': 0.0,
          'reviewCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      setState(() {
        _submitting = false;
        _hasSubmitted = true;
      });

      _showSuccessSnackBar('Tutor registration successful!');
    } catch (e) {
      setState(() {
        _submitting = false;
      });
      _showErrorSnackBar('Failed to submit registration: $e');
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
    if (_hasSubmitted) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          image: _profileImage != null
                              ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _profileImage == null
                            ? const Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text('Upload Profile Picture'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Subjects selection
              Text(
                'Subjects You Can Tutor On',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSubjects.map((subject) {
                  return FilterChip(
                    label: Text(subject),
                    selected: _selectedSubjects.contains(subject),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedSubjects.add(subject);
                        } else {
                          _selectedSubjects.remove(subject);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Specialty field
              Text(
                'Your Specialty',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _specialtyController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'e.g., Calculus, Programming, Literature',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your specialty';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // About Me field
              Text(
                'More on your tutor topic',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _moreController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Tell students more about what you can tutor...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please tell us about what you can tutor';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Time slots selection
              Text(
                'Available Time Slots',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTimeSlots.map((timeSlot) {
                  return FilterChip(
                    label: Text(timeSlot),
                    selected: _selectedTimeSlots.contains(timeSlot),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTimeSlots.add(timeSlot);
                        } else {
                          _selectedTimeSlots.remove(timeSlot);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitRegistration,
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
                          'Submit Registration',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Complete'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Registration Successful!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your tutor profile has been created. Students can now book sessions with you.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileWidget()),
                    );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Go to Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
