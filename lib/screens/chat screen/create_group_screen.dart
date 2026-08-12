import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/services/message_service.dart';
// Make sure this path is correct for your project
import 'package:study_sync/widgets/profile_avatar.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _loopController;
  final TextEditingController _groupNameController = TextEditingController();

  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final Set<String> _selectedMemberIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _loopController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  void _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a group name"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one member"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await MessageService().createGroupChat(
        groupName,
        _selectedMemberIds.toList(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Group created successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error creating group: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 85),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: surfaceColor.withOpacity(isDark ? 0.35 : 0.55),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.04),
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _groupNameController,
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter Group Name...',
                            hintStyle: TextStyle(
                              color: onSurfaceColor.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "SELECT ACCEPTED FRIENDS (${_selectedMemberIds.length})",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: onSurfaceColor.withOpacity(0.5),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('requests')
                        .where('status', isEqualTo: 'accepted')
                        .where(
                          Filter.or(
                            Filter('senderId', isEqualTo: currentUserId),
                            Filter('receiverId', isEqualTo: currentUserId),
                          ),
                        )
                        .snapshots(),
                    builder: (context, requestSnapshot) {
                      if (requestSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      }

                      if (!requestSnapshot.hasData ||
                          requestSnapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "No accepted friends yet.\nConnect with users first!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: onSurfaceColor.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      List<String> friendIds = [];
                      for (var doc in requestSnapshot.data!.docs) {
                        String senderId = doc['senderId'];
                        String receiverId = doc['receiverId'];
                        String friendId = (senderId == currentUserId)
                            ? receiverId
                            : senderId;
                        friendIds.add(friendId);
                      }

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where(FieldPath.documentId, whereIn: friendIds)
                            .snapshots(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            );
                          }

                          final users = userSnapshot.data!.docs;

                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final userData =
                                  users[index].data() as Map<String, dynamic>;
                              final userId = users[index].id;
                              final name = userData['fullname'] ?? 'Unknown';
                              final username = userData['username'] ?? 'user';
                              final photoUrl =
                                  userData['photoUrl'] ?? ''; // Access photoUrl
                              final isSelected = _selectedMemberIds.contains(
                                userId,
                              );

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 12,
                                      sigmaY: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: surfaceColor.withOpacity(
                                          isDark ? 0.25 : 0.4,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? primaryColor
                                              : (isDark
                                                    ? Colors.white10
                                                    : Colors.black12),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: CheckboxListTile(
                                        activeColor: primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        title: Text(
                                          name,
                                          style: TextStyle(
                                            color: onSurfaceColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "@$username",
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        // --- UPDATED TO USE PROFILE AVATAR ---
                                        secondary: ProfileAvatar(
                                          photoUrl: photoUrl,
                                          radius: 20,
                                        ),
                                        value: isSelected,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedMemberIds.add(userId);
                                            } else {
                                              _selectedMemberIds.remove(userId);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Icons.close_rounded,
                                color: onSurfaceColor.withOpacity(0.8),
                                size: 20,
                              ),
                            ),
                          ),
                          Text(
                            'Create Group',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading ? null : _createGroup,
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Create",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
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
          ),
        ],
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
