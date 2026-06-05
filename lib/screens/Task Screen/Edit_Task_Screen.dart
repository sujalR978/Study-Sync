import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskid;

  const EditTaskScreen({super.key, required this.taskid});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  Future<DocumentSnapshot<Map<String, dynamic>>> loadTask() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(widget.taskid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task")),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: loadTask(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load task'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Task not found'));
          }

          final doc = snapshot.data!.data()!;

          // safe timestamp handling
          String formattedDate = '';
          String formetedTime = '';

          if (doc['dueDate'] != null) {
            final date = (doc['dueDate'] as Timestamp).toDate();
            formattedDate = DateFormat('dd/MM/yyyy').format(date);
          }
          if (doc['dueTime'] != null) {
            final time = doc['dueTime'] ?? '';
            formetedTime = time
                .toString()
                .replaceAll('TimeOfDay(', '')
                .replaceAll(')', '');
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Text(doc['description'] ?? ''),
                const SizedBox(height: 10),

                Text("Category: ${doc['category'] ?? ''}"),
                const SizedBox(height: 10),

                Text("Priority: ${doc['priority'] ?? ''}"),
                const SizedBox(height: 10),

                Text("Due Date: $formattedDate"),
                Text("Due Date: $formetedTime"),
              ],
            ),
          );
        },
      ),
    );
  }
}
