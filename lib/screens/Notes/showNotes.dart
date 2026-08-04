import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/screens/Notes/Notes.dart';

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
      duration: const Duration(seconds: 10), // Smoother, slightly slower loop
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

  // --- NEW LOGIC: Calculate Word Count & Read Time ---
  Map<String, dynamic> _getNoteStats(String text) {
    if (text.trim().isEmpty) return {'words': 0, 'time': 1};
    int wordCount = text.trim().split(RegExp(r'\s+')).length;
    int readTime = (wordCount / 200).ceil(); // Avg reading speed 200 WPM
    return {'words': wordCount, 'time': readTime == 0 ? 1 : readTime};
  }

  // --- NEW LOGIC: Safely Parse Date ---
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
      extendBodyBehindAppBar: true, // Allows background to flow under appbar
      // --- UPGRADED ATTRACTIVE GRADIENT APP BAR ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.04)
                        : Colors.black.withOpacity(0.02),
                    width: 1.0,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'Note Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  leadingWidth: 72,
                  leading: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const Notes(),
                          ),
                        );
                      },
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: surfaceColor.withOpacity(isDark ? 0.35 : 0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons
                              .arrow_back_rounded, // Changed to back arrow for better UX
                          color: onSurfaceColor.withOpacity(0.8),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // --- CYCLIC LOOP BACKGROUND ENGINE DESIGN ---
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

          SafeArea(
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

                // --- NEW LOGIC: Entrance Animation ---
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
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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

                                // --- NEW METADATA ROW ---
                                Row(
                                  children: [
                                    _buildMetaChip(
                                      Icons.calendar_month_rounded,
                                      dateStr,
                                      isDark,
                                      onSurfaceColor,
                                    ),
                                    const SizedBox(width: 12),
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

  // Helper widget for note metadata tags (Date, Read Time)
  Widget _buildMetaChip(
    IconData icon,
    String label,
    bool isDark,
    Color onSurface,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: onSurface.withOpacity(isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: onSurface.withOpacity(0.7)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
