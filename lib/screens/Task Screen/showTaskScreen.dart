import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:study_sync/screens/BottomNavigation.dart';

class Showtaskscreen extends StatefulWidget {
  final String taskid;
  const Showtaskscreen({super.key, required this.taskid});

  @override
  State<Showtaskscreen> createState() => _ShowtaskscreenState();
}

class _ShowtaskscreenState extends State<Showtaskscreen> {
  Future<DocumentSnapshot<Map<String, dynamic>>> loadTask() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(widget.taskid)
        .get();
  }

  Color _getPriorityColor(String priority, Color primaryColor) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return primaryColor;
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

    final Color dynamicTextBody = onSurfaceColor.withOpacity(0.55);
    final Color dynamicInputFill = Color.alphaBlend(
      primaryColor.withOpacity(isDark ? 0.12 : 0.06),
      surfaceColor,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // --- UPGRADED ATTRACTIVE GRADIENT APP BAR ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
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
                'Task Inspection',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: -0.6,
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
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const Bottomnavigation()),
                    ),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(isDark ? 0.35 : 0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: onSurfaceColor.withOpacity(0.8),
                        size: 20,
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
          // Dynamic Atmospheric Emitter Orbs
          Positioned(
            top: 40,
            left: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.06),
                ),
              ),
            ),
          ),

          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: loadTask(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                  child: Text(
                    'Task could not be found',
                    style: TextStyle(
                      color: dynamicTextBody,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                );
              }

              final doc = snapshot.data!.data()!;

              String formetedTime = '';
              String createdAt = '';
              String updatedAt = '';

              String dayStr = '--';
              String monthStr = '---';
              String yearStr = '----';
              String hourStr = '--';
              String minuteStr = '--';
              String periodStr = '--';

              if (doc['dueDate'] != null) {
                final date = (doc['dueDate'] as Timestamp).toDate();
                dayStr = DateFormat('dd').format(date);
                monthStr = DateFormat('MMM').format(date).toUpperCase();
                yearStr = DateFormat('yyyy').format(date);
              }
              if (doc['createdAt'] != null && doc['updatedAt'] != null) {
                final date = (doc['createdAt'] as Timestamp).toDate();
                final updateDate = (doc['updatedAt'] as Timestamp).toDate();

                createdAt = DateFormat('dd MMM, yyyy').format(date);
                updatedAt = DateFormat('dd MMM yyyy, hh:mm a').format(updateDate);
              }
              if (doc['dueTime'] != null) {
                final time = doc['dueTime'] ?? '';
                formetedTime = time.toString().replaceAll('TimeOfDay(', '').replaceAll(')', '');

                List<String> rawParts = formetedTime.split(':');
                if (rawParts.length == 2) {
                  int extractedHour = int.tryParse(rawParts[0]) ?? 0;
                  hourStr = (extractedHour % 12 == 0 ? 12 : extractedHour % 12).toString().padLeft(2, '0');
                  minuteStr = rawParts[1].padLeft(2, '0');
                  periodStr = extractedHour >= 12 ? 'PM' : 'AM';
                }
              }

              bool isCompleted = doc['isCompleted'] ?? false;
              String priorityLevel = doc['priority'] ?? 'Medium';

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CATEGORY & PRIORITY ACCENTS ---
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: dynamicInputFill.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bookmark_outline_rounded, size: 14, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                doc['category'] ?? 'General',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: onSurfaceColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priorityLevel, primaryColor).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle_rounded,
                                size: 8,
                                color: _getPriorityColor(priorityLevel, primaryColor),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "$priorityLevel Priority".toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: _getPriorityColor(priorityLevel, primaryColor),
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- TASK CONTENTS CANVAS ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: surfaceColor.withOpacity(isDark ? 0.30 : 0.45),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc['title'] ?? '',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: onSurfaceColor,
                                  letterSpacing: -0.8,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                doc['description'] ?? 'No extra context or operational instructions have been provided for this task element.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: onSurfaceColor.withOpacity(0.7),
                                  height: 1.55,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- TIMELINE CARD ---
                    Text(
                      "Timeline Allocation",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: onSurfaceColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: surfaceColor.withOpacity(isDark ? 0.25 : 0.45),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      dayStr,
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                        color: onSurfaceColor,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          monthStr,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: primaryColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          yearStr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: dynamicTextBody,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 36,
                                width: 1.5,
                                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                              ),
                              const SizedBox(width: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    "$hourStr:$minuteStr",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: onSurfaceColor,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    periodStr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: dynamicTextBody,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- CURRENT STATUS CONTROL SHEET ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF10B981).withOpacity(0.06)
                            : dynamicInputFill.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCompleted ? const Color(0xFF10B981).withOpacity(0.2) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                            color: isCompleted ? const Color(0xFF10B981) : dynamicTextBody,
                            size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CURRENT STATUS",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isCompleted ? const Color(0xFF10B981) : dynamicTextBody,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isCompleted ? "Task Executed completely" : "Awaiting user completion",
                              style: TextStyle(
                                fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: onSurfaceColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Divider(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                      thickness: 1,
                    ),
                    const SizedBox(height: 20),

                    // --- METADATA HISTORY LOG AUDIT ---
                    Text(
                      "Activity History Log",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: dynamicTextBody,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(isDark ? 0.15 : 0.45),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.01),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Initial Registry", style: TextStyle(color: dynamicTextBody, fontSize: 13, fontWeight: FontWeight.w500)),
                              Text(createdAt, style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Divider(
                              color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                              thickness: 0.8,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Latest Engine Modification", style: TextStyle(color: dynamicTextBody, fontSize: 13, fontWeight: FontWeight.w500)),
                              Text(updatedAt, style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}