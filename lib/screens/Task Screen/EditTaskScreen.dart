import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/services/Task_service.dart';
import 'package:study_sync/widgets/category_card.dart';
import 'package:study_sync/widgets/custom_textfield.dart';
import 'package:study_sync/constants/app_colors.dart'; // Make sure this path is correct

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

  void _showDatePicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: selectedDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
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

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
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

  @override
  void initState() {
    super.initState();
    taskName = TextEditingController();
    taskDescription = TextEditingController();
    getdata();
  }

  void getdata() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      Category =
          sp.getStringList('category') ??
          ["Study", "Work", "Personal", "Health", "Shopping"];
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTask();
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

  Color _getPriorityColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'miduim':
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return AppColors.primary;
    }
  }

  Widget _buildPriorityButton(String level) {
    bool isSelected = false;
    String currentPriorityLower = setpriority.toLowerCase().trim();
    String buttonLevelLower = level.toLowerCase().trim();

    if (buttonLevelLower == currentPriorityLower) {
      isSelected = true;
    } else if (buttonLevelLower == 'miduim' || buttonLevelLower == 'medium') {
      if (currentPriorityLower == 'miduim' ||
          currentPriorityLower == 'medium') {
        isSelected = true;
      }
    }

    Color targetColor = _getPriorityColor(level);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            setpriority = level;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? targetColor : AppColors.inputFill,
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
                color: isSelected ? Colors.white : AppColors.textBody,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Modify Task',
          style: TextStyle(
            color: AppColors.neutral,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.neutral,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Title',
                  style: TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextfield.customTextField(
                  hintText: 'Enter Text',
                  icon: Icons.edit_note_rounded,
                  controller: taskName,
                  regex: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9 ]')),
                  ],
                  valideter: (Value) {
                    if (Value == null || Value.isEmpty) {
                      return 'Enter task';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  'Description',
                  style: TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextfield.customTextField(
                  hintText: 'Enter description',
                  icon: Icons.description_outlined,
                  controller: taskDescription,
                  valideter: (Value) {
                    if (Value == null || Value.isEmpty) {
                      return 'Enter Description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                const Text(
                  'Category Selection',
                  style: TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(Category.length, (index) {
                    String cat = Category[index];
                    return CategoryCard(
                      category: cat,
                      isSelected: categorySelected == cat,
                      onTap: () {
                        setState(() {
                          categorySelected = cat;
                        });
                      },
                      onLongPress: () {},
                    );
                  }),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Priority Range',
                  style: TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPriorityButton('High'),
                    _buildPriorityButton('Miduim'),
                    _buildPriorityButton('Low'),
                  ],
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Due Date',
                            style: TextStyle(
                              color: AppColors.neutral,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showDatePicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.inputFill,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      selectedDate != null
                                          ? "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}"
                                          : "Set Date",
                                      style: const TextStyle(
                                        color: AppColors.neutral,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                          const Text(
                            'Due Time',
                            style: TextStyle(
                              color: AppColors.neutral,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showTimePicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.inputFill,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      selectedTime ?? "Set Time",
                                      style: const TextStyle(
                                        color: AppColors.neutral,
                                        fontWeight: FontWeight.w600,
                                      ),
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

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // --- NEW: FUTURE TIME VALIDATION ENGINE ---
                        if (selectedDate != null && selectedTime != null) {
                          DateTime now = DateTime.now();

                          // Check if selected date is explicitly today
                          if (selectedDate!.day == now.day &&
                              selectedDate!.month == now.month &&
                              selectedDate!.year == now.year) {
                            int currentMinutes = now.hour * 60 + now.minute;
                            int targetMinutes = 0;

                            // Safely extract hours and minutes out of format variations (AM/PM string format parsing check)
                            try {
                              String cleanTime = selectedTime!.trim();
                              bool isPM = cleanTime.toLowerCase().contains(
                                'pm',
                              );
                              bool isAM = cleanTime.toLowerCase().contains(
                                'am',
                              );

                              // Clear suffix text elements
                              cleanTime = cleanTime
                                  .toLowerCase()
                                  .replaceAll('am', '')
                                  .replaceAll('pm', '')
                                  .trim();
                              List<String> timeParts = cleanTime.split(':');

                              if (timeParts.length == 2) {
                                int hour = int.parse(timeParts[0].trim());
                                int minute = int.parse(timeParts[1].trim());

                                // Adjust clock indexing to 24-hour constraints if AM/PM handles are active
                                if (isPM && hour < 12) hour += 12;
                                if (isAM && hour == 12) hour = 0;

                                targetMinutes = hour * 60 + minute;
                              }
                            } catch (e) {
                              // Secondary raw conversion fallback strategy if format parsing encounters string abnormalities
                              targetMinutes =
                                  TimeOfDay.now().hour * 60 +
                                  TimeOfDay.now().minute;
                            }

                            // Block transaction processing if validation parameters are violated
                            if (targetMinutes <= currentMinutes) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Validation Failure: Please pick a future time window for today.',
                                  ),
                                  backgroundColor: Color(0xFFEF4444),
                                ),
                              );
                              return; // Exits logic cleanly without spawning confirm box
                            }
                          }
                        }

                        // Spawns confirmation interactive window safely if conditions check out
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return AlertDialog(
                              insetPadding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(
                                24,
                                24,
                                24,
                                16,
                              ),
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit_calendar_rounded,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Apply Changes?',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.neutral,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Are you sure you want to edit and overwrite this task definition?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textBody,
                                      fontSize: 14,
                                      height: 1.4,
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
                                              Navigator.of(
                                                context,
                                              ).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HomeScreen(),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              backgroundColor: AppColors
                                                  .inputFill
                                                  .withOpacity(0.5),
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
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: SizedBox(
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);

                                              TaskService().updateTask(
                                                title: taskName.text,
                                                description:
                                                    taskDescription.text,
                                                category: categorySelected
                                                    .toString(),
                                                priority: setpriority
                                                    .toString(),
                                                dueDate: selectedDate,
                                                dueTime: selectedTime
                                                    .toString(),
                                                updatedAt: DateTime.now(),
                                                taskid: widget.taskId
                                                    .toString(),
                                              );

                                              Navigator.of(
                                                context,
                                              ).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HomeScreen(),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
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
                            );
                          },
                        );
                      }
                    },
                    child: const Text(
                      'Update Task Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
    );
  }
}
