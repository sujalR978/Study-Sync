import 'package:flutter/material.dart';
import 'package:study_sync/API/get_open_router_response.dart';
import 'package:study_sync/constants/app_colors.dart'; // Make sure this path is correct

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController controller = TextEditingController();
  String answer = '';
  bool _isLoading = false; 
  String lastUserPrompt = ''; 

  void _talkToGpt() async {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      lastUserPrompt = controller.text;
      answer = ''; 
    });

    String theAnswer = await getOpenRouterResponse(controller.text);

    setState(() {
      answer = theAnswer;
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
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 20,
            ),
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- SCROLLABLE CENTRALIZED CHAT BUBBLE VIEWPORT ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // Initial Welcome Screen Matrix Card if no prompt has run yet
                    if (lastUserPrompt.isEmpty && answer.isEmpty && !_isLoading)
                      Container(
                        margin: const EdgeInsets.only(top: 40),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          // FIXED: Reads system card surface settings cleanly
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black26 : Colors.black.withOpacity(0.02),
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
                                color: isDark ? AppColors.darkTextBody : AppColors.textBody,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 1. --- USER PROMPT BUBBLE ---
                    if (lastUserPrompt.isNotEmpty)
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
                            lastUserPrompt,
                            style: const TextStyle(
                              color: Colors.white, // Text remains white on primary background
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),

                    // 2. --- NETWORK TYPING LOADER STATUS BLOCK ---
                    if (_isLoading)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20, right: 80),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            // FIXED: Uses surface container color safely
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Thinking...",
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextBody : AppColors.textBody,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 3. --- SYSTEM AI ANSWER RESPONDER BUBBLE ---
                    if (answer.isNotEmpty)
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
                                      color: isDark ? AppColors.darkTextBody.withOpacity(0.7) : AppColors.textBody.withOpacity(0.7),
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
                                answer,
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
            ),

            // --- BOTTOM PREMIUM CONTROL TERMINAL DOCK ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                // FIXED: Shifts color safely depending on your current mode layout
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black38 : Colors.black.withOpacity(0.04),
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
                          color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
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
                              color: isDark ? AppColors.darkTextBody : AppColors.textBody,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
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