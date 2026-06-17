import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/widgets/custom_textfield.dart';

class Editnotes extends StatefulWidget {
  final String noteId;
  const Editnotes({super.key, required this.noteId});

  @override
  State<Editnotes> createState() => _EditnotesState();
}

class _EditnotesState extends State<Editnotes> {
  late TextEditingController title =;
  late TextEditingController body ;

  Future<void> shownotes() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notes')
        .doc(widget.noteId)
        .get();

    final data = snapshot.data();

    if(data != null){
      title =
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Form(
            child: Column(
              children: [
                CustomTextfield.customTextField(
                  hintText: '',
                  icon: Icons.icecream_outlined,
                  controller: title,
                  context: context,
                ),
                CustomTextfield.customTextField(
                  hintText: '',
                  icon: Icons.icecream_outlined,
                  controller: body,
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
