import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/providers/them_provider.dart';

class AiAnswer extends StatefulWidget {
  final String lastUserPrompt;
  final String answer;
  final bool isLoading;
  const AiAnswer({super.key
  ,
  required this.answer,
  required this.isLoading,
  required this.lastUserPrompt});

  @override
  State<AiAnswer> createState() => _AiAnswerState();
}

class _AiAnswerState extends State<AiAnswer> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return // --- SCROLLABLE CENTRALIZED CHAT BUBBLE VIEWPORT ---
    Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Initial Welcome Screen Matrix Card if no prompt has run yet
            if (widget.lastUserPrompt.isEmpty && widget.answer.isEmpty && !widget.isLoading)
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  // FIXED: Reads system card surface settings cleanly
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black26
                          : Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "How can I assist your studies today?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ask me to draft scheduling summaries, explain complex data modules, or rewrite your active items.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        // FIXED: Pulls correct adaptive text body colors
                        color: isDark
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            // 1. --- USER PROMPT BUBBLE ---
            if (widget.lastUserPrompt.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
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
      ),
    );
  }
}
