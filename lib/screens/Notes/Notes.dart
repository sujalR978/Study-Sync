import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/screens/Notes/EditNotes.dart';
import 'package:study_sync/screens/Notes/createNotes.dart';
import 'package:study_sync/screens/Notes/showNotes.dart';
import 'package:study_sync/services/Notes_service.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  // --- UPGRADED: PREMIUM OPTIONS & DELETION CONFIRMATION STRIP ---
  void showOptionsDialog(String noteId, String noteTitle, bool isDark) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.symmetric(horizontal: 60),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                noteTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? AppColors.darkNeutral : AppColors.neutral,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Note Options",
                style: TextStyle(
                  color: (isDark ? AppColors.darkTextBody : AppColors.textBody)
                      .withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
                  thickness: 1.2,
                ),
              ),

              // --- SHOW ACTION ---
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Shownotes(noteId: noteId),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.visibility_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  label: Text(
                    'Open Note',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // --- EDIT ACTION ---
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Editnotes(noteId: noteId),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  label: Text(
                    'Edit Content',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // --- WARNING DELETE ACTION SYSTEM ---
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Dismiss options panel framework
                    showDeleteConfirmation(
                      noteId,
                      noteTitle,
                      isDark,
                    ); // Open target warning dialog
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                  label: const Text(
                    'Delete Note',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    overlayColor: const Color(0xFFEF4444).withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- NEW: DEDICATED RED WARNING CONFIRMATION MATRIX ---
  void showDeleteConfirmation(String noteId, String noteTitle, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Color(0xFFEF4444),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Discard Note?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkNeutral : AppColors.neutral,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextBody : AppColors.textBody,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Are you sure you want to permanently purge ',
                    ),
                    TextSpan(
                      text: '"$noteTitle"',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkNeutral
                            : AppColors.neutral,
                      ),
                    ),
                    const TextSpan(text: '? This action cannot be reversed.'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor:
                              (isDark
                                      ? AppColors.darkInputFill
                                      : AppColors.inputFill)
                                  .withOpacity(0.5),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkNeutral
                                : AppColors.neutral,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          NotesService().DeleteNotes(noteId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Bottomnavigation()),
            );
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkNeutral : AppColors.neutral,
            size: 18,
          ),
        ),
        title: Text(
          'Notes Directory',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? AppColors.darkNeutral : AppColors.neutral,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const Createnotes()));
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          "New Note",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: NotesService().getNotes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_alt_rounded,
                            size: 80,
                            color: isDark
                                ? AppColors.darkInputFill
                                : AppColors.inputFill,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Notes Found",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextBody
                                  : AppColors.textBody,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final notes = snapshot.data!.docs;

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: notes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.88,
                        ),
                    itemBuilder: (context, index) {
                      final data = notes[index];
                      String noteId = data.id;
                      String title = data['title'] ?? 'Untitled';
                      String body = data['body'] ?? '';

                      return Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                (isDark
                                        ? AppColors.darkInputFill
                                        : AppColors.inputFill)
                                    .withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black26
                                  : Colors.black.withOpacity(0.01),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. --- APP BAR HEADER (Title Block Grid) ---
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 14,
                                  right: 4,
                                  top: 4,
                                  bottom: 4,
                                ),
                                color:
                                    (isDark
                                            ? AppColors.darkInputFill
                                            : AppColors.inputFill)
                                        .withOpacity(0.15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark
                                              ? AppColors.darkNeutral
                                              : AppColors.neutral,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.more_vert_rounded,
                                        size: 18,
                                        color: isDark
                                            ? AppColors.darkTextBody
                                            : AppColors.textBody,
                                      ),
                                      onPressed: () => showOptionsDialog(
                                        noteId,
                                        title,
                                        isDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 2. --- NOTEPAD PREVIEW RENDER PANEL ---
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Text(
                                    body,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      height: 1.4,
                                      color: isDark
                                          ? AppColors.darkTextBody
                                          : AppColors.textBody,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
