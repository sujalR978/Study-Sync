import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_sync/API/get_open_router_response.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/services/chat_service.dart';
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
  List<List<XFile>> messageImagesHistory = [];
  List<Map<String, String>> messages = [];

  List<XFile> selectedImage = [];
  bool images = false;

  Future<void> loadChat() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chats')
        .orderBy('timestamp')
        .get();

    lastUserPrompt.clear();
    answer.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) continue;

      if (data['roal'] == 'user') {
        lastUserPrompt.add(data['content']?.toString() ?? '');
      } else if (data['roal'] == 'Ai') {
        answer.add(data['content']?.toString() ?? '');
      }
    }
    setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  void _talkToGpt() async {
    if (controller.text.trim().isEmpty) return;

    final String prompt = controller.text.trim();
    controller.clear();

    setState(() {
      _isLoading = true;

      ChatService().addChat(
        roal: 'user',
        content: prompt,
        timestamp: Timestamp.now(),
      );
      // lastUserPrompt.add(prompt);
      messageImagesHistory.add([]);
      messages.add({"role": "user", "content": prompt});
    });

    try {
      String theAnswer = await getOpenRouterResponse(messages);

      setState(() {
        ChatService().addChat(
          roal: 'Ai',
          content: theAnswer,
          timestamp: Timestamp.now(),
        );

        // answer.add(theAnswer);
        _isLoading = false;
        messages.add({"role": "assistant", "content": theAnswer});
      });
    } catch (e) {
      setState(() {
        answer.add("Error connecting to server. Please try again.");
        _isLoading = false;
      });
    }
  }

  void _talkToGpt40() async {
    if (controller.text.trim().isEmpty) return;

    final String prompt = controller.text.trim();
    final List<XFile> imagesToSend = List.from(
      selectedImage,
    ); // Copy chosen elements safely

    controller.clear();
    setState(() {
      _isLoading = true;
      lastUserPrompt.add(prompt);
      messageImagesHistory.add(imagesToSend);
      selectedImage
          .clear(); // Clear local UI queue instantly for responsive feel
    });

    try {
      String theAnswer = await getOpenRouterResponseForGpt40(
        prompt,
        imagesToSend,
      );

      setState(() {
        answer.add(theAnswer);
        _isLoading = false;
        // Keep context history updated if needed
        messages.add({"role": "user", "content": prompt});
        messages.add({"role": "assistant", "content": theAnswer});
      });
    } catch (e) {
      print("THE ACTUAL API CRASH REASON IS: $e");
      setState(() {
        answer.add("Error analyzing images. Please verify your file payload.");
        _isLoading = false;
      });
    }
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Sync AI Studio",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 0.2,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onBackground,
            size: 18,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const Bottomnavigation()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Welcome Card Area
            if (lastUserPrompt.isEmpty && answer.isEmpty && !_isLoading)
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
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
                        color: isDark
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            // Scrollable Chat Message History Block Viewport
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: answer.length,
                itemBuilder: (context, index) {
                  // Safe indexing protection guard rails
                  if (index >= lastUserPrompt.length)
                    return const SizedBox.shrink();
                  return AiAnswer(
                    answer: answer[index],
                    isLoading: false,
                    lastUserPrompt: lastUserPrompt[index],
                    // selectedimages: messageImagesHistory[index],
                  );
                },
              ),
            ),

            // Network Action Progress Thinking Status Ring Tracker
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
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
              ),

            // Image Preview Terminal Docking Shelf Component
            if (selectedImage.isNotEmpty)
              Container(
                height: 90,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImage.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkInputFill
                                  : AppColors.inputFill,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(selectedImage[index].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImage.removeAt(index);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black87,
                              child: Icon(
                                Icons.close,
                                size: 12,
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

            // --- BOTTOM CONTROL TERMINAL DOCK ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
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

                  // Image Selection Attachment Trigger Pin
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

                  // Interactive Elevated Dynamic Send Execution Node
                  GestureDetector(
                    onTap: () {
                      if (selectedImage.isNotEmpty) {
                        _talkToGpt40();
                      } else {
                        _talkToGpt();
                      }
                    },
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
