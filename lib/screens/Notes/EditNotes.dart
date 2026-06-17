import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Editnotes extends StatefulWidget {
  final String noteId;
  const Editnotes({super.key, required this.noteId});

  @override
  State<Editnotes> createState() => _EditnotesState();
}

class _EditnotesState extends State<Editnotes> {
  Future<DocumentSnapshot> shownotes() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notes')
        .doc(widget.noteId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [

        ],
      ));
  }
}
