import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModuleDetail extends StatefulWidget {
  const ModuleDetail({super.key, required this.moduleId, required this.userId});
  final String moduleId;
  final String userId;

  @override
  State<ModuleDetail> createState() => _ModuleDetailState();
}

class _ModuleDetailState extends State<ModuleDetail> {
  bool isLoading = true;
  bool isEmpty = true;
  Map<String, dynamic>? moduleData;

  @override
  void initState() {
    super.initState();
    fetchModule();
  }

  Future<void> fetchModule() async {
    try {
      DocumentSnapshot moduleDoc = await FirebaseFirestore.instance
          .collection('modules')
          .doc(widget.moduleId)
          .get();

      setState(() {
        if (moduleDoc.exists) {
          moduleData = moduleDoc.data() as Map<String, dynamic>;
          isEmpty = false;
        } else {
          isEmpty = true;
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching module: $e");
      setState(() {
        isLoading = false;
        isEmpty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add Scaffold for proper app structure
      appBar: AppBar(
        title: Text(moduleData?['title'] ?? 'Module Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isEmpty
              ? const Center(child: Text('No content in module'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            moduleData?['title'] ?? 'No title',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            moduleData?['content'] ?? 'No content',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
