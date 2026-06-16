import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Shownotes extends StatefulWidget {
  final String noteId;
  const Shownotes({super.key, required this.noteId});

  @override
  State<Shownotes> createState() => _ShownotesState();
}

class _ShownotesState extends State<Shownotes> {
  Future<DocumentSnapshot<Map<String, dynamic>>> showNotes() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notes')
        .doc(widget.noteId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: showNotes(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'Task could not be found',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              );
            }
            final data = snapshot.data!.data();

            return Container(
              child: Column(
                children: [
                  Text(data?['title'] ?? ''),
                  Text(data?['body'] ?? ''),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
