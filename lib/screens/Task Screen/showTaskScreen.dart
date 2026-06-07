import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_sync/constants/app_colors.dart'; // Make sure this path is correct

// Make sure this path is correct

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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Task Inspection",
          style: TextStyle(
            color: AppColors.neutral,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.neutral,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: loadTask(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Task could not be found',
                style: TextStyle(
                  color: AppColors.textBody,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final doc = snapshot.data!.data()!;

          // Primary Variable extractions (Kept intact)
          String formetedTime = '';
          String createdAt = '';
          String updatedAt = '';

          // Explicit Detailed Subcomponents for display
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
            formetedTime = time
                .toString()
                .replaceAll('TimeOfDay(', '')
                .replaceAll(')', '');

            // Safe extraction pattern for displaying specific Hour, Minutes
            List<String> rawParts = formetedTime.split(':');
            if (rawParts.length == 2) {
              int extractedHour = int.tryParse(rawParts[0]) ?? 0;
              hourStr = (extractedHour % 12 == 0 ? 12 : extractedHour % 12)
                  .toString()
                  .padLeft(2, '0');
              minuteStr = rawParts[1].padLeft(2, '0');
              periodStr = extractedHour >= 12 ? 'PM' : 'AM';
            }
          }

          bool isCompleted = doc['isCompleted'] ?? false;
          String priorityLevel = doc['priority'] ?? 'Medium';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CATEGORY & PRIORITY FLOATING ACCENTS ---
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bookmark_outline_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            doc['category'] ?? 'General',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutral,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(
                          priorityLevel,
                        ).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle_rounded,
                            size: 8,
                            color: _getPriorityColor(priorityLevel),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "$priorityLevel Priority".toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: _getPriorityColor(priorityLevel),
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

                // --- FOCUS HEADLINE INTERFACE ---
                Text(
                  doc['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.neutral,
                    letterSpacing: -1.0,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  doc['description'] ??
                      'No extra context or operational instructions have been provided for this task element.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textBody,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 32),

                // --- MODERN CHRONO CARD (DATE / MONTH / TIME BLOCKS) ---
                const Text(
                  "Timeline Allocation",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Formatted Custom Date Column
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              dayStr,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: AppColors.neutral,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  monthStr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  yearStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBody,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Split Divider Line
                      Container(
                        height: 36,
                        width: 1.5,
                        color: AppColors.inputFill,
                      ),
                      const SizedBox(width: 24),

                      // Formatted Custom Time Column (H M Period Structure)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "$hourStr:$minuteStr",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutral,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            periodStr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBody,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // --- PROGRESSIVE CONTROL STRIP ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF10B981).withOpacity(0.06)
                        : AppColors.inputFill.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF10B981).withOpacity(0.2)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.verified_rounded
                            : Icons.hourglass_top_rounded,
                        color: isCompleted
                            ? const Color(0xFF10B981)
                            : AppColors.textBody,
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
                                color: isCompleted
                                    ? const Color(0xFF10B981)
                                    : AppColors.textBody,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isCompleted
                                  ? "Task Executed completely"
                                  : "Awaiting user completion",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Divider(color: AppColors.inputFill, thickness: 1),
                const SizedBox(height: 24),

                // --- METADATA FOOTER AUDIT RAIL ---
                const Text(
                  "Activity History Log",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBody,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Initial Registry",
                            style: TextStyle(
                              color: AppColors.textBody,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            createdAt,
                            style: const TextStyle(
                              color: AppColors.neutral,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          color: AppColors.inputFill,
                          thickness: 0.8,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Latest Engine Modification",
                            style: TextStyle(
                              color: AppColors.textBody,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            updatedAt,
                            style: const TextStyle(
                              color: AppColors.neutral,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
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
    );
  }
}
