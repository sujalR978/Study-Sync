import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:study_sync/providers/auth_provider.dart';
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
        return const Color(0xFFF59E0B); // Premium Orange
      case 'low':
        return const Color(0xFF10B981); // Premium Green
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<Authprovider>().user;
    return Scaffold(
      backgroundColor: AppColors.background,

      // --- NEW: MODERN FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton.extended(
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

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NEW: CUSTOM HEADER ---
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

                  // Used .toList() to ensure the drag-and-drop reorder logic doesn't crash on immutable stream data
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
                      for (final task in tasks)
                        Container(
                          key: ValueKey(task.id),
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
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      Showtaskscreen(taskid: task.id),
                                ),
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),

                            // --- CHECKBOX ---
                            leading: Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: task['isCompleted'],
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                side: BorderSide(
                                  color: AppColors.textBody.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                onChanged: (value) async {
                                  await TaskService().updateTaskComplete(
                                    task.id,
                                    value!,
                                  );
                                },
                              ),
                            ),

                            // --- TASK TITLE ---
                            title: Text(
                              task['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                // Add strikethrough if completed
                                decoration: task['isCompleted']
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task['isCompleted']
                                    ? AppColors.textBody
                                    : AppColors.neutral,
                              ),
                            ),

                            // --- METADATA (CATEGORY, PRIORITY, DATE) ---
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  // Priority Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(
                                        task['priority'],
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      task['priority'].toString().toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _getPriorityColor(
                                          task['priority'],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Category Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.inputFill,
                                      borderRadius: BorderRadius.circular(10),
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

                                  // Date
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

                            // --- DRAG HANDLE ---
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert_rounded),
                              color: AppColors.neutral,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      // Tightens the dialog perfectly around its contents
                                      scrollable: true,
                                      insetPadding: const EdgeInsets.symmetric(
                                        horizontal: 60,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 20,
                                          ),
                                      backgroundColor: AppColors.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize
                                            .min, // Shrinks height to fit content exactly
                                        children: [
                                          // --- TASK TITLE HEADER ---
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Text(
                                              task['title'],
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.neutral,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
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
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),

                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            child: Divider(
                                              color: AppColors.inputFill,
                                              thickness: 1.2,
                                            ),
                                          ),

                                          // --- EDIT BUTTON ---
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
                                                        Edittaskscreen(),
                                                  ),
                                                ); // Close dialog
                                                // Add your Edit Screen navigation code right here!
                                              },
                                              icon: const Icon(
                                                Icons.edit_calendar_rounded,
                                                color: AppColors.primary,
                                                size: 20,
                                              ),
                                              label: const Text(
                                                'Edit Details',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          // --- DELETE BUTTON ---
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: TextButton.icon(
                                              onPressed: () {
                                                TaskService().taskDelete(
                                                  task.id,
                                                );
                                                Navigator.pop(
                                                  context,
                                                ); // Close dialog
                                                // Add your Firebase delete logic right here!
                                              },
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Color(0xFFEF4444),
                                                size: 20,
                                              ),
                                              label: const Text(
                                                'Delete Task',
                                                style: TextStyle(
                                                  color: Color(
                                                    0xFFEF4444,
                                                  ), // Matte red alert color
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                // Gives a soft red ripple effect when clicked
                                                overlayColor: const Color(
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
                        ),
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
