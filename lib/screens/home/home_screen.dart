import 'dart:math';
import 'dart:ui';

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

import 'package:study_sync/services/notification_service.dart';
import 'package:study_sync/widgets/profile_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  void updateMyTile(int oldindex, int newindex, List tasks) async {
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

  late final AnimationController _bgController;
  late final AnimationController _fabController;
  late final AnimationController _avatarController;

  // color coordinate priority
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
        return const Color(0xFF0052FF);
    }
  }

  DateTime _getTaskDeadline(Timestamp dueDateTimestamp, dynamic dueTimeRaw) {
    try {
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

      return DateTime(dueDate.year, dueDate.month, dueDate.day, hour, minute);
    } catch (e) {
      final DateTime dueDate = dueDateTimestamp.toDate();
      return DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59);
    }
  }

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _fabController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<Authprovider>().user;
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // SYNCED: Pull dynamic design accents natively from the global theme engine
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color surfaceColor = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,

      // --- MODERN FLOATING ACTION BUTTONS ---
      // --- UPGRADED ATTRACTIVE GLASSMORPHIC FLOATING ACTION HUB ---
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 95,
          right: 4,
        ), // Raised clear of bottom navigation docks
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _AnimatedFab(
              heroTag: 'ai_task_btn',
              controller: _fabController,
              delay: 0.3,
              color: primaryColor,
              secondaryColor: secondaryColor,
              surfaceColor: surfaceColor,
              onSurfaceColor: onSurfaceColor,
              isDark: isDark,
              icon: Icons.auto_awesome_rounded,
              label: 'AI Studio',
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (context) => const AiChatScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _AnimatedFab(
              heroTag: 'add_task_btn',
              controller: _fabController,
              delay: 0.0,
              color: primaryColor,
              secondaryColor: secondaryColor,
              surfaceColor: surfaceColor,
              onSurfaceColor: onSurfaceColor,
              isDark: isDark,
              icon: Icons.add_task_rounded,
              label: 'New Task',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddTaskScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          // --- LOOPING ANIMATED TASK-THEMED BACKGROUND ---
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _TaskBackgroundPainter(
                    t: _bgController.value,
                    colors: [primaryColor, secondaryColor, primaryColor],
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- GLASSY HEADER / APP BAR ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: _GlassContainer(
                    isDark: isDark,
                    borderRadius: 26,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My Tasks",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: onSurfaceColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Let's get things done!",
                              style: TextStyle(
                                fontSize: 13,
                                color: onSurfaceColor.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _AnimatedProfileAvatar(
                              controller: _avatarController,
                              accent: primaryColor,
                              isDark: isDark,
                              photoUrl: user?.photoUrl ?? '',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const Profilescreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // --- TASK LIST STREAM ---
                Expanded(
                  child: StreamBuilder(
                    stream: TaskService().getTask(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: primaryColor),
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
                                color: onSurfaceColor.withOpacity(0.1),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No Tasks Found",
                                style: TextStyle(
                                  color: onSurfaceColor.withOpacity(0.4),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final tasks = snapshot.data!.docs.toList();

                      int completedCount = 0;
                      int expiredCount = 0;
                      for (final t in tasks) {
                        final bool done = t['isCompleted'] ?? false;
                        if (done) {
                          completedCount++;
                          continue;
                        }
                        final deadline = _getTaskDeadline(
                          t['dueDate'] as Timestamp,
                          t['dueTime'],
                        );
                        if (DateTime.now().isAfter(deadline)) expiredCount++;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                            child: _ProgressCard(
                              isDark: isDark,
                              accent: primaryColor,
                              secondaryAccent: secondaryColor,
                              total: tasks.length,
                              completed: completedCount,
                              expired: expiredCount,
                            ),
                          ),
                          Expanded(
                            child: ReorderableListView(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                150,
                              ),
                              proxyDecorator: (child, index, animation) {
                                return Material(
                                  elevation: 10,
                                  color: Colors.transparent,
                                  shadowColor: primaryColor.withOpacity(0.2),
                                  child: child,
                                );
                              },
                              onReorder: (oldindex, newindex) =>
                                  updateMyTile(oldindex, newindex, tasks),
                              children: [
                                for (final task in tasks) ...[
                                  _buildTaskCard(
                                    context,
                                    task,
                                    isDark,
                                    primaryColor,
                                    onSurfaceColor,
                                  ),
                                ],
                              ],
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
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    dynamic task,
    bool isDark,
    Color primaryColor,
    Color onSurfaceColor,
  ) {
    final bool isCompleted = task['isCompleted'] ?? false;
    final DateTime taskDeadline = _getTaskDeadline(
      task['dueDate'] as Timestamp,
      task['dueTime'],
    );
    final bool isExpired = !isCompleted && DateTime.now().isAfter(taskDeadline);

    if (!isCompleted && taskDeadline.isAfter(DateTime.now())) {
      NotificationService().scheduleTaskExpiryNotification(
        id: task.id.hashCode,
        title: 'Task Expired! ⏰',
        body: 'Your task "${task['title']}" has reached its deadline.',
        scheduledTime: taskDeadline,
      );
    }

    String statusLabel = isCompleted
        ? "COMPLETED"
        : (isExpired ? "EXPIRED" : "PENDING");
    Color statusColor = isCompleted
        ? const Color(0xFF10B981)
        : (isExpired ? const Color(0xFFEF4444) : primaryColor);

    return Opacity(
      key: ValueKey(task.id),
      opacity: isExpired ? 0.55 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withOpacity(isDark ? 0.25 : 0.55),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.03),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
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
                          builder: (_) => Showtaskscreen(taskid: task.id),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    leading: isExpired
                        ? const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 26,
                          )
                        : Transform.scale(
                            scale: 1.1,
                            child: Checkbox(
                              value: isCompleted,
                              activeColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              onChanged: (value) async {
                                await TaskService().updateTaskComplete(
                                  task.id,
                                  value!,
                                );
                                if (value == true) {
                                  await NotificationService()
                                      .cancelNotification(task.id.hashCode);
                                }
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
                            ? onSurfaceColor.withOpacity(0.4)
                            : onSurfaceColor,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              task['priority'].toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getPriorityColor(task['priority']),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              task['category'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: onSurfaceColor.withOpacity(0.6),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: onSurfaceColor.withOpacity(0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${task['dueDate'].toDate().day}/${task['dueDate'].toDate().month}/${task['dueDate'].toDate().year}",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: onSurfaceColor.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      color: onSurfaceColor.withOpacity(0.7),
                      onPressed: () => _showTaskOptions(
                        context,
                        task,
                        isCompleted,
                        isExpired,
                        isDark,
                        primaryColor,
                      ),
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

  void _showTaskOptions(
    BuildContext context,
    dynamic task,
    bool isCompleted,
    bool isExpired,
    bool isDark,
    Color primaryColor,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.symmetric(horizontal: 60),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task['title'],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Task Options",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(thickness: 1.2),
              ),
              if (!isCompleted && !isExpired) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => Edittaskscreen(taskId: task.id),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.edit_calendar_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                    label: Text(
                      'Edit Details',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(context, task, isDark);
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                  ),
                  label: const Text(
                    'Delete Task',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, dynamic task, bool isDark) {
    // Local internal state management hook to toggle the loading animation
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final Color primaryColor = theme.colorScheme.primary;
            final Color onSurfaceColor = theme.colorScheme.onSurface;
            final Color surfaceColor = theme.colorScheme.surface;

            return ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 16,
                  sigmaY: 16,
                ), // High-fidelity glass distortion
                child: AlertDialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                  contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  backgroundColor: surfaceColor.withOpacity(
                    isDark ? 0.35 : 0.55,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.04),
                      width: 1.5,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- MICRO-ANIMATED DESTRUCTION VECTOR ICON ---
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                        child: isDeleting
                            ? Container(
                                key: const ValueKey('deleting_loader'),
                                padding: const EdgeInsets.all(16),
                                child: SizedBox(
                                  height: 36,
                                  width: 36,
                                  child: CircularProgressIndicator(
                                    color: const Color(0xFFEF4444),
                                    strokeWidth: 3.5,
                                    backgroundColor: const Color(
                                      0xFFEF4444,
                                    ).withOpacity(0.1),
                                  ),
                                ),
                              )
                            : TweenAnimationBuilder<double>(
                                key: const ValueKey('static_trash_icon'),
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) {
                                  return Transform.rotate(
                                    angle:
                                        (1.0 - value) *
                                        -0.25, // Playful micro-rotation drop down entry
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFEF4444,
                                    ).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(
                                        0xFFEF4444,
                                      ).withOpacity(0.08),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.delete_sweep_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 34,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isDeleting ? 'Removing Task...' : 'Delete Task?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: onSurfaceColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: onSurfaceColor.withOpacity(0.55),
                            fontSize: 14,
                            height: 1.45,
                            fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'Are you sure you want to permanently delete ',
                            ),
                            TextSpan(
                              text: '"${task['title']}"',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: onSurfaceColor,
                              ),
                            ),
                            const TextSpan(
                              text: '? This action cannot be undone.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // --- SPRING ACTION STRIP FLOW ---
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: TextButton(
                                onPressed: isDeleting
                                    ? null
                                    : () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: isDark
                                      ? Colors.white.withOpacity(0.04)
                                      : Colors.black.withOpacity(0.03),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: onSurfaceColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: isDeleting
                                    ? null
                                    : () async {
                                        // Activate structural loader lock inside the modal dialog context
                                        setDialogState(() => isDeleting = true);

                                        // Let the crisp loader spin smoothly for a moment before popping out completely
                                        await Future.delayed(
                                          const Duration(milliseconds: 650),
                                        );

                                        try {
                                          await NotificationService()
                                              .cancelNotification(
                                                task.id.hashCode,
                                              );
                                          await TaskService().taskDelete(
                                            task.id,
                                          );
                                        } catch (e) {
                                          print(e);
                                        }

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  disabledBackgroundColor: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.4),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadowColor: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.2),
                                ),
                                child: Text(
                                  isDeleting ? 'Deleting' : 'Delete',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
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
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// =====================================================================
// GLASS CONTAINER
// =====================================================================
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const _GlassContainer({
    required this.child,
    required this.isDark,
    this.borderRadius = 24,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withOpacity(isDark ? 0.35 : 0.55),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// =====================================================================
// ANIMATED PROFILE AVATAR
// =====================================================================
class _AnimatedProfileAvatar extends StatefulWidget {
  final AnimationController controller;
  final Color accent;
  final bool isDark;
  final String photoUrl;
  final VoidCallback onTap;

  const _AnimatedProfileAvatar({
    required this.controller,
    required this.accent,
    required this.isDark,
    required this.photoUrl,
    required this.onTap,
  });

  @override
  State<_AnimatedProfileAvatar> createState() => _AnimatedProfileAvatarState();
}

class _AnimatedProfileAvatarState extends State<_AnimatedProfileAvatar> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.88),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, child) {
            final double pulse = 1.0 + (widget.controller.value * 0.06);
            return Transform.scale(
              scale: pulse,
              child: Container(
                height: 48,
                width: 48,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      widget.accent,
                      widget.accent.withOpacity(0.2),
                      widget.accent,
                    ],
                    transform: GradientRotation(
                      widget.controller.value * 2 * pi,
                    ),
                  ),
                ),
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: Colors.transparent,
                  child: ProfileAvatar(photoUrl: widget.photoUrl, radius: 21),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =====================================================================
// ANIMATED FAB
// =====================================================================
class _AnimatedFab extends StatefulWidget {
  final String heroTag;
  final AnimationController controller;
  final double delay;
  final Color color;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final bool isDark;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _AnimatedFab({
    required this.heroTag,
    required this.controller,
    required this.delay,
    required this.color,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.isDark,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<_AnimatedFab> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final Animation<double> entrance = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(widget.delay, 1.0, curve: Curves.elasticOut),
    );

    return ScaleTransition(
      scale: entrance,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.90),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 12,
                sigmaY: 12,
              ), // Premium frosted glass blur
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  // Dynamic Translucent configuration balances contrast elegantly for all 8 themes
                  color: widget.surfaceColor.withOpacity(
                    widget.isDark ? 0.35 : 0.55,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.10)
                        : Colors.black.withOpacity(0.05),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(
                        widget.isDark ? 0.15 : 0.06,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [widget.color, widget.secondaryColor],
                      ).createShader(bounds),
                      child: Icon(widget.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.onSurfaceColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: -0.2,
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
}

// =====================================================================
// PROGRESS CARD
// =====================================================================
class _ProgressCard extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final Color secondaryAccent;
  final int total;
  final int completed;
  final int expired;

  const _ProgressCard({
    required this.isDark,
    required this.accent,
    required this.secondaryAccent,
    required this.total,
    required this.completed,
    required this.expired,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = total == 0 ? 0 : completed / total;
    final bool struggling = total > 0 && expired / total > 0.3;
    final Color barColor = struggling
        ? const Color(0xFFEF4444)
        : const Color(0xFF10B981);

    return _GlassContainer(
      isDark: isDark,
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                struggling ? "Falling behind" : "Today's Progress",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                "$completed/$total done",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Stack(
                  children: [
                    Container(
                      height: 10,
                      color: (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.04)),
                    ),
                    FractionallySizedBox(
                      widthFactor: value.clamp(0.0, 1.0),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [barColor, accent]),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (expired > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 4),
                Text(
                  "$expired task${expired > 1 ? 's' : ''} missed the deadline",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// =====================================================================
// LOOPING TASK-THEMED BACKGROUND PAINTER
// =====================================================================
class _TaskBackgroundPainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  final bool isDark;

  _TaskBackgroundPainter({
    required this.t,
    required this.colors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors.map((c) => c.withOpacity(isDark ? 0.12 : 0.05)).toList(),
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    final double angle1 = t * 2 * pi;
    final double angle2 = t * 2 * pi + pi;

    final Offset c1 = Offset(
      size.width * 0.28 + sin(angle1) * size.width * 0.22,
      size.height * 0.22 + cos(angle1) * size.height * 0.12,
    );
    final Offset c2 = Offset(
      size.width * 0.78 + cos(angle2) * size.width * 0.18,
      size.height * 0.68 + sin(angle2) * size.height * 0.16,
    );

    canvas.drawCircle(
      c1,
      size.width * 0.35,
      Paint()
        ..color = colors[0].withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );
    canvas.drawCircle(
      c2,
      size.width * 0.4,
      Paint()
        ..color = colors.last.withOpacity(0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70),
    );

    const icons = [
      Icons.check_circle_rounded,
      Icons.calendar_month_rounded,
      Icons.notifications_active_rounded,
      Icons.star_rounded,
      Icons.task_alt_rounded,
      Icons.bolt_rounded,
    ];

    for (int i = 0; i < icons.length; i++) {
      final double progress = (t + i / icons.length) % 1.0;
      final double dx = size.width * (0.1 + 0.75 * ((i * 53) % 100) / 100);
      final double dy = size.height * (1.15 - progress * 1.35);
      final double fade = sin(progress * pi).clamp(0.0, 1.0);

      final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(
        text: String.fromCharCode(icons[i].codePoint),
        style: TextStyle(
          fontSize: 20,
          fontFamily: icons[i].fontFamily,
          package: icons[i].fontPackage,
          color: colors[i % colors.length].withOpacity(0.18 * fade),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _TaskBackgroundPainter oldDelegate) => true;
}

// action floating button theme
