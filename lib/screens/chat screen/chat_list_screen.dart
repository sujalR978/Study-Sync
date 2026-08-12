
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// Dummy Model for Users (Replace with your Firebase User Model later)
class ChatUser {
  final String id;
  final String name;
  final String username;
  final String lastMessage;
  final bool isOnline;
  final String time;

  ChatUser({
    required this.id,
    required this.name,
    required this.username,
    required this.lastMessage,
    required this.isOnline,
    required this.time,
  });
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _loopController;
  final TextEditingController _searchController = TextEditingController();

  // Dummy Data
  final List<ChatUser> _allUsers = [
    ChatUser(id: '1', name: 'Alex Johnson', username: 'alexj', lastMessage: 'Did you finish the math notes?', isOnline: true, time: '2m ago'),
    ChatUser(id: '2', name: 'Sarah Connor', username: 'sarah_c', lastMessage: 'Let\'s study at 5 PM!', isOnline: true, time: '1h ago'),
    ChatUser(id: '3', name: 'Michael Smith', username: 'mike99', lastMessage: 'Thanks for the help! 🙌', isOnline: false, time: 'Yesterday'),
    ChatUser(id: '4', name: 'Emma Davis', username: 'emma_d', lastMessage: 'Sent an attachment', isOnline: false, time: 'Mon'),
    ChatUser(id: '5', name: 'David Lee', username: 'david_l', lastMessage: 'Are we still on for tomorrow?', isOnline: true, time: 'Tue'),
  ];

  List<ChatUser> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = _allUsers;

    // Background ambient loop
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _loopController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter logic for the search bar
  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() => _filteredUsers = _allUsers);
    } else {
      setState(() {
        _filteredUsers = _allUsers.where((user) => 
          user.username.toLowerCase().contains(query.toLowerCase()) || 
          user.name.toLowerCase().contains(query.toLowerCase())
        ).toList();
      });
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
          // ===================================================================
          // --- 1. CYCLIC LOOP BACKGROUND ---
          // ===================================================================
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

          // ===================================================================
          // --- 2. MAIN SCROLLING CONTENT ---
          // ===================================================================
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 85), // Spacer for Floating App Bar

                // --- SEARCH BAR PILL ---
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
                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: onSurfaceColor.withOpacity(0.5), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: _filterUsers,
                                style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'Search by @username or name...',
                                  hintStyle: TextStyle(color: onSurfaceColor.withOpacity(0.4), fontSize: 14),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _filterUsers('');
                                },
                                child: Icon(Icons.close_rounded, color: onSurfaceColor.withOpacity(0.5), size: 20),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // --- ACTIVE NOW HORIZONTAL LIST (Optional, but looks great!) ---
                if (_searchController.text.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "ACTIVE NOW",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: onSurfaceColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _allUsers.where((u) => u.isOnline).length,
                      itemBuilder: (context, index) {
                        final onlineUsers = _allUsers.where((u) => u.isOnline).toList();
                        return _buildActiveUserBubble(onlineUsers[index], primaryColor, onSurfaceColor);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                      thickness: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // --- USER LIST VIEW ---
                Expanded(
                  child: _filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          "No users found.",
                          style: TextStyle(color: onSurfaceColor.withOpacity(0.5), fontWeight: FontWeight.w600),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          return _buildUserChatCard(_filteredUsers[index], primaryColor, surfaceColor, onSurfaceColor, isDark);
                        },
                      ),
                ),
              ],
            ),
          ),

          // ===================================================================
          // --- 3. FLOATING PILL APP BAR ---
          // ===================================================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                          // Back Button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: onSurfaceColor.withOpacity(isDark ? 0.08 : 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_back_rounded, color: onSurfaceColor.withOpacity(0.8), size: 20),
                            ),
                          ),

                          // Title
                          Text(
                            'Messages',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                          ),

                          // Add/Search Button
                          GestureDetector(
                            onTap: () {
                              // Optional: Bring focus to search bar
                            },
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_comment_rounded, color: primaryColor, size: 20),
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

  // --- WIDGET: INDIVIDUAL CHAT CARD ---
  Widget _buildUserChatCard(ChatUser user, Color primaryColor, Color surfaceColor, Color onSurfaceColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate to actual 1-on-1 chat screen (You will build this next!)
                print("Clicked on ${user.name}");
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor.withOpacity(isDark ? 0.30 : 0.45),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar with online status indicator
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: primaryColor.withOpacity(0.2),
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        if (user.isOnline)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              height: 12,
                              width: 12,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: surfaceColor, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Name & Message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              Text(
                                user.time,
                                style: TextStyle(color: onSurfaceColor.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "@${user.username}",
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: onSurfaceColor.withOpacity(0.6), fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET: ACTIVE USER BUBBLE ---
  Widget _buildActiveUserBubble(ChatUser user, Color primaryColor, Color onSurfaceColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Text(
                user.name[0].toUpperCase(),
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.name.split(' ')[0], // Only show first name
            style: TextStyle(color: onSurfaceColor.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Helper widget for background glows
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