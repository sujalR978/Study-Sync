import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/screens/Notes/EditNotes.dart';

class Shownotes extends StatefulWidget {
  final String noteId;
  const Shownotes({super.key, required this.noteId});

  @override
  State<Shownotes> createState() => _ShownotesState();
}

class _ShownotesState extends State<Shownotes>
    with SingleTickerProviderStateMixin {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _notesFuture;
  late AnimationController _loopController;

  @override
  void initState() {
    super.initState();
    _notesFuture = _fetchNotes();

    // Continuous loop background tracking controller setup
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _loopController.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchNotes() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(widget.noteId)
        .get();
  }

  // Calculate Word Count & Read Time
  Map<String, dynamic> _getNoteStats(String text) {
    if (text.trim().isEmpty) return {'words': 0, 'time': 1};
    int wordCount = text.trim().split(RegExp(r'\s+')).length;
    int readTime = (wordCount / 200).ceil();
    return {'words': wordCount, 'time': readTime == 0 ? 1 : readTime};
  }

  // Safely Parse Date
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Unknown date";
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is String) {
      date = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      return "Unknown date";
    }

    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color surfaceColor = theme.colorScheme.surface;

    final Color dynamicTextBody = onSurfaceColor.withOpacity(
      isDark ? 0.8 : 0.75,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,

      // Scaffold AppBar removed to use Stack-based Floating Pill App Bar
      body: Stack(
        children: [
          // ===================================================================
          // --- 1. CYCLIC LOOP BACKGROUND ENGINE DESIGN ---
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
                  // Added a 3rd subtle glow for more depth
                  Positioned(
                    top:
                        MediaQuery.of(context).size.height * 0.4 +
                        (20 * cos(_loopController.value * pi)),
                    right: 40 + (20 * sin(_loopController.value * pi)),
                    child: _buildAmbientGlow(
                      Color.lerp(primaryColor, secondaryColor, 0.5)!,
                      isDark,
                      size: 200,
                      opacityMultiplier: 0.5,
                    ),
                  ),
                ],
              );
            },
          ),

          // ===================================================================
          // --- 2. MAIN CONTENT (NOTE RENDERER) ---
          // ===================================================================
          SafeArea(
            bottom: false,
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _notesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 60,
                          color: onSurfaceColor.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Note could not be found',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: onSurfaceColor.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final noteBody =
                    data['body'] ??
                    'No text description entered inside this note block.';
                final stats = _getNoteStats(noteBody);
                final dateStr = _formatDate(
                  data['timestamp'] ?? data['createdAt'] ?? data['date'],
                );

                // EXTRACTING THE TAG
                final subjectTag =
                    data['subject']?.toString().isNotEmpty == true
                    ? data['subject'].toString().trim()
                    : 'General';

                // --- Entrance Animation ---
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 40 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    margin: const EdgeInsets.fromLTRB(
                      16,
                      85,
                      16,
                      24,
                    ), // Increased top margin to clear Pill App Bar
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: surfaceColor.withOpacity(
                              isDark ? 0.40 : 0.65,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.12)
                                  : Colors.black.withOpacity(0.06),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- IMMERSIVE NOTE TITLE RENDER ---
                                SelectableText(
                                  data['title'] ?? 'Untitled Note',
                                  style: TextStyle(
                                    fontSize: 28,
                                    height: 1.2,
                                    fontWeight: FontWeight.w900,
                                    color: onSurfaceColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // --- METADATA ROW WITH TAG ---
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    // Highlighted Tag Chip
                                    _buildMetaChip(
                                      Icons.local_offer_rounded,
                                      subjectTag,
                                      isDark,
                                      primaryColor,
                                      isHighlighted: true,
                                    ),
                                    _buildMetaChip(
                                      Icons.calendar_month_rounded,
                                      dateStr,
                                      isDark,
                                      onSurfaceColor,
                                    ),
                                    _buildMetaChip(
                                      Icons.access_time_rounded,
                                      '${stats['time']} min read',
                                      isDark,
                                      onSurfaceColor,
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24.0,
                                  ),
                                  child: Container(
                                    height: 1.5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          onSurfaceColor.withOpacity(0.15),
                                          onSurfaceColor.withOpacity(0.01),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // --- IMMERSIVE NOTE BODY CONTENT ---
                                SelectableText(
                                  noteBody,
                                  style: TextStyle(
                                    fontSize: 17,
                                    height: 1.7,
                                    color: dynamicTextBody,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
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
              },
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
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
                          // Left Icon (Back Button)
                          GestureDetector(
                            onTap: () {
                              // Proper Navigation: Native Pop
                              Navigator.pop(context);
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
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: onSurfaceColor.withOpacity(0.8),
                                size: 20,
                              ),
                            ),
                          ),

                          // Centered Title
                          Text(
                            'View Note',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                          ),

                          // Right Icon (Quick Edit Button)
                          GestureDetector(
                            onTap: () {
                              // Push replacement directly to edit mode
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Editnotes(noteId: widget.noteId),
                                ),
                              );
                            },
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                color: primaryColor,
                                size: 18,
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

  // Helper widget for background glows
  Widget _buildAmbientGlow(
    Color color,
    bool isDark, {
    double size = 280,
    double opacityMultiplier = 1.0,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity((isDark ? 0.08 : 0.04) * opacityMultiplier),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(
              (isDark ? 0.06 : 0.03) * opacityMultiplier,
            ),
            blurRadius: 70,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  // Helper widget for note metadata tags (Date, Read Time, Subject Tag)
  Widget _buildMetaChip(
    IconData icon,
    String label,
    bool isDark,
    Color color, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isHighlighted ? 0.15 : (isDark ? 0.1 : 0.05)),
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(color: color.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color.withOpacity(isHighlighted ? 1.0 : 0.7),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: color.withOpacity(isHighlighted ? 1.0 : 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
