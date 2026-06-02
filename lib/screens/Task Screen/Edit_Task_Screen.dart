import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskid;
  const EditTaskScreen({super.key, required this.taskid});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  Future<DocumentSnapshot<Map<String, dynamic>>> loadTask() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(widget.taskid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: loadTask(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const Text('Failed to load task');
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('Task not found');
            }
            final doc = snapshot.data!;
            return Column(children: [Text(doc['title'])]);
          },
        ),
      ),
    );
  }
}
