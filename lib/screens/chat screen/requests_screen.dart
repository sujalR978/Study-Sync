import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/services/message_service.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _loopController;

  // UX State
  bool _showHistory = false; // Toggles between Pending and History

  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Cache to prevent flickering when scrolling
  final Map<String, Map<String, dynamic>> _userCache = {};

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
    super.dispose();
  }

  // --- LOGIC: HANDLE REQUEST & SHOW TIME SNACKBAR ---
  void _handleRequest(
    String requestId,
    String senderId,
    String name,
    bool accept,
  ) async {
    // 1. Show immediate UI feedback
    _showActionSnackBar(
      accept ? 'Accepted' : 'Declined',
      name,
      accept ? Colors.green : Colors.redAccent,
      accept ? Icons.check_circle_rounded : Icons.cancel_rounded,
    );

    // 2. Process in Firebase
    try {
      await MessageService().respondToRequest(requestId, senderId, accept);
    } catch (e) {
      debugPrint("Error responding to request: $e");
    }
  }

  // --- LOGIC: RESTORE A DECLINED REQUEST ---
  void _restoreRequest(String requestId, String name) async {
    _showActionSnackBar(
      'Restored',
      name,
      Theme.of(context).colorScheme.primary,
      Icons.restore_rounded,
    );

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
            'status': 'pending',
            'actionTime': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint("Error restoring request: $e");
    }
  }

  // --- NEW LOGIC: PERMANENTLY DELETE A HISTORY RECORD ---
  void _deleteHistoryRecord(String requestId, String name) async {
    _showActionSnackBar(
      'Removed from history',
      name,
      Colors.grey,
      Icons.delete_outline_rounded,
    );

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .delete();
    } catch (e) {
      debugPrint("Error deleting history record: $e");
    }
  }

  // --- REUSABLE SNACKBAR NOTIFICATION ---
  void _showActionSnackBar(
    String actionText,
    String name,
    Color actionColor,
    IconData actionIcon,
  ) {
    final now = DateTime.now();
    String ampm = now.hour >= 12 ? 'PM' : 'AM';
    int hr = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    String min = now.minute.toString().padLeft(2, '0');
    String timeString = "$hr:$min $ampm";

    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(
                  isDark ? 0.8 : 0.9,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: actionColor.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(actionIcon, color: actionColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$actionText: $name",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Action taken at $timeString",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
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
          // BACKGROUND ANIMATION
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

          // MAIN CONTENT
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 85), // Spacer for App Bar
                // --- TOGGLE SWITCH (PENDING vs HISTORY) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.all(4),
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
                            Expanded(
                              child: _buildToggleButton(
                                title: "Pending",
                                isSelected: !_showHistory,
                                onTap: () =>
                                    setState(() => _showHistory = false),
                                primaryColor: primaryColor,
                                onSurfaceColor: onSurfaceColor,
                              ),
                            ),
                            Expanded(
                              child: _buildToggleButton(
                                title: "History",
                                isSelected: _showHistory,
                                onTap: () =>
                                    setState(() => _showHistory = true),
                                primaryColor: primaryColor,
                                onSurfaceColor: onSurfaceColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- REAL FIREBASE LIST VIEW ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('requests')
                        .where(
                          Filter.or(
                            Filter('receiverId', isEqualTo: currentUserId),
                            Filter('senderId', isEqualTo: currentUserId),
                          ),
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState(onSurfaceColor);
                      }

                      // Filter the stream locally based on Pending vs History
                      final targetStatus = _showHistory
                          ? 'declined'
                          : 'pending';

                      var requests = snapshot.data!.docs.where((doc) {
                        return doc['status'] == targetStatus;
                      }).toList();

                      // Sort newest first
                      requests.sort((a, b) {
                        Timestamp? timeA = a['timestamp'] as Timestamp?;
                        Timestamp? timeB = b['timestamp'] as Timestamp?;
                        if (timeA == null || timeB == null) return 0;
                        return timeB.compareTo(timeA);
                      });

                      if (requests.isEmpty) {
                        return _buildEmptyState(onSurfaceColor);
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final reqDoc = requests[index];
                          final data = reqDoc.data() as Map<String, dynamic>;
                          final requestId = reqDoc.id;

                          bool isIncoming = data['receiverId'] == currentUserId;
                          String otherUserId = isIncoming
                              ? data['senderId']
                              : data['receiverId'];

                          return _buildUserCardFuture(
                            requestId: requestId,
                            otherUserId: otherUserId,
                            isIncoming: isIncoming,
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

          // APP BAR WITH BACK BUTTON
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
                                Icons.arrow_back_rounded,
                                color: onSurfaceColor.withOpacity(0.8),
                                size: 20,
                              ),
                            ),
                          ),
                          Text(
                            'Connections',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 44),
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

  // --- FETCH USER DETAILS FOR THE CARD ---
  Widget _buildUserCardFuture({
    required String requestId,
    required String otherUserId,
    required bool isIncoming,
    required Color primaryColor,
    required Color surfaceColor,
    required Color onSurfaceColor,
    required bool isDark,
  }) {
    if (_userCache.containsKey(otherUserId)) {
      return _routeCardBuild(
        requestId,
        otherUserId,
        _userCache[otherUserId]!,
        isIncoming,
        primaryColor,
        surfaceColor,
        onSurfaceColor,
        isDark,
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 100);
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        _userCache[otherUserId] = userData;

        return _routeCardBuild(
          requestId,
          otherUserId,
          userData,
          isIncoming,
          primaryColor,
          surfaceColor,
          onSurfaceColor,
          isDark,
        );
      },
    );
  }

  // --- ROUTE TO CORRECT CARD TYPE ---
  Widget _routeCardBuild(
    String requestId,
    String otherUserId,
    Map<String, dynamic> userData,
    bool isIncoming,
    Color primaryColor,
    Color surfaceColor,
    Color onSurfaceColor,
    bool isDark,
  ) {
    String name = userData['fullname'] ?? 'Unknown User';
    String username = userData['username'] ?? 'no_username';

    if (_showHistory) {
      return _buildHistoryCard(
        requestId,
        otherUserId,
        name,
        username,
        isIncoming,
        primaryColor,
        surfaceColor,
        onSurfaceColor,
        isDark,
      );
    } else {
      return _buildPendingCard(
        requestId,
        otherUserId,
        name,
        username,
        isIncoming,
        primaryColor,
        surfaceColor,
        onSurfaceColor,
        isDark,
      );
    }
  }

  Widget _buildEmptyState(Color onSurfaceColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showHistory ? Icons.history_rounded : Icons.how_to_reg_rounded,
            size: 60,
            color: onSurfaceColor.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _showHistory ? "No declined requests" : "No pending requests",
            style: TextStyle(
              color: onSurfaceColor.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- UI: TOGGLE BUTTON ---
  Widget _buildToggleButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color onSurfaceColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : onSurfaceColor.withOpacity(0.6),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // --- UI: PENDING REQUEST CARD ---
  Widget _buildPendingCard(
    String requestId,
    String otherUserId,
    String name,
    String username,
    bool isIncoming,
    Color primaryColor,
    Color surfaceColor,
    Color onSurfaceColor,
    bool isDark,
  ) {
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
            child: Column(
              children: [
                Row(
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
                  ],
                ),
                const SizedBox(height: 16),

                if (isIncoming) ...[
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handleRequest(
                            requestId,
                            otherUserId,
                            name,
                            false,
                          ), // Decline
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: onSurfaceColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                "Decline",
                                style: TextStyle(
                                  color: onSurfaceColor.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handleRequest(
                            requestId,
                            otherUserId,
                            name,
                            true,
                          ), // Accept
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "Accept",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: onSurfaceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        "Request Pending...",
                        style: TextStyle(
                          color: onSurfaceColor.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI: HISTORY (REJECTED) CARD ---
  Widget _buildHistoryCard(
    String requestId,
    String otherUserId,
    String name,
    String username,
    bool isIncoming,
    Color primaryColor,
    Color surfaceColor,
    Color onSurfaceColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor.withOpacity(isDark ? 0.20 : 0.35),
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
                  radius: 24,
                  backgroundColor: onSurfaceColor.withOpacity(0.05),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: onSurfaceColor.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                          color: onSurfaceColor.withOpacity(0.8),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isIncoming ? "Declined by you" : "Declined",
                        style: TextStyle(
                          color: Colors.redAccent.withOpacity(0.8),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // NEW: ACTIONS ROW IN HISTORY (DELETE & UNDO)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // PERMANENT REMOVE / TRASH BUTTON
                    GestureDetector(
                      onTap: () => _deleteHistoryRecord(requestId, name),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // UNDO BUTTON (Only visible if you were the one who declined it)
                    if (isIncoming)
                      GestureDetector(
                        onTap: () => _restoreRequest(requestId, name),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.restore_rounded,
                                color: primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Undo",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
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
