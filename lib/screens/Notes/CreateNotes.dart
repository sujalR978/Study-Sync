import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/screens/Notes/Notes.dart';
import 'package:study_sync/services/Notes_service.dart';

class Createnotes extends StatefulWidget {
  const Createnotes({super.key});

  @override
  State<Createnotes> createState() => _CreatenotesState();
}

class _CreatenotesState extends State<Createnotes> {
  final TextEditingController notesName = TextEditingController();
  final TextEditingController notesBody = TextEditingController();
  final GlobalKey<FormState> KeyForm = GlobalKey<FormState>();

  @override
  void dispose() {
    notesBody.dispose();
    notesName.dispose();
    super.dispose();
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
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Notes()),
            );
          },
          icon: Icon(
            Icons
                .close_rounded, // Changed to a clean "close" icon for a modern notepad feel
            color: isDark ? AppColors.darkNeutral : AppColors.neutral,
            size: 22,
          ),
        ),
        title: Text(
          'New Note',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.2,
            color: isDark ? AppColors.darkNeutral : AppColors.neutral,
          ),
        ),
        actions: [
          // Moved the action button to the Top Right AppBar for a premium, clean layout workflow
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: () {
                if (KeyForm.currentState!.validate()) {
                  NotesService().AddNotes(
                    title: notesName.text,
                    body: notesBody.text,
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
          key: KeyForm,
          // ✅ CHANGED: Replaced Column with an immersive full-page expansion layout container block
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                // 1. --- IMMERSIVE NOTE TITLE INPUT ---
                TextFormField(
                  controller: notesName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkNeutral : AppColors.neutral,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter title...',
                    hintStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          (isDark ? AppColors.darkTextBody : AppColors.textBody)
                              .withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
                    color:
                        (isDark ? AppColors.darkInputFill : AppColors.inputFill)
                            .withOpacity(0.5),
                    thickness: 1.5,
                  ),
                ),

                // 2. --- EXPANDED NOTE BODY INPUT (MAXIMUM HEIGHT VIEW) ---
                Expanded(
                  child: TextFormField(
                    controller: notesBody,
                    maxLines: null, // Allows infinite lines internally
                    expands:
                        true, // ✅ CHANGED: Forces the input field box to dynamically stretch to the bottom of the page!
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical
                        .top, // Starts typing from the very top-left corner
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: isDark
                          ? AppColors.darkTextBody
                          : AppColors.textBody,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start typing your study notes here...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color:
                            (isDark
                                    ? AppColors.darkTextBody
                                    : AppColors.textBody)
                                .withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
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
