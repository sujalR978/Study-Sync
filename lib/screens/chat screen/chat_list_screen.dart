import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/screens/chat%20screen/requests_screen.dart';
// / Import Request Screen

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _loopController;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  final Set<String> _sentRequests = {};

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color surfaceColor = theme.colorScheme.surface;
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Dummy variable to show the red dot (change this based on Firebase later)
    bool hasPendingRequests = true;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // --- BACKGROUND ---
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

          // --- MAIN CONTENT ---
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 85),

                // --- SEARCH BAR ---
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
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: onSurfaceColor.withOpacity(0.5),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) => setState(
                                  () => _searchQuery = val.toLowerCase(),
                                ),
                                style: TextStyle(
                                  color: onSurfaceColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search to connect...',
                                  hintStyle: TextStyle(
                                    color: onSurfaceColor.withOpacity(0.4),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- USERS LIST ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                        return Center(
                          child: Text(
                            "No users found.",
                            style: TextStyle(
                              color: onSurfaceColor.withOpacity(0.5),
                            ),
                          ),
                        );

                      var users = snapshot.data!.docs.where((doc) {
                        if (doc.id == currentUserId) return false;
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['fullname'] ?? '')
                            .toString()
                            .toLowerCase();
                        final username = (data['username'] ?? '')
                            .toString()
                            .toLowerCase();
                        return _searchQuery.isEmpty ||
                            name.contains(_searchQuery) ||
                            username.contains(_searchQuery);
                      }).toList();

                      if (users.isEmpty)
                        return Center(
                          child: Text(
                            "No user matches '$_searchQuery'",
                            style: TextStyle(
                              color: onSurfaceColor.withOpacity(0.5),
                            ),
                          ),
                        );

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final userData =
                              users[index].data() as Map<String, dynamic>;
                          return _buildUserCard(
                            userId: users[index].id,
                            name: userData['fullname'] ?? 'Unknown User',
                            username: userData['username'] ?? 'no_username',
                            primaryColor: primaryColor,
                            surfaceColor: surfaceColor,
                            onSurfaceColor: onSurfaceColor,
                            isDark: isDark,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- INSTAGRAM-STYLE APP BAR ---
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          // Title on the left
                          Text(
                            'Messages',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: onSurfaceColor,
                              fontSize: 22,
                              letterSpacing: -0.5,
                            ),
                          ),

                          // Notification Icon on the right (Pushes to Requests Screen)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RequestsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: onSurfaceColor.withOpacity(
                                  isDark ? 0.08 : 0.05,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite_outline_rounded,
                                    color: onSurfaceColor.withOpacity(0.9),
                                    size: 22,
                                  ),
                                  // The Red Badge Dot
                                  if (hasPendingRequests)
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        height: 10,
                                        width: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: surfaceColor,
                                            width: 2,
                                          ),
                                        ),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String userId,
    required String name,
    required String username,
    required Color primaryColor,
    required Color surfaceColor,
    required Color onSurfaceColor,
    required bool isDark,
  }) {
    bool isSent = _sentRequests.contains(userId);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor.withOpacity(isDark ? 0.30 : 0.45),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.03),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: onSurfaceColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "@$username",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (!isSent) setState(() => _sentRequests.add(userId));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSent
                          ? onSurfaceColor.withOpacity(0.1)
                          : primaryColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      isSent ? "Requested" : "Connect",
                      style: TextStyle(
                        color: isSent
                            ? onSurfaceColor.withOpacity(0.6)
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
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
