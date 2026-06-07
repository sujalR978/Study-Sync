import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/Ai_screen/ai_chat_screen.dart';
import 'package:study_sync/screens/Task%20Screen/EditTaskScreen.dart';
import 'package:study_sync/screens/Task%20Screen/showTaskScreen.dart';
import 'package:study_sync/screens/Task%20Screen/add_Task_Screen.dart';

import 'package:study_sync/screens/profile/profileScreen.dart';
import 'package:study_sync/services/Task_service.dart';
import 'package:study_sync/constants/app_colors.dart'; // Adjust path if needed

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void updateMyTiel(int oldindex, int newindex, List tasks) async {
    if (newindex > oldindex) {
      newindex--;
    }

    final item = tasks.removeAt(oldindex);
    tasks.insert(newindex, item);

    for (int i = 0; i < tasks.length; i++) {
      await TaskService().updateTaskOrder(tasks[i].id, i);
    }
  }

  bool isClick = false;

  // Helper function to color coordinate priority pills
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444); // Premium Red
      case 'medium':
      case 'miduim':
        return const Color(0xFFF59E0B); // Premium Orange
      case 'low':
        return const Color(0xFF10B981); // Premium Green
      default:
        return AppColors.primary;
    }
  }

  // Helper utility to safely calculate expiration states at runtime
  bool _checkIsExpired(Timestamp dueDateTimestamp, dynamic dueTimeRaw) {
    try {
      final now = DateTime.now();
      final DateTime dueDate = dueDateTimestamp.toDate();
      String rawTime = dueTimeRaw
          .toString()
          .replaceAll('TimeOfDay(', '')
          .replaceAll(')', '')
          .trim();

      int hour = 12;
      int minute = 0;

      bool isPM = rawTime.toLowerCase().contains('pm');
      bool isAM = rawTime.toLowerCase().contains('am');
      rawTime = rawTime
          .toLowerCase()
          .replaceAll('am', '')
          .replaceAll('pm', '')
          .trim();

      List<String> timeParts = rawTime.split(':');
      if (timeParts.length == 2) {
        hour = int.parse(timeParts[0].trim());
        minute = int.parse(timeParts[1].trim());

        if (isPM && hour < 12) hour += 12;
        if (isAM && hour == 12) hour = 0;
      }

      final taskDeadline = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        hour,
        minute,
      );
      return now.isAfter(taskDeadline);
    } catch (e) {
      final now = DateTime.now();
      final DateTime dueDate = dueDateTimestamp.toDate();
      final targetDateOnly = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        23,
        59,
      );
      return now.isAfter(targetDateOnly);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<Authprovider>().user;
    return Scaffold(
      backgroundColor: AppColors.background,

      // --- MODERN FLOATING ACTION BUTTON ---
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // --- AI UTILITY ACTION BUTTON ---
          FloatingActionButton.extended(
            heroTag: 'ai_task_btn',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AiChatScreen()),
              );
            },
            backgroundColor: AppColors.primary,
            elevation: 4,
            icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
            label: const Text(
              "AI",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // --- STANDARD NEW TASK ACTION BUTTON ---
          FloatingActionButton.extended(
            heroTag: 'add_task_btn',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddTaskScreen()),
              );
            },
            backgroundColor: AppColors.primary,
            elevation: 4,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              "New Task",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CUSTOM HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Tasks",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutral,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Let's get things done!",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textBody,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Profilescreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: AppColors.inputFill,
                        backgroundImage:
                            user != null && user.loginMethod == 'google'
                            ? NetworkImage(user.photoUrl) as ImageProvider
                            : null,
                        child: user == null || user.loginMethod != 'google'
                            ? const Icon(Icons.person_off)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- TASK LIST STREAM ---
            Expanded(
              child: StreamBuilder(
                stream: TaskService().getTask(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_rounded,
                            size: 80,
                            color: AppColors.inputFill,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Tasks Found",
                            style: TextStyle(
                              color: AppColors.textBody,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final tasks = snapshot.data!.docs.toList();

                  return ReorderableListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        elevation: 10,
                        color: Colors.transparent,
                        shadowColor: AppColors.primary.withOpacity(0.2),
                        child: child,
                      );
                    },
                    onReorder: (oldindex, newindex) =>
                        updateMyTiel(oldindex, newindex, tasks),
                    children: [
                      for (final task in tasks) ...[
                        () {
                          final bool isCompleted = task['isCompleted'] ?? false;
                          final bool isExpired =
                              !isCompleted &&
                              _checkIsExpired(
                                task['dueDate'] as Timestamp,
                                task['dueTime'],
                              );

                          String statusLabel = "PENDING";
                          Color statusColor = AppColors.primary;

                          if (isCompleted) {
                            statusLabel = "COMPLETED";
                            statusColor = const Color(0xFF10B981);
                          } else if (isExpired) {
                            statusLabel = "EXPIRED";
                            statusColor = const Color(0xFFEF4444);
                          }

                          return Opacity(
                            key: ValueKey(task.id),
                            opacity: isExpired ? 0.5 : 1.0,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- TOP ACCENT CORNER STATUS BAR ---
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            statusLabel,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: statusColor,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  ListTile(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              Showtaskscreen(taskid: task.id),
                                        ),
                                      );
                                    },
                                    contentPadding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      12,
                                    ),
                                    leading: isExpired
                                        ? const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.error_outline_rounded,
                                              color: Color(0xFFEF4444),
                                              size: 24,
                                            ),
                                          )
                                        : Transform.scale(
                                            scale: 1.2,
                                            child: Checkbox(
                                              value: isCompleted,
                                              activeColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              side: BorderSide(
                                                color: AppColors.textBody
                                                    .withOpacity(0.5),
                                                width: 1.5,
                                              ),
                                              onChanged: (value) async {
                                                await TaskService()
                                                    .updateTaskComplete(
                                                      task.id,
                                                      value!,
                                                    );
                                              },
                                            ),
                                          ),

                                    title: Text(
                                      task['title'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: isCompleted
                                            ? AppColors.textBody
                                            : AppColors.neutral,
                                      ),
                                    ),

                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getPriorityColor(
                                                task['priority'],
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              task['priority']
                                                  .toString()
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: _getPriorityColor(
                                                  task['priority'],
                                                ),
                                              ),
                                            ),
                                          ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.inputFill,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              task['category'],
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textBody,
                                              ),
                                            ),
                                          ),

                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.calendar_today_rounded,
                                                size: 12,
                                                color: AppColors.textBody,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${task['dueDate'].toDate().day}/${task['dueDate'].toDate().month}/${task['dueDate'].toDate().year}",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textBody,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    trailing: IconButton(
                                      icon: const Icon(Icons.more_vert_rounded),
                                      color: AppColors.neutral,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              scrollable: true,
                                              insetPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 60,
                                                  ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 20,
                                                  ),
                                              backgroundColor:
                                                  AppColors.surface,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8.0,
                                                        ),
                                                    child: Text(
                                                      task['title'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.neutral,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        letterSpacing: -0.3,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Task Options",
                                                    style: TextStyle(
                                                      color: AppColors.textBody
                                                          .withOpacity(0.7),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),

                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    child: Divider(
                                                      color:
                                                          AppColors.inputFill,
                                                      thickness: 1.2,
                                                    ),
                                                  ),

                                                  // --- Only show Edit if task is NOT completed AND NOT expired ---
                                                  if (isCompleted != true &&
                                                      isExpired != true) ...[
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 48,
                                                      child: TextButton.icon(
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pushReplacement(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Edittaskscreen(
                                                                    taskId:
                                                                        task.id,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          Icons
                                                              .edit_calendar_rounded,
                                                          color:
                                                              AppColors.primary,
                                                          size: 20,
                                                        ),
                                                        label: const Text(
                                                          'Edit Details',
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .primary,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        style: TextButton.styleFrom(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],

                                                  // --- DELETE BUTTON (Always visible for all tasks) ---
                                                  SizedBox(
                                                    width: double.infinity,
                                                    height: 48,
                                                    child: TextButton.icon(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              true,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              insetPadding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        40,
                                                                  ),
                                                              contentPadding:
                                                                  const EdgeInsets.fromLTRB(
                                                                    24,
                                                                    24,
                                                                    24,
                                                                    16,
                                                                  ),
                                                              backgroundColor:
                                                                  AppColors
                                                                      .surface,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      28,
                                                                    ),
                                                              ),
                                                              content: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          14,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      color: const Color(
                                                                        0xFFEF4444,
                                                                      ).withOpacity(0.1),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child: const Icon(
                                                                      Icons
                                                                          .delete_sweep_rounded,
                                                                      color: Color(
                                                                        0xFFEF4444,
                                                                      ),
                                                                      size: 32,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  const Text(
                                                                    'Delete Task?',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                      color: AppColors
                                                                          .neutral,
                                                                      letterSpacing:
                                                                          -0.5,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 8,
                                                                  ),
                                                                  RichText(
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    text: TextSpan(
                                                                      style: const TextStyle(
                                                                        color: AppColors
                                                                            .textBody,
                                                                        fontSize:
                                                                            14,
                                                                        height:
                                                                            1.4,
                                                                      ),
                                                                      children: [
                                                                        const TextSpan(
                                                                          text:
                                                                              'Are you sure you want to permanently delete ',
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              '"${task['title']}"',
                                                                          style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                AppColors.neutral,
                                                                          ),
                                                                        ),
                                                                        const TextSpan(
                                                                          text:
                                                                              '? This action cannot be undone.',
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 28,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: SizedBox(
                                                                          height:
                                                                              48,
                                                                          child: TextButton(
                                                                            onPressed: () => Navigator.pop(
                                                                              context,
                                                                            ),
                                                                            style: TextButton.styleFrom(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  14,
                                                                                ),
                                                                              ),
                                                                              backgroundColor: AppColors.inputFill.withOpacity(
                                                                                0.5,
                                                                              ),
                                                                            ),
                                                                            child: const Text(
                                                                              'Cancel',
                                                                              style: TextStyle(
                                                                                color: AppColors.neutral,
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: 15,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            12,
                                                                      ),
                                                                      Expanded(
                                                                        child: SizedBox(
                                                                          height:
                                                                              48,
                                                                          child: ElevatedButton(
                                                                            // --- INTEGRATED DATABASE CALL HERE ---
                                                                            onPressed: () async {
                                                                              Navigator.pop(
                                                                                context,
                                                                              ); // Close dialog
                                                                              try {
                                                                                await TaskService().taskDelete(
                                                                                  task.id,
                                                                                );
                                                                                if (context.mounted) {
                                                                                  ScaffoldMessenger.of(
                                                                                    context,
                                                                                  ).showSnackBar(
                                                                                    SnackBar(
                                                                                      content: Text(
                                                                                        '"${task['title']}" deleted successfully',
                                                                                      ),
                                                                                      backgroundColor: Colors.black87,
                                                                                      behavior: SnackBarBehavior.floating,
                                                                                    ),
                                                                                  );
                                                                                }
                                                                              } catch (
                                                                                e
                                                                              ) {
                                                                                if (context.mounted) {
                                                                                  ScaffoldMessenger.of(
                                                                                    context,
                                                                                  ).showSnackBar(
                                                                                    SnackBar(
                                                                                      content: Text(
                                                                                        'Failed to delete: $e',
                                                                                      ),
                                                                                      backgroundColor: const Color(
                                                                                        0xFFEF4444,
                                                                                      ),
                                                                                      behavior: SnackBarBehavior.floating,
                                                                                    ),
                                                                                  );
                                                                                }
                                                                              }
                                                                            },

                                                                            style: ElevatedButton.styleFrom(
                                                                              backgroundColor: const Color(
                                                                                0xFFEF4444,
                                                                              ),
                                                                              elevation: 0,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  14,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            child: const Text(
                                                                              'Delete',
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 15,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        color: Color(
                                                          0xFFEF4444,
                                                        ),
                                                        size: 20,
                                                      ),
                                                      label: const Text(
                                                        'Delete Task',
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFFEF4444,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        overlayColor:
                                                            const Color(
                                                              0xFFEF4444,
                                                            ).withOpacity(0.1),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }(),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
