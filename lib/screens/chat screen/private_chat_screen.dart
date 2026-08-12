import 'dart:convert'; // Required for Base64
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PrivateChatScreen extends StatefulWidget {
  final String roomId;
  final String otherUserName;
  final String otherUserAvatarText;

  const PrivateChatScreen({
    super.key,
    required this.roomId,
    required this.otherUserName,
    required this.otherUserAvatarText,
  });

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  late AnimationController _loopController;

  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    // Clear unread count for the current user when they open the chat
    FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.roomId)
        .update({'unreadCount.$currentUserId': 0});
  }

  @override
  void dispose() {
    _messageController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  // --- SEND TEXT MESSAGE ---
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      // 1. Add message to subcollection
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.roomId)
          .collection('messages')
          .add({
            'senderId': currentUserId,
            'text': text,
            'imageBase64': null,
            'timestamp': FieldValue.serverTimestamp(),
          });

      // 2. Fetch the chat room to find the other user's ID
      final roomDoc = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.roomId)
          .get();
      List<dynamic> users = roomDoc.data()?['users'] ?? [];
      String otherUserId = users.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      // 3. Update last message AND increment the other user's unread badge count
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.roomId)
          .update({
            'lastMessage': text,
            'lastMessageTime': FieldValue.serverTimestamp(),
            'unreadCount.$otherUserId': FieldValue.increment(
              1,
            ), // Increments unread count for the offline user!
          });
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  // --- SEND BASE64 IMAGE ---
  Future<void> _pickAndSendImage() async {
    try {
      // 1. Pick and heavily compress the image (Firestore has a 1MB document limit)
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40, // High compression
        maxWidth: 800, // Resize to prevent massive Base64 strings
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      // 2. Read file as Bytes and convert to Base64 String
      final bytes = await File(image.path).readAsBytes();
      final String base64String = base64Encode(bytes);

      // Check if it's too large for Firestore (~1MB limit, keeping it under 900KB to be safe)
      if (base64String.length > 900000) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Image is too large. Please select a smaller one."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        setState(() => _isUploading = false);
        return;
      }

      // 3. Save directly to Firestore (No Firebase Storage needed!)
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.roomId)
          .collection('messages')
          .add({
            'senderId': currentUserId,
            'text': '',
            'imageBase64': base64String, // Store string instead of URL
            'timestamp': FieldValue.serverTimestamp(),
          });

      // 4. Update Inbox
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.roomId)
          .update({
            'lastMessage': '📷 Image',
            'lastMessageTime': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint("Error converting image: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color surfaceColor = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // --- BACKGROUND ANIMATION ---
          AnimatedBuilder(
            animation: _loopController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: 100 + (35 * sin(_loopController.value * 2 * pi)),
                    left: -40 + (30 * cos(_loopController.value * 2 * pi)),
                    child: _buildAmbientGlow(primaryColor, isDark),
                  ),
                  Positioned(
                    bottom: 80 - (35 * sin(_loopController.value * 2 * pi)),
                    right: -50 + (30 * cos(_loopController.value * 2 * pi)),
                    child: _buildAmbientGlow(secondaryColor, isDark),
                  ),
                ],
              );
            },
          ),

          // --- MESSAGES LIST ---
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 85),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chat_rooms')
                        .doc(widget.roomId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "Say hi! 👋",
                            style: TextStyle(
                              color: onSurfaceColor.withOpacity(0.5),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        reverse: true,
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 100,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msgDoc = messages[index];
                          final msgData = msgDoc.data() as Map<String, dynamic>;

                          bool isMe = msgData['senderId'] == currentUserId;
                          String text = msgData['text'] ?? '';
                          String? imageBase64 = msgData['imageBase64'];

                          // Pass msgDoc.id to use as a unique Hero Tag for full-screen animation
                          return _buildChatBubble(
                            msgDoc.id,
                            text,
                            imageBase64,
                            isMe,
                            primaryColor,
                            surfaceColor,
                            onSurfaceColor,
                            isDark,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- APP BAR ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(isDark ? 0.35 : 0.65),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: onSurfaceColor.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: onSurfaceColor.withOpacity(
                                  isDark ? 0.08 : 0.05,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: onSurfaceColor.withOpacity(0.8),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: primaryColor.withOpacity(0.2),
                            child: Text(
                              widget.otherUserAvatarText,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.otherUserName,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                              fontSize: 16,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- BOTTOM TEXT & IMAGE INPUT FIELD ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(isDark ? 0.45 : 0.75),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black.withOpacity(0.08),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // --- IMAGE PICKER BUTTON ---
                        _isUploading
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: _pickAndSendImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: onSurfaceColor.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: primaryColor,
                                    size: 22,
                                  ),
                                ),
                              ),
                        const SizedBox(width: 8),

                        // --- TEXT FIELD ---
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: TextStyle(
                              color: onSurfaceColor,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                color: onSurfaceColor.withOpacity(0.4),
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),

                        // --- SEND BUTTON ---
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor],
                              ),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DYNAMIC CHAT BUBBLE (HANDLES TEXT & BASE64 IMAGES) ---
  Widget _buildChatBubble(
    String messageId,
    String text,
    String? imageBase64,
    bool isMe,
    Color primaryColor,
    Color surfaceColor,
    Color onSurfaceColor,
    bool isDark,
  ) {
    bool isImageMessage = imageBase64 != null && imageBase64.isNotEmpty;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isMe ? 24 : 6),
            bottomRight: Radius.circular(isMe ? 6 : 24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: isImageMessage
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isMe
                    ? primaryColor.withOpacity(0.85)
                    : surfaceColor.withOpacity(isDark ? 0.3 : 0.6),
                border: Border.all(
                  color: isMe
                      ? Colors.transparent
                      : (isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.05)),
                  width: 1.2,
                ),
              ),
              child: isImageMessage
                  // Render Base64 Image with tap-to-expand
                  ? GestureDetector(
                      onTap: () {
                        // Open Full Screen Viewer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImageViewer(
                              base64String: imageBase64,
                              heroTag: messageId,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag:
                            messageId, // Hero animation links the thumbnail to the full screen
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            base64Decode(imageBase64),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  // Render Text
                  : Text(
                      text,
                      style: TextStyle(
                        color: isMe ? Colors.white : onSurfaceColor,
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmbientGlow(Color color, bool isDark) {
    return Container(
      height: 280,
      width: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(isDark ? 0.08 : 0.04),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.06 : 0.03),
            blurRadius: 70,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// NEW: FULL-SCREEN IMAGE VIEWER
// =====================================================================
class FullScreenImageViewer extends StatelessWidget {
  final String base64String;
  final String heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.base64String,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for viewing images
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        // InteractiveViewer adds pinch-to-zoom and panning capabilities!
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0, // Allow user to zoom in 4x
          child: Hero(
            tag: heroTag,
            child: Image.memory(
              base64Decode(base64String),
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
