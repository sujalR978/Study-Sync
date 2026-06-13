import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:study_sync/constants/app_colors.dart';

class AiAnswer extends StatefulWidget {
  final String lastUserPrompt;
  final String answer;
  final bool isLoading;
  final List<XFile> selectedimages;
  const AiAnswer({
    super.key,
    required this.answer,
    required this.isLoading,
    required this.lastUserPrompt,
    required this.selectedimages,
  });

  @override
  State<AiAnswer> createState() => _AiAnswerState();
}

class _AiAnswerState extends State<AiAnswer> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return // --- SCROLLABLE CENTRALIZED CHAT BUBBLE VIEWPORT ---
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          // Initial Welcome Screen Matrix Card if no prompt has run yet

          // 1. --- USER PROMPT BUBBLE ---
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.selectedimages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.end,
                      children: List.generate(widget.selectedimages.length, (
                        index,
                      ) {
                        return Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkInputFill
                                  : AppColors.inputFill,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(widget.selectedimages[index].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                Container(
                  margin: const EdgeInsets.only(bottom: 20, left: 50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary, // Brand color remains static
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    widget.lastUserPrompt,
                    style: const TextStyle(
                      color: Colors
                          .white, // Text remains white on primary background
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. --- NETWORK TYPING LOADER STATUS BLOCK ---

          // 3. --- SYSTEM AI ANSWER RESPONDER BUBBLE ---
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20, right: 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // FIXED: Uses structural safe layouts for surfaces
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black26
                        : Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF00D1FF),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "GENERATED RESPONSE",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.darkTextBody.withOpacity(0.7)
                              : AppColors.textBody.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      // FIXED: Use adaptive dynamic borders or fills
                      color: isDark
                          ? AppColors.darkInputFill
                          : AppColors.inputFill,
                      thickness: 0.8,
                    ),
                  ),
                  SelectableText(
                    widget.answer,
                    style: TextStyle(
                      // FIXED: Explicitly sets appropriate contrast font colors
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
