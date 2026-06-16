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
        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: showNotes(),

          builder: (context, snepshot) {
            final data = snepshot.data!.data();

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
