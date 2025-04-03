import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';

// Models stay the same
class Course {
  final String author;
  final String title;
  final String timestamp;
  final String courseId;
  final String description;
  final String? imageUrl;
  final List<Module> modules;

  Course({
    required this.author,
    required this.title,
    required this.timestamp,
    required this.courseId,
    required this.description,
    this.imageUrl,
    this.modules = const [],
  });

  String get formattedData =>
      'Author"$author"\n(string)\nTime $timestamp\n(timestamp)\ntitle "$title"\ndescription "$description"\nimageUrl "${imageUrl ?? 'No image'}"';
}

class Module {
  final String title;
  final String content;
  final String courseId;

  Module({
    required this.title,
    required this.content,
    required this.courseId,
  });

  String get formattedData =>
      'content"$content"\n(string)\ncourse_id"$courseId"\n(string)\ntitle"$title"';
}

class CourseCreationWidget extends StatefulWidget {
  final Function(Course)? onCourseCreated;
  final Function(Module)? onModuleAdded;

  const CourseCreationWidget({
    Key? key,
    this.onCourseCreated,
    this.onModuleAdded,
  }) : super(key: key);

  @override
  State<CourseCreationWidget> createState() => _CourseCreationWidgetState();
}

class _CourseCreationWidgetState extends State<CourseCreationWidget> {
  String author = "Loading author...";
  bool isAuthorLoading = true;
  bool isUploading = false;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Image related variables
  File? _imageFile;
  Uint8List? _webImage;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool get _hasImage => _imageFile != null || _webImage != null;
  String? _imageSize;
  double _uploadProgress = 0.0;

