import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/screens/Notes/Notes.dart';
import 'package:study_sync/services/Notes_service.dart';

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

  // Premium Custom Dark Palette System matching reference architecture
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkNeutral = Color(0xFFF8FAFC);
  static const Color darkTextBody = Color(0xFF94A3B8);
  static const Color darkInputFill = Color(0xFF334155);
  static const Color accentPrimary = Color(0xFF6366F1);

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
      backgroundColor: darkBackground,
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
            Icons
                .close_rounded, // Premium notepad close handle matching reference
            color: darkNeutral,
            size: 22,
          ),
        ),
        title: const Text(
          'Edit Note',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.2,
            color: darkNeutral,
          ),
        ),
        actions: [
          // Premium Save/Update trigger positioned in top right bar
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
                foregroundColor: accentPrimary,
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
          // TAKING EXACT DESIGN REFERENCE FROM YOUR CODE: Immersive full page card block
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: darkSurface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
                    color: darkNeutral,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter title...',
                    hintStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkTextBody.withOpacity(0.5),
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
                    color: darkInputFill.withOpacity(0.5),
                    thickness: 1.5,
                  ),
                ),

                // 2. --- EXPANDED NOTE BODY INPUT (MAXIMUM HEIGHT COHESIVE VIEW) ---
                Expanded(
                  child: TextFormField(
                    controller: body,
                    maxLines:
                        null, // Unlimited lines tracking matching blueprint
                    expands:
                        true, // Forces the input field box to dynamically fill remaining space
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical
                        .top, // Locks generation inputs to top-left
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: darkTextBody,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start typing your study notes here...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: darkTextBody.withOpacity(0.5),
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
