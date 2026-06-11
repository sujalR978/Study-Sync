import 'package:flutter/material.dart';
import 'package:study_sync/API/get_open_router_response.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/widgets/Ai_answer.dart'; // Make sure this path is correct

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController controller = TextEditingController();
  List<String> answer = [''];
  bool _isLoading = false;
  List<String> lastUserPrompt = [];

  void _talkToGpt() async {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      lastUserPrompt.add(controller.text);
    });

    String theAnswer = await getOpenRouterResponse(controller.text);

    setState(() {
      answer.add(theAnswer);
      _isLoading = false;
    });

    controller.clear();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access theme brightness to adjust custom overlay features safely
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIXED: Uses system-configured scaffold background automatically
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Text(
              "Sync AI Studio",
              style: TextStyle(
                // FIXED: Theme-aware font rendering
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            // FIXED: Automatically shifts color arrow based on theme state
            color: Theme.of(context).colorScheme.onBackground,
            size: 18,
          ),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => Bottomnavigation()));
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- SCROLLABLE CENTRALIZED CHAT BUBBLE VIEWPORT ---
            SizedBox(
              height: 650,
              child: ListView.builder(
                itemCount: lastUserPrompt.length,
                itemBuilder: (context, index) {
                  return AiAnswer(
                    answer: answer[index],
                    isLoading: _isLoading,
                    lastUserPrompt: lastUserPrompt[index],
                  );
                },
              ),
            ),

            // --- BOTTOM PREMIUM CONTROL TERMINAL DOCK ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                // FIXED: Shifts color safely depending on your current mode layout
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black38
                        : Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        // FIXED: Replaces background code structure cleanly
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkInputFill
                              : AppColors.inputFill,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextFormField(
                          controller: controller,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                            // FIXED: Sets terminal text styling correctly
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ask Sync AI something...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextBody
                                  : AppColors.textBody,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Interactive Elevated Send Controller Circle
                  GestureDetector(
                    onTap: _talkToGpt,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
