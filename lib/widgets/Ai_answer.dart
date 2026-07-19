import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class AiAnswer extends StatelessWidget {
  final String lastUserPrompt;
  final String answer;
  final bool isLoading;
  final List<String> selectedimages;

  const AiAnswer({
    super.key,
    required this.answer,
    required this.isLoading,
    required this.lastUserPrompt,
    required this.selectedimages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color surfaceColor = theme.colorScheme.surface;
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    // Direct multi-theme color blending models
    final Color dynamicBorderColor = Color.alphaBlend(
      primaryColor.withOpacity(isDark ? 0.15 : 0.08),
      surfaceColor,
    );
    final Color dynamicTextBody = onSurfaceColor.withOpacity(0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          // 1. --- USER PROMPT BUBBLE (STAGGERED ANIMATION 1) ---
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(20 * (1.0 - value), 0), // Subtle slide from the right side
                  child: child,
                ),
              );
            },
            child: Align( 
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (selectedimages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: List.generate(selectedimages.length, (index) {
                          try {
                            String base64RawStr = selectedimages[index];
                            if (base64RawStr.contains(',')) {
                              base64RawStr = base64RawStr.split(',').last;
                            }
                            
                            Uint8List imageBytes = base64Decode(base64RawStr);

                            return _ImagePreviewCard(
                              imageBytes: imageBytes, 
                              borderColor: dynamicBorderColor,
                            );
                          } catch (e) {
                            return const SizedBox.shrink();
                          }
                        }),
                      ),
                    ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 20, left: 50),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryColor, primaryColor.withOpacity(0.85)],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      lastUserPrompt,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. --- SYSTEM AI ANSWER BUBBLE (STAGGERED ANIMATION 2) ---
          if (!isLoading && answer.isNotEmpty)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(-20 * (1.0 - value), 0), // Subtle slide from the left side
                    child: child,
                  ),
                );
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10, right: 30),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: secondaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "GENERATED RESPONSE",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: dynamicTextBody,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          color: dynamicBorderColor,
                          thickness: 1.0,
                        ),
                      ),
                      SelectableText(
                        answer,
                        style: TextStyle(
                          color: onSurfaceColor,
                          fontSize: 15,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Internal private micro-component checking press scales on attachment previews
class _ImagePreviewCard extends StatefulWidget {
  final Uint8List imageBytes;
  final Color borderColor;

  const _ImagePreviewCard({required this.imageBytes, required this.borderColor});

  @override
  State<_ImagePreviewCard> createState() => _ImagePreviewCardState();
}

class _ImagePreviewCardState extends State<_ImagePreviewCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.borderColor,
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              widget.imageBytes,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}