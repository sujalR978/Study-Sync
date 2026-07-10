import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_sync/API/get_open_router_response.dart';
import 'package:study_sync/constants/app_colors.dart'; 

import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/services/chat_service.dart';
import 'package:study_sync/widgets/Ai_answer.dart';

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
  List<List<String>> messageImagesHistory = [];
  List<Map<String, String>> messages = [];

  List<XFile> selectedImage = [];
  bool images = false;

  @override
  void initState() {
    super.initState();
    loadChat();
  }

  Future<void> loadChat() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chats')
          .orderBy('timestamp', descending: false)
          .get();

      lastUserPrompt.clear();
      answer.clear();
      messageImagesHistory.clear();
      messages.clear();

      String temporaryUserPrompt = "";
      List<String> temporaryUserImages = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        String role = data['roal']?.toString() ?? '';
        String content = data['content']?.toString() ?? '';

        if (role == 'user') {
          temporaryUserPrompt = content;

          if (data['images'] != null) {
            temporaryUserImages = List<String>.from(data['images']);
          } else {
            temporaryUserImages = [];
          }

          messages.add({"role": "user", "content": content});
        } else if (role == 'Ai') {
          lastUserPrompt.add(
            temporaryUserPrompt.isNotEmpty
                ? temporaryUserPrompt
                : "Multimodal Query",
          );
          answer.add(content);
          messageImagesHistory.add(List.from(temporaryUserImages));
          messages.add({"role": "assistant", "content": content});

          temporaryUserPrompt = "";
          temporaryUserImages = [];
        }
      }
    } catch (e) {
      print("Error fetching database documents sequence: $e");
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _talkToGpt() async {
    if (controller.text.trim().isEmpty) return;

    final String prompt = controller.text.trim();
    controller.clear();

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      lastUserPrompt.add(prompt);
      messageImagesHistory.add(<String>[]);
      messages.add({"role": "user", "content": prompt});
    });

    await ChatService().addChat(
      roal: 'user',
      content: prompt,
      timestamp: Timestamp.now(),
    );

    try {
      String theAnswer = await getOpenRouterResponse(messages);

      await ChatService().addChat(
        roal: 'Ai',
        content: theAnswer,
        timestamp: Timestamp.now(),
      );

      if (!mounted) return;
      setState(() {
        answer.add(theAnswer);
        _isLoading = false;
        messages.add({"role": "assistant", "content": theAnswer});
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        answer.add("Error connecting to server. Please try again.");
        _isLoading = false;
      });
    }
  }

  void _talkToGpt40() async {
    if (controller.text.trim().isEmpty) return;

    final String prompt = controller.text.trim();
    final List<XFile> imagesToSend = List.from(selectedImage);

    controller.clear();

    // 1. Process local image compression parsing stages first
    List<String> base64ImageStrings = await _convertImagesToBase64(
      imagesToSend,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      lastUserPrompt.add(prompt);
      messageImagesHistory.add(base64ImageStrings);
      selectedImage.clear(); 
    });

    try {
      // 2. Push pre-converted string arrays directly down to OpenRouter
      String theAnswer = await getOpenRouterResponseForGpt40(
        prompt,
        base64ImageStrings,
      );

      String uid = FirebaseAuth.instance.currentUser!.uid;

      // 3. Document the User's transaction block parameters inside Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chats')
          .add({
            'roal': 'user',
            'content': prompt,
            'images': base64ImageStrings,
            'timestamp': Timestamp.now(),
          });

      // 4. Record responding completion turns inside Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chats')
          .add({
            'roal': 'Ai',
            'content': theAnswer,
            'images': [],
            'timestamp': Timestamp.now(),
          });

      if (!mounted) return;
      setState(() {
        answer.add(theAnswer);
        _isLoading = false;
        messages.add({"role": "user", "content": prompt});
        messages.add({"role": "assistant", "content": theAnswer});
      });
    } catch (e) {
      print("THE ACTUAL API CRASH REASON IS: $e");
      if (!mounted) return;
      setState(() {
        answer.add("Error analyzing images. Please verify your file payload.");
        _isLoading = false;
      });
    }
  }

  Future _pickImages() async {
    final image = await ImagePicker().pickMultiImage(
      maxWidth: 600,
      imageQuality: 70,
    );

    if (image.isNotEmpty) {
      setState(() {
        selectedImage.addAll(image);
        images = true;
      });
    }
  }

  Future<void> deleteChat() async {
    setState(() {
      answer.clear();
      lastUserPrompt.clear();
      messageImagesHistory.clear();
      messages.clear();
      _isLoading = false; // Stop any active loading indicators
    });
    String uid = FirebaseAuth.instance.currentUser!.uid;

    final CollectionReference conllectionRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chats');

    QuerySnapshot snapshot = await conllectionRef.get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (DocumentSnapshot doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<List<String>> _convertImagesToBase64(List<XFile> images) async {
    List<String> base64Strings = [];

    for (XFile image in images) {
      try {
        final List<int> imageBytes = await image.readAsBytes();
        final String base64String = base64Encode(imageBytes);

        String extension = image.path.split('.').last.toLowerCase();
        if (extension == 'jpg') extension = 'jpeg';

        String fullBase64DataUri = "data:image/$extension;base64,$base64String";
        base64Strings.add(fullBase64DataUri);
      } catch (e) {
        print("Error converting image to Base64 text string: $e");
      }
    }
    return base64Strings;
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
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () async {
                await deleteChat();
              },
              child: Text(
                'Clear',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: answer.length,
                itemBuilder: (context, index) {
                  if (index >= lastUserPrompt.length ||
                      index >= messageImagesHistory.length) {
                    return const SizedBox.shrink();
                  }
                  return AiAnswer(
                    answer: answer[index],
                    isLoading: false,
                    lastUserPrompt: lastUserPrompt[index],
                    selectedimages: messageImagesHistory[index],
                  );
                },
              ),
            ),

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
