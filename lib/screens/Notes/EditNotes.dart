import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/screens/Notes/Notes.dart';
import 'package:study_sync/services/Notes_service.dart';
import 'package:study_sync/constants/app_colors.dart'; // Verified path mapping import

class Editnotes extends StatefulWidget {
  final String noteId;
  const Editnotes({super.key, required this.noteId});

  @override
  State<Editnotes> createState() => _EditnotesState();
}

class _EditnotesState extends State<Editnotes> {
  late TextEditingController title;
  late TextEditingController body;

  // Dynamic validation key for form state management
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    title = TextEditingController();
    body = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    shownotes();
  }

  Future<void> shownotes() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notes')
        .doc(widget.noteId)
        .get();

    final data = snapshot.data() as Map<String, dynamic>;

    if (data != null) {
      title.text = data['title'] ?? '';
      body.text = data['body'] ?? '';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Linked seamlessly to your newly defined premium Dark Palette tokens
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Notes()),
            );
          },
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.darkNeutral,
            size: 22,
          ),
        ),
        title: const Text(
          'Edit Note',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.2,
            color: AppColors.darkNeutral,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  NotesService().EditNotes(
                    title.text,
                    body.text,
                    widget.noteId,
                  );

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const Notes()),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // 1. --- IMMERSIVE NOTE TITLE INPUT ---
                TextFormField(
                  controller: title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkNeutral,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter title...',
                    hintStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTextBody.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Add Note title';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9a-zA-Z ]')),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(
                    color: AppColors.darkInputFill.withOpacity(0.5),
                    thickness: 1.5,
                  ),
                ),

                // 2. --- EXPANDED NOTE BODY INPUT (MAXIMUM HEIGHT COHESIVE VIEW) ---
                Expanded(
                  child: TextFormField(
                    controller: body,
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.darkTextBody,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start typing your study notes here...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: AppColors.darkTextBody.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Add Note body';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
