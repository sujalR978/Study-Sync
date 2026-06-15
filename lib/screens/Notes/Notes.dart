import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/providers/them_provider.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/screens/Notes/createNotes.dart';
import 'package:study_sync/services/Notes_service.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => Bottomnavigation()));
          },
          icon: Icon(Icons.arrow_back_ios),
        ),

        title: Padding(
          padding: const EdgeInsets.only(left: 110),
          child: Text('Notes', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => Createnotes()));
        },
        child: Icon(Icons.add),
      ),

      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder(
              stream: NotesService().getNotes(),
              builder: (context, snepshot) {
                if (snepshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
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
                          Icons.task_rounded,
                          size: 80,
                          color: isDark
                              ? AppColors.darkInputFill
                              : AppColors.inputFill,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Tasks Found",
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

                return SafeArea(child: Column(children: []));
              },
            ),
          ],
        ),
      ),
    );
  }
}
