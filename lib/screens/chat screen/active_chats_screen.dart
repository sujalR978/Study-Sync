import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/screens/chat%20screen/chat_list_screen.dart';
import 'package:study_sync/screens/chat%20screen/create_group_screen.dart';
import 'package:study_sync/screens/chat%20screen/private_chat_screen.dart';
import 'package:study_sync/screens/chat%20screen/requests_screen.dart';


import 'package:study_sync/services/message_service.dart';

class ActiveChatsScreen extends StatefulWidget {
  const ActiveChatsScreen({super.key});

  @override
  State<ActiveChatsScreen> createState() => _ActiveChatsScreenState();
}

class _ActiveChatsScreenState extends State<ActiveChatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _loopController;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  // Filter Tab State: 'all', 'direct', or 'group'
  String _currentFilter = 'all';

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

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays == 0 && now.day == date.day) {
      String ampm = date.hour >= 12 ? 'PM' : 'AM';
      int hr = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      String min = date.minute.toString().padLeft(2, '0');
      return "$hr:$min $ampm";
    } else if (diff.inDays == 1 || (diff.inDays == 0 && now.day != date.day)) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
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

          // MAIN ACTIVE CHATS LIST
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 85), 

                // --- FILTER PILL TABS (All, Direct, Groups) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      _buildFilterChip("All", 'all', primaryColor, surfaceColor, onSurfaceColor, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip("Direct", 'direct', primaryColor, surfaceColor, onSurfaceColor, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip("Groups", 'group', primaryColor, surfaceColor, onSurfaceColor, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chat_rooms')
                        .where('users', arrayContains: currentUserId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text("Error loading chats.", style: TextStyle(color: Colors.redAccent)));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: primaryColor));
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState(primaryColor, onSurfaceColor);
                      }

                      // Filter and Sort chat rooms locally
                      final chatRooms = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        bool isGroup = data['isGroup'] == true;

                        if (_currentFilter == 'direct') return !isGroup;
                        if (_currentFilter == 'group') return isGroup;
                        return true; // 'all'
                      }).toList();

                      chatRooms.sort((a, b) {
                        final dataA = a.data() as Map<String, dynamic>;
                        final dataB = b.data() as Map<String, dynamic>;
                        Timestamp? timeA = dataA['lastMessageTime'] as Timestamp?;
                        Timestamp? timeB = dataB['lastMessageTime'] as Timestamp?;
                        if (timeA == null && timeB == null) return 0;
                        if (timeA == null) return 1;
                        if (timeB == null) return -1;
                        return timeB.compareTo(timeA);
                      });

                      if (chatRooms.isEmpty) {
                        return Center(child: Text("No chats in this filter", style: TextStyle(color: onSurfaceColor.withOpacity(0.5), fontWeight: FontWeight.bold)));
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        itemCount: chatRooms.length,
                        itemBuilder: (context, index) {
                          final room = chatRooms[index];
                          final roomData = room.data() as Map<String, dynamic>;
                          bool isGroup = roomData['isGroup'] == true;

                          if (isGroup) {
                            return _buildGroupChatCard(
                              roomId: room.id,
                              roomData: roomData,
                              primaryColor: primaryColor,
                              surfaceColor: surfaceColor,
                              onSurfaceColor: onSurfaceColor,
                              isDark: isDark,
                            );
                          } else {
                            List<dynamic> users = roomData['users'] ?? [];
                            String otherUserId = users.firstWhere((id) => id != currentUserId, orElse: () => '');

                            if (otherUserId.isEmpty) return const SizedBox.shrink();

                            return _buildChatCardFuture(
                              roomId: room.id,
                              otherUserId: otherUserId,
                              roomData: roomData,
                              primaryColor: primaryColor,
                              surfaceColor: surfaceColor,
                              onSurfaceColor: onSurfaceColor,
                              isDark: isDark,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // APP BAR
          Positioned(
            top: 0, left: 0, right: 0,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(isDark ? 0.35 : 0.65),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: onSurfaceColor.withOpacity(0.08), width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Inbox', style: TextStyle(fontWeight: FontWeight.w900, color: onSurfaceColor, fontSize: 22, letterSpacing: -0.5)),

                          Row(
                            children: [
                              // Add Friend Button
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen())),
                                child: Container(
                                  height: 44, width: 44,
                                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(Icons.person_add_alt_1_rounded, color: primaryColor, size: 20),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Make Group Button
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateGroupScreen())),
                                child: Container(
                                  height: 44, width: 44,
                                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(Icons.group_add_rounded, color: primaryColor, size: 20),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Request Bell
                              StreamBuilder<QuerySnapshot>(
                                stream: MessageService().getIncomingRequests(),
                                builder: (context, snapshot) {
                                  bool hasPendingRequests = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                                  return GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestsScreen())),
                                    child: Container(
                                      height: 44, width: 44,
                                      decoration: BoxDecoration(color: onSurfaceColor.withOpacity(isDark ? 0.08 : 0.05), shape: BoxShape.circle),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(Icons.favorite_outline_rounded, color: onSurfaceColor.withOpacity(0.9), size: 22),
                                          if (hasPendingRequests)
                                            Positioned(
                                              top: 10, right: 10,
                                              child: Container(
                                                height: 10, width: 10,
                                                decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: surfaceColor, width: 2)),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              ),
                            ],
                          )
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

  // --- FILTER CHIP WIDGET ---
  Widget _buildFilterChip(String label, String value, Color primaryColor, Color surfaceColor, Color onSurfaceColor, bool isDark) {
    bool isSelected = _currentFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _currentFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : surfaceColor.withOpacity(isDark ? 0.3 : 0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : Colors.black12)),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : onSurfaceColor.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  // --- GROUP CHAT CARD WIDGET ---
  Widget _buildGroupChatCard({
    required String roomId, 
    required Map<String, dynamic> roomData,
    required Color primaryColor, 
    required Color surfaceColor, 
    required Color onSurfaceColor, 
    required bool isDark,
  }) {
    String groupName = roomData['groupName'] ?? 'Study Group';
    String lastMessage = roomData['lastMessage'] ?? '';
    Timestamp? lastMessageTime = roomData['lastMessageTime'] as Timestamp?;
    String timeString = _formatTime(lastMessageTime);

    Map<String, dynamic> unreadMap = roomData['unreadCount'] ?? {};
    int myUnreadCount = unreadMap[currentUserId] ?? 0;

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrivateChatScreen(
                      roomId: roomId,
                      otherUserName: groupName,
                      otherUserAvatarText: groupName.isNotEmpty ? groupName[0].toUpperCase() : 'G',
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor.withOpacity(isDark ? 0.30 : 0.45),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03), width: 1.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryColor.withOpacity(0.2),
                      child: Icon(Icons.groups_rounded, color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(groupName, style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w800, fontSize: 16)),
                              Row(
                                children: [
                                  if (myUnreadCount > 0)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                      child: Text('$myUnreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  Text(timeString, style: TextStyle(color: onSurfaceColor.withOpacity(0.5), fontWeight: FontWeight.w600, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lastMessage,
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

  // --- DIRECT CHAT CARD FUTURE ---
  Widget _buildChatCardFuture({
    required String roomId, 
    required String otherUserId, 
    required Map<String, dynamic> roomData,
    required Color primaryColor, 
    required Color surfaceColor, 
    required Color onSurfaceColor, 
    required bool isDark,
  }) {
    if (_userCache.containsKey(otherUserId)) {
      return _buildChatCard(roomId, otherUserId, _userCache[otherUserId]!, roomData, primaryColor, surfaceColor, onSurfaceColor, isDark);
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 80); 
        
        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        _userCache[otherUserId] = userData; 

        return _buildChatCard(roomId, otherUserId, userData, roomData, primaryColor, surfaceColor, onSurfaceColor, isDark);
      },
    );
  }

  Widget _buildChatCard(
    String roomId, 
    String otherUserId, 
    Map<String, dynamic> userData, 
    Map<String, dynamic> roomData,
    Color primaryColor, 
    Color surfaceColor, 
    Color onSurfaceColor, 
    bool isDark
  ) {
    String name = userData['fullname'] ?? 'Unknown';
    bool isOnline = userData['isOnline'] ?? false;
    
    String lastMessage = roomData['lastMessage'] ?? '';
    Timestamp? lastMessageTime = roomData['lastMessageTime'] as Timestamp?;
    String timeString = _formatTime(lastMessageTime);

    Map<String, dynamic> unreadMap = roomData['unreadCount'] ?? {};
    int myUnreadCount = unreadMap[currentUserId] ?? 0;

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrivateChatScreen(
                      roomId: roomId,
                      otherUserName: name,
                      otherUserAvatarText: name.isNotEmpty ? name[0].toUpperCase() : '?',
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor.withOpacity(isDark ? 0.30 : 0.45),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03), width: 1.5),
                ),
                child: Row(
                  children: [
                    // --- ACTIVE USER GREEN GLOW OUTLINE ---
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isOnline ? Colors.greenAccent : Colors.transparent,
                          width: isOnline ? 2.5 : 0,
                        ),
                        boxShadow: isOnline ? [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ] : [],
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?', 
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20)
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(name, style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w800, fontSize: 16)),
                              Row(
                                children: [
                                  if (myUnreadCount > 0)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                      child: Text('$myUnreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  Text(timeString, style: TextStyle(color: onSurfaceColor.withOpacity(0.5), fontWeight: FontWeight.w600, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lastMessage,
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

  Widget _buildEmptyState(Color primaryColor, Color onSurfaceColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 48, color: primaryColor),
          ),
          const SizedBox(height: 20),
          Text("Your inbox is empty", style: TextStyle(color: onSurfaceColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Tap the buttons above to find friends\nor create a study group!", 
            textAlign: TextAlign.center,
            style: TextStyle(color: onSurfaceColor.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientGlow(Color color, bool isDark) {
    return Container(
      height: 280, width: 280,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(isDark ? 0.08 : 0.04), boxShadow: [BoxShadow(color: color.withOpacity(isDark ? 0.06 : 0.03), blurRadius: 70, spreadRadius: 20)]),
    );
  }
}