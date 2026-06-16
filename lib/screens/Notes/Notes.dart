import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/screens/Notes/createNotes.dart';
import 'package:study_sync/services/Notes_service.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  void show() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(title: Text('hi'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Dynamic dark theme background adaptive switching
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle:
            true, // Cleanly handles center positioning natively across devices
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
          'Notes',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: isDark ? AppColors.darkNeutral : AppColors.neutral,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const Createnotes()));
        },
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: NotesService().getNotes(),
                builder: (context, snepshot) {
                  if (snepshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (snepshot.hasError) {
                    return Center(child: Text(snepshot.error.toString()));
                  }
                  if (!snepshot.hasData || snepshot.data!.docs.isEmpty) {
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

                  final notes = snepshot.data!.docs.toList();

                  // ✅ TRANSFORMED: Using standard GridView.builder for clean 2-column layout profiles
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: notes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          2, // Restricts layout rows strictly to two boxes
                      mainAxisSpacing:
                          14, // Clear separation gutters between rows
                      crossAxisSpacing:
                          14, // Clear separation gutters between columns
                      childAspectRatio:
                          0.85, // Balances heights beautifully for note descriptions
                    ),
                    itemBuilder: (context, index) {
                      final data = notes[index];
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
                                    .withOpacity(0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black26
                                  : Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. --- BOX HEADER (Title Section) ---
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                color:
                                    (isDark
                                            ? AppColors.darkInputFill
                                            : AppColors.inputFill)
                                        .withOpacity(0.3),
                                child: Row(
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow
                                          .ellipsis, // Clips text with '...' if title is long
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark
                                            ? AppColors.darkNeutral
                                            : AppColors.neutral,
                                      ),
                                    ),

SizedBox(width: 300,)
                                    Align(
                                      
                                      child: IconButton(
                                        onPressed: () {
                                          show();
                                        },
                                        icon: Icon(Icons.more_vert),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 2. --- BOX BODY (Notes Description Section) ---
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Text(
                                    body,
                                    maxLines:
                                        5, // Allows preview text stack to fill layout space elegantly
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
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
