import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/services/task_service.dart';
import 'package:study_sync/widgets/category_card.dart';
import 'package:study_sync/widgets/custom_textfield.dart';

class Edittaskscreen extends StatefulWidget {
  final String taskId;
  const Edittaskscreen({super.key, required this.taskId});

  @override
  State<Edittaskscreen> createState() => _EdittaskscreenState();
}

class _EdittaskscreenState extends State<Edittaskscreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController taskName;
  late TextEditingController taskDescription;
  List<String> Category = [];
  String categorySelected = '';
  DateTime? selectedDate;
  String? selectedTime;
  String setpriority = 'Medium';
  bool isLoaded = false;

  bool _isUpdatePressed = false;

  @override
  void initState() {
    super.initState();
    taskName = TextEditingController();
    taskDescription = TextEditingController();
    getdata();
  }

  @override
  void dispose() {
    taskName.dispose();
    taskDescription.dispose();
    super.dispose();
  }

  void getdata() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      Category = sp.getStringList('category') ?? ["Study", "Work", "Personal", "Health", "Shopping"];
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isLoaded) {
      _loadTask();
      isLoaded = true;
    }
  }

  Future<void> _loadTask() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final taskSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(widget.taskId)
        .get();

    final taskData = taskSnapshot.data();
    if (taskData != null) {
      taskName.text = taskData['title'] ?? '';
      taskDescription.text = taskData['description'] ?? '';
      categorySelected = taskData['category'] ?? '';
      selectedDate = (taskData['dueDate'] as Timestamp).toDate();

      String rawTime = taskData['dueTime'] ?? '';
      if (rawTime.contains('TimeOfDay(')) {
        selectedTime = rawTime.replaceAll('TimeOfDay(', '').replaceAll(')', '');
      } else {
        selectedTime = rawTime;
      }

      setpriority = taskData['priority'] ?? 'Medium';
      setState(() {});
    }
  }

  void _showDatePicker(Color primaryColor) {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: selectedDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: primaryColor),
          ),
          child: child!,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedDate = value;
        });
      }
    });
  }

  void _showTimePicker(Color primaryColor) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: primaryColor),
          ),
          child: child!,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedTime = value.format(context);
        });
      }
    });
  }

  Color _getPriorityColor(String level, Color primaryColor) {
    switch (level.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'miduim':
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return primaryColor;
    }
  }

  Widget _buildPriorityButton(BuildContext context, String level, Color primaryColor, Color inputFill, Color textBodyColor) {
    bool isSelected = false;
    String currentPriorityLower = setpriority.toLowerCase().trim();
    String buttonLevelLower = level.toLowerCase().trim();

    if (buttonLevelLower == currentPriorityLower) {
      isSelected = true;
    } else if (buttonLevelLower == 'miduim' || buttonLevelLower == 'medium') {
      if (currentPriorityLower == 'miduim' || currentPriorityLower == 'medium') {
        isSelected = true;
      }
    }

    Color targetColor = _getPriorityColor(level, primaryColor);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => setpriority = level),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? targetColor : inputFill.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? targetColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              level.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : textBodyColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.0,
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
                'Modify Task',
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
                        Icons.arrow_back_ios_new_rounded,
                        color: onSurfaceColor.withOpacity(0.8),
                        size: 16,
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
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.06),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.15),
                    blurRadius: 55,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TASK SHELL PANEL ENCLOSED IN FROSTED ACRYLIC MAPS ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
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
                                'TASK TITLE',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              CustomTextfield.customTextField(
                                context: context,
                                hintText: 'Enter Text',
                                icon: Icons.edit_note_rounded,
                                controller: taskName,
                                regex: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9 ]'))],
                                valideter: (value) => (value == null || value.isEmpty) ? 'Enter task' : null,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'DESCRIPTION',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              CustomTextfield.customTextField(
                                context: context,
                                hintText: 'Enter description',
                                icon: Icons.description_outlined,
                                controller: taskDescription,
                                valideter: (value) => (value == null || value.isEmpty) ? 'Enter Description' : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- CATEGORY SEGMENTED HUB ---
                    Text(
                      'Category Selection',
                      style: TextStyle(
                        color: onSurfaceColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(Category.length, (index) {
                        String cat = Category[index];
                        return CategoryCard(
                          category: cat,
                          isSelected: categorySelected == cat,
                          onTap: () => setState(() => categorySelected = cat),
                          onLongPress: () {},
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // --- PRIORITY MATRIX AREA ---
                    Text(
                      'Priority Range',
                      style: TextStyle(
                        color: onSurfaceColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildPriorityButton(context, 'High', primaryColor, dynamicInputFill, dynamicTextBody),
                        _buildPriorityButton(context, 'Miduim', primaryColor, dynamicInputFill, dynamicTextBody),
                        _buildPriorityButton(context, 'Low', primaryColor, dynamicInputFill, dynamicTextBody),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // --- CHRONO MESH DATA PICKERS ---
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Date',
                                style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showDatePicker(primaryColor),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: dynamicInputFill.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, color: primaryColor, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          selectedDate != null
                                              ? "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}"
                                              : "Set Date",
                                          style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Time',
                                style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showTimePicker(primaryColor),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: dynamicInputFill.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time_rounded, color: primaryColor, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          selectedTime ?? "Set Time",
                                          style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 44),

                    // --- THEME-REACTIVE ANIMATED UPDATE CONFIRM BUTTON ---
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isUpdatePressed = true),
                      onTapUp: (_) => setState(() => _isUpdatePressed = false),
                      onTapCancel: () => setState(() => _isUpdatePressed = false),
                      onTap: () {
                        if (!_formKey.currentState!.validate()) return;
                        if (selectedDate != null && selectedTime != null) {
                          DateTime now = DateTime.now();

                          if (selectedDate!.day == now.day && selectedDate!.month == now.month && selectedDate!.year == now.year) {
                            int currentMinutes = now.hour * 60 + now.minute;
                            int targetMinutes = 0;

                            try {
                              String cleanTime = selectedTime!.trim();
                              bool isPM = cleanTime.toLowerCase().contains('pm');
                              bool isAM = cleanTime.toLowerCase().contains('am');

                              cleanTime = cleanTime.toLowerCase().replaceAll('am', '').replaceAll('pm', '').trim();
                              List<String> timeParts = cleanTime.split(':');

                              if (timeParts.length == 2) {
                                int hour = int.parse(timeParts[0].trim());
                                int minute = int.parse(timeParts[1].trim());

                                if (isPM && hour < 12) hour += 12;
                                if (isAM && hour == 12) hour = 0;
                                targetMinutes = hour * 60 + minute;
                              }
                            } catch (e) {
                              targetMinutes = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
                            }

                            if (targetMinutes <= currentMinutes) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Validation Failure: Please pick a future time window for today.'),
                                  backgroundColor: Color(0xFFEF4444),
                                ),
                              );
                              return;
                            }
                          }
                        }

                        _openApplyChangesDialog(context, isDark, primaryColor, secondaryColor, surfaceColor, onSurfaceColor, dynamicTextBody);
                      },
                      child: AnimatedScale(
                        scale: _isUpdatePressed ? 0.96 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [primaryColor, secondaryColor],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Update Task Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UPGRADED GLASSMORPHIC CONFIRMATION DIALOG LAYER ---
  void _openApplyChangesDialog(
    BuildContext context, bool isDark, Color primaryColor, Color secondaryColor,
    Color surfaceColor, Color onSurfaceColor, Color textBodyColor
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 40),
              contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              backgroundColor: surfaceColor.withOpacity(isDark ? 0.45 : 0.65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                  width: 1.5,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_calendar_rounded,
                      color: primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Apply Changes?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: onSurfaceColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Are you sure you want to edit and overwrite this task definition?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textBodyColor,
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              backgroundColor: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: onSurfaceColor,
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
                            onPressed: () {
                              Navigator.pop(context);

                              TaskService().updateTask(
                                title: taskName.text,
                                description: taskDescription.text,
                                category: categorySelected.toString(),
                                priority: setpriority.toString(),
                                dueDate: selectedDate,
                                dueTime: selectedTime.toString(),
                                updatedAt: DateTime.now(),
                                taskid: widget.taskId.toString(),
                              );

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const Bottomnavigation()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text(
                              'Confirm',
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
            ),
          ),
        );
      },
    );
  }
}