import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart';

class AiAnswer extends StatelessWidget {
  final String lastUserPrompt;
  final String answer;
  final bool isLoading;
  final List<String> selectedimages; // FIXED: Changed to List<String> to accept Base64 content

  const AiAnswer({
    super.key,
    required this.answer,
    required this.isLoading,
    required this.lastUserPrompt,
    required this.selectedimages,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          // 1. --- USER PROMPT BUBBLE ---
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // FIXED: Displays image previews from historical Base64 strings safely
                if (selectedimages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.end,
                      children: List.generate(selectedimages.length, (index) {
                        try {
                          // Extract raw Base64 contents by cutting data scheme signatures if present
                          String base64RawStr = selectedimages[index];
                          if (base64RawStr.contains(',')) {
                            base64RawStr = base64RawStr.split(',').last;
                          }
                          
                          Uint8List imageBytes = base64Decode(base64RawStr);

                          return Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                imageBytes,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        } catch (e) {
                          print("Failed decoding text string item in UI frame: $e");
                          return const SizedBox.shrink();
                        }
                      }),
                    ),
                  ),

                Container(
                  margin: const EdgeInsets.only(bottom: 20, left: 50),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    lastUserPrompt,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. --- SYSTEM AI ANSWER RESPONDER BUBBLE ---
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20, right: 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.black.withOpacity(0.02),
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
                      color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
                      thickness: 0.8,
                    ),
                  ),
                  SelectableText(
                    answer,
                    style: TextStyle(
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