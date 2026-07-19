import 'dart:io';
import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_sync/API/get_open_router_response.dart';

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

  bool _isClearPressed = false;
  bool _isImagePickPressed = false;
  bool _isSendPressed = false;

  // Preset smart study prompts that users can tap instantly
  final List<String> _quickPrompts = [
    "📝 Summarize my notes",
    "⏰ Make a study plan",
    "💻 Debug my Java code",
    "📚 Explain Memory Paging",
  ];

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
          temporaryUserImages = data['images'] != null
              ? List<String>.from(data['images'])
              : [];
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
      String theAnswer = await getOpenRouterResponseForGpt40(
        prompt,
        base64ImageStrings,
      );
      String uid = FirebaseAuth.instance.currentUser!.uid;

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
      _isLoading = false;
    });
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final CollectionReference conllectionRef = FirebaseFirestore.instance
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
        base64Strings.add("data:image/$extension;base64,$base64String");
      } catch (e) {
        print("Error converting image: $e");
      }
    }
    return base64Strings;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color surfaceColor = theme.colorScheme.surface;

    final Color dynamicTextBody = onSurfaceColor.withOpacity(0.55);
    final Color dynamicInputFill = Color.alphaBlend(
      primaryColor.withOpacity(isDark ? 0.12 : 0.06),
      surfaceColor,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.02),
                width: 1.0,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 70,
            centerTitle: true,
            title: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [primaryColor, secondaryColor],
              ).createShader(bounds),
              child: const Text(
                'Sync AI Studio',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            leadingWidth: 72,
            leading: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(isDark ? 0.35 : 0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.04),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: onSurfaceColor.withOpacity(0.8),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isClearPressed = true),
                    onTapUp: (_) => setState(() => _isClearPressed = false),
                    onTapCancel: () => setState(() => _isClearPressed = false),
                    onTap: () async => await deleteChat(),
                    child: AnimatedScale(
                      scale: _isClearPressed ? 0.94 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.black.withOpacity(0.03),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // NEW BACKGROUND DESIGN: Multiplex Cosmic Light emitters changing dynamically with the 8 active themes
          Positioned(
            top: -20,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withOpacity(isDark ? 0.08 : 0.05),
              ),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 65, sigmaY: 65),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            left: -80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              height: 320,
              width: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(isDark ? 0.07 : 0.04),
              ),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // NEW WIDGET: Realtime System Diagnostic Stripe
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 20,
                  ),
                  color: primaryColor.withOpacity(0.04),
                  child: Row(
                    children: [
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "ENGINE ONLINE  |  CONTEXT DYNAMIC",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor.withOpacity(0.4),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- CHAT WINDOW DATA MESH ---
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
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

                // --- THINKING LOADER INDICATOR ---
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: surfaceColor.withOpacity(
                                isDark ? 0.35 : 0.45,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.black.withOpacity(0.03),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Thinking...",
                                  style: TextStyle(
                                    color: dynamicTextBody,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // NEW WIDGET: Horizontal Study Prompt Shortcuts
                if (lastUserPrompt.isEmpty && answer.isEmpty && !_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _quickPrompts.length,
                        itemBuilder: (context, idx) {
                          return GestureDetector(
                            onTap: () => controller.text = _quickPrompts[idx]
                                .substring(3),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: surfaceColor.withOpacity(
                                  isDark ? 0.25 : 0.55,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.black.withOpacity(0.04),
                                  width: 1.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _quickPrompts[idx],
                                style: TextStyle(
                                  color: onSurfaceColor.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // --- MULTIMODAL HORIZONTAL IMAGE PREVIEW MESH ---
                if (selectedImage.isNotEmpty)
                  Container(
                    height: 94,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImage.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color.alphaBlend(
                                    primaryColor.withOpacity(
                                      isDark ? 0.15 : 0.08,
                                    ),
                                    surfaceColor,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  File(selectedImage[index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 14,
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => selectedImage.removeAt(index),
                                ),
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

                // --- INTEGRATED ACRYLIC INPUT MESH DOCK ---
                // --- UPGRADED HIFI ULTRA-TRANSLUCENT INTEGRATED ACRYLIC INPUT DOCK ---
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 24,
                      sigmaY: 24,
                    ), // Intensified blur for frosted premium transparency
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      decoration: BoxDecoration(
                        // Reduced opacity down to 0.25 for a true transparent glass reflection
                        color: surfaceColor.withOpacity(isDark ? 0.25 : 0.35),
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.12)
                                : Colors.black.withOpacity(0.05),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                // Blends cleanly with the blurred sheet beneath it
                                color: dynamicInputFill.withOpacity(
                                  isDark ? 0.4 : 0.6,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.04)
                                      : Colors.black.withOpacity(0.02),
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                child: TextFormField(
                                  controller: controller,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  style: TextStyle(
                                    color: onSurfaceColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Ask Sync AI something...',
                                    hintStyle: TextStyle(
                                      color: onSurfaceColor.withOpacity(0.35),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // --- ATTACH UTILITY RADIAL BUTTON ---
                          GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _isImagePickPressed = true),
                            onTapUp: (_) =>
                                setState(() => _isImagePickPressed = false),
                            onTapCancel: () =>
                                setState(() => _isImagePickPressed = false),
                            onTap: _pickImages,
                            child: AnimatedScale(
                              scale: _isImagePickPressed ? 0.92 : 1.0,
                              duration: const Duration(milliseconds: 100),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.black.withOpacity(0.04),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.black.withOpacity(0.02),
                                    width: 1.0,
                                  ),
                                ),
                                child: Icon(
                                  Icons.image_rounded,
                                  color: onSurfaceColor.withOpacity(0.75),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // --- TRANSMIT LAYER BUTTON ---
                          GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _isSendPressed = true),
                            onTapUp: (_) =>
                                setState(() => _isSendPressed = false),
                            onTapCancel: () =>
                                setState(() => _isSendPressed = false),
                            onTap: () {
                              if (selectedImage.isNotEmpty) {
                                _talkToGpt40();
                              } else {
                                _talkToGpt();
                              }
                            },
                            child: AnimatedScale(
                              scale: _isSendPressed ? 0.92 : 1.0,
                              duration: const Duration(milliseconds: 100),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, secondaryColor],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
