import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/screens/Notes/Notes.dart';

class Shownotes extends StatefulWidget {
  final String noteId;
  const Shownotes({super.key, required this.noteId});

  @override
  State<Shownotes> createState() => _ShownotesState();
}

class _ShownotesState extends State<Shownotes> {
  // Caching the future variable at state level prevents infinite database re-reads on rebuilds
  late Future<DocumentSnapshot<Map<String, dynamic>>> _notesFuture;

  @overridee
  void initState() {
    super.initState();
    _notesFuture = _fetchNotes();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchNotes() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(widget.noteId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC THEME DETECTOR BLOCK ---
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
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
          icon: Icon(
            Icons.close_rounded, // Cohesive notepad layout close controller
            color: isDark ? AppColors.darkNeutral : AppColors.neutral,
            size: 22,
          ),
        ),
        title: Text(
          'View Note',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.2,
            color: isDark ? AppColors.darkNeutral : AppColors.neutral,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _notesFuture,
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
                  'Note could not be found',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextBody : AppColors.textBody,
                  ),
                ),
              );
            }

            // Explicit cast safely resolves the Object operator '[]' verification error
            final data = snapshot.data!.data() as Map<String, dynamic>;

            return Container(
              width: double.infinity,
              height: double
                  .infinity, // Forces the sheet to stretch completely downwards
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black38
                        : Colors.black.withOpacity(0.02),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- IMMERSIVE NOTE TITLE RENDER ---
                    SelectableText(
                      data['title'] ?? 'Untitled Note',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkNeutral
                            : AppColors.neutral,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(
                        color:
                            (isDark
                                    ? AppColors.darkInputFill
                                    : AppColors.inputFill)
                                .withOpacity(0.5),
                        thickness: 1.5,
                      ),
                    ),

                    // --- IMMERSIVE NOTE BODY CONTENT ---
                    SelectableText(
                      data['body'] ??
                          'No text description entered inside this note block.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: isDark
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
