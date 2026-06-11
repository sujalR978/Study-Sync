import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/providers/them_provider.dart';

class AiAnswer extends StatefulWidget {
  final String Answer;
  const AiAnswer({super.key, required this.Answer});

  @override
  State<AiAnswer> createState() => _AiAnswerState();
}

class _AiAnswerState extends State<AiAnswer> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
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
                // FIXED: Use adaptive dynamic borders or fills
                color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
                thickness: 0.8,
              ),
            ),
            SelectableText(
              widget.Answer,
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
    );
  }
}
