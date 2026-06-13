import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  List<String> answer = [];
  bool _isLoading = false;
  List<String> lastUserPrompt = [];

  List<Map<String, String>> messages = [];

  List<XFile> selectedImage = [];
  bool images = false;

  void _talkToGpt() async {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      lastUserPrompt.add(controller.text);
      messages.add({"role": "user", "content": controller.text});
    });

    String theAnswer = await getOpenRouterResponse(messages);

    setState(() {
      answer.add(theAnswer);
      _isLoading = false;
      messages.add({"role": "assistant", "content": theAnswer});
    });

    controller.clear();
  }

  Future _pickImages() async {
    final image = await ImagePicker().pickMultiImage();

    if (image.isNotEmpty) {
      setState(() {
        selectedImage.addAll(image);
        images = true;
      });
    }
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

            Flexible(
              child: SizedBox(
                height: 700,
                child: ListView.builder(
                  itemCount: answer.length,
                  itemBuilder: (context, index) {
                    return AiAnswer(
                      answer: answer[index],
                      isLoading: _isLoading,
                      lastUserPrompt: lastUserPrompt[index],
                    );
                  },
                ),
              ),
            ),

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
                          color: isDark
                              ? AppColors.darkTextBody
                              : AppColors.textBody,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (selectedImage.isNotEmpty)
              SizedBox(
                height: 200,
                width: 300,

                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),

                  itemCount: selectedImage.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        // Render image asset container frame
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(selectedImage[index].path),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Action overlay button UI component to delete images individualistically
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImage.removeAt(index);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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

                  GestureDetector(
                    onTap: _pickImages,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 20,
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