  final CollectionReference courses =
      FirebaseFirestore.instance.collection('courses');
  final CollectionReference modules =
      FirebaseFirestore.instance.collection('modules');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isAuthorLoading = true;
    });

    try {
      String authorName = await _getUserData();
      setState(() {
        author = authorName;
        isAuthorLoading = false;
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        author = "Error loading author";
        isAuthorLoading = false;
      });
    }
  }

  Future<String> _getUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return "Not logged in";
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: currentUser.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return userData['name'] ?? "No author name";
    } else {
      return "No author found";
    }
  }

  Future<String> _getCourseUid(Module module) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('courseId', isEqualTo: _createdCourse!.courseId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentUid = querySnapshot.docs.first.id;
        print('Found course document UID: $documentUid');
        return documentUid;
      } else {
        print(
            'No course document found with courseId: ${_createdCourse!.courseId}');
        return '';
      }
    } catch (e) {
      print('Error getting course UID: $e');
      return '';
    }
  }

  // Course state
  String _courseId = '';
  Course? _createdCourse;

  // Module state
  final List<Module> _modules = [];

  // Generate random ID similar to Firebase ID
  String _generateRandomId() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(20, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  String _formatCurrentDateTime() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final month = months[now.month - 1];
    final day = now.day;
    final year = now.year;

    final hour = now.hour > 12
        ? now.hour - 12
        : now.hour == 0
            ? 12
            : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    final timeZoneOffset = now.timeZoneOffset;
    final offsetHours = timeZoneOffset.inHours;
    final sign = offsetHours >= 0 ? '+' : '';

    return '$month $day, $year at $hour:$minute:$second $period UTC$sign$offsetHours';
  }

  // Platform-aware image picking function
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600, // Reduced from 800
        maxHeight: 600, // Added height constraint
        imageQuality: 60, // Reduced from 80
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Handle web image
          final imageBytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = imageBytes;
            _imageFile = null;
            // Add filesize info for feedback
            _imageSize = (imageBytes.length / 1024).toStringAsFixed(2) + ' KB';
          });
        } else {
          // Handle mobile image
          setState(() {
            _imageFile = File(pickedFile.path);
            _webImage = null;
            // Add filesize info for feedback
            _imageSize =
                (File(pickedFile.path).lengthSync() / 1024).toStringAsFixed(2) +
                    ' KB';
          });
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  // Platform-aware image upload function
  Future<String?> _uploadImage() async {
    if (!_hasImage) return null;

    setState(() {
      isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Create a unique file name
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_course_image';

      // Create a reference to the location where we'll store the file
      Reference storageRef = _storage.ref().child('course_images/$fileName');

      // Upload the file based on platform
      UploadTask uploadTask;
      if (kIsWeb) {
        // Web platform - upload bytes
        uploadTask = storageRef.putData(_webImage!);
      } else {
        // Mobile platform - upload file
        uploadTask = storageRef.putFile(_imageFile!);
      }

      // Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          _uploadProgress = progress;
        });
      });

      // Wait until the file is uploaded
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        isUploading = false;
        _uploadProgress = 0.0;
        _uploadedImageUrl = downloadUrl;
      });

      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      setState(() {
        isUploading = false;
        _uploadProgress = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              // Only show camera option if not on web
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              if (_hasImage)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Image',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    setState(() {
                      _imageFile = null;
                      _webImage = null;
                      _uploadedImageUrl = null;
                    });
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _createCourse() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final generatedId = _courseId.isEmpty ? _generateRandomId() : _courseId;
      final timestamp = _formatCurrentDateTime();
      print("Initializing course");

      // Upload image if selected
      String? imageUrl;
      if (_hasImage) {
        imageUrl = await _uploadImage();
      }

      final course = Course(
        author: author,
        title: _titleController.text,
        timestamp: timestamp,
        courseId: generatedId,
        description: _descriptionController.text,
        imageUrl: imageUrl,
      );

      setState(() {
        _courseId = generatedId;
        _createdCourse = course;
      });

      // Add to Firestore
      DocumentReference docRef = await courses.add({
        'author': author,
        'title': course.title,
        'timestamp': course.timestamp,
        'courseId': course.courseId,
        'description': course.description,
        'imageUrl': imageUrl,
      });

      print("Course created with Firestore ID: ${docRef.id}");

      // Call the callback if provided
      if (widget.onCourseCreated != null) {
        widget.onCourseCreated!(course);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _courseId = '';
      _createdCourse = null;
      _modules.clear();
      _imageFile = null;
      _webImage = null;
      _uploadedImageUrl = null;
    });
  }

  void _handleModuleAdded(Module module) async {
    // Get the Firestore document ID of the course
    String courseUid = await _getCourseUid(module);

    setState(() {
      _modules.add(module);
    });

    // Call the callback if provided
    if (widget.onModuleAdded != null) {
      widget.onModuleAdded!(module);
    }

    // Add module to Firestore with the course UID
    DocumentReference moduleRef = await modules.add({
      'title': module.title,
      'content': module.content,
      'course_id': courseUid, // Using the Firestore document ID
      'course_logical_id':
          module.courseId, // Also storing the logical ID if needed
      'created_at': FieldValue.serverTimestamp(),
    });

    print("Module added with Firestore ID: ${moduleRef.id}");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _createdCourse == null ? _buildCourseForm() : _buildModuleSection(),
    );
  }

  Widget _buildCourseForm() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Course'),
        
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              // const Text(
              //   'Create New Course',
              //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                
              // ),
              // const SizedBox(height: 20),
      
              // Author field (non-editable)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Author',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isAuthorLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            author,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ],
                ),
              ),
      
              const SizedBox(height: 16),
      
              // Course Image Picker
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb && _webImage != null
                                ? Image.memory(
                                    _webImage!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          if (isUploading)
                            Container(
                              color: Colors.black38,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    value: _uploadProgress,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '${(_uploadProgress * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white),
                                onPressed: _showImagePickerOptions,
                              ),
                            ),
                          ),
                          if (_imageSize != null && !isUploading)
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Size: $_imageSize',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add Course Image',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showImagePickerOptions,
                              icon: const Icon(Icons.photo_camera),
                              label: const Text('Choose Image'),
                            ),
                          ],
                        ),
                      ),
              ),
      
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Course Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course description';
                  }
                  return null;
                },
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    (isAuthorLoading || isUploading) ? null : _createCourse,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isAuthorLoading
                    ? const Text('Loading Author Data...')
                    : isUploading
                        ? const Text('Uploading Image...')
                        : const Text('Create Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleSection() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      shrinkWrap: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Course Created',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _resetForm,
              icon: const Icon(Icons.add),
              label: const Text('Create New Course'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Course image display
        if (_createdCourse?.imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _createdCourse!.imageUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text('Failed to load image'),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(_createdCourse!.formattedData),
        ),
        const SizedBox(height: 16),
        Text('Created on: ${_createdCourse!.timestamp}'),
        Text('Course ID: ${_createdCourse!.courseId}'),
        const SizedBox(height: 24),
        const Divider(),

        // Module Form
        const Text(
          'Add Module',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _AddModuleForm(
          courseId: _createdCourse!.courseId,
          onModuleAdded: _handleModuleAdded,
        ),

        // Modules List
        if (_modules.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Added Modules (${_modules.length})',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _modules.length,
            itemBuilder: (context, index) {
              final module = _modules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        module.content.length > 150
                            ? '${module.content.substring(0, 150)}...'
                            : module.content,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(module.formattedData),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

// The module form remains unchanged
class _AddModuleForm extends StatefulWidget {
  final String courseId;
  final Function(Module) onModuleAdded;

  const _AddModuleForm({
    Key? key,
    required this.courseId,
    required this.onModuleAdded,
  }) : super(key: key);

  @override
  State<_AddModuleForm> createState() => _AddModuleFormState();
}

class _AddModuleFormState extends State<_AddModuleForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _submitModule() {
    if (_formKey.currentState!.validate()) {
      final module = Module(
        title: _titleController.text,
        content: _contentController.text,
        courseId: widget.courseId,
      );

      widget.onModuleAdded(module);

      // Reset the form for a new module
      _titleController.clear();
      _contentController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Module added successfully')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Module Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter module title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Module Content',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter module content';
              }
              return null;
            },
            maxLines: 10,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitModule,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              backgroundColor: Colors.green,
            ),
            child: const Text('Add Module'),
          ),
        ],
      ),
    );
  }
}

// Example usage remains the same
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Creation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: CourseCreationWidget(
          onCourseCreated: (course) {
            // Handle course creation
            print('Course created: ${course.title}');
          },
          onModuleAdded: (module) {
            // Handle module addition
            print('Module added: ${module.title}');
          },
        ),
      ),
    );
  }
}
