import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/services/Task_service.dart';
import 'package:study_sync/widgets/category_card.dart';
import 'package:study_sync/widgets/custom_textfield.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController newcategory = TextEditingController();
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();

  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();
  final GlobalKey<FormState> taskFormKey = GlobalKey<FormState>();

  List<String> category = ["Study", "Work", "Personal", "Health", "Shopping"];
  String _selectdvalue = '';

  DateTime? selectedDate = DateTime.now();
  TimeOfDay? SelectedTime = TimeOfDay.now();

  // Set default priority to medium
  String priority = 'medium';

  @override
  void dispose() {
    newcategory.dispose();
    title.dispose();
    description.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // FIXED: Automatically adopts native light/dark properties
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
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
      initialTime: TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute + 1,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // FIXED: Automatically adopts native light/dark properties
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          SelectedTime = value;
        });
      }
    });
  }

  // Helper Widget for Priority Buttons
  Widget _buildPriorityButton(
    BuildContext context,
    String level,
    Color activeColor,
  ) {
    bool isSelected = priority == level;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            priority = level;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.darkInputFill : AppColors.inputFill),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              level.toUpperCase(),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextBody : AppColors.textBody),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIXED: Adaptive core canvas color layout
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'New Task',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => Bottomnavigation())),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: taskFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TASK TITLE ---
                Text(
                  'Task Title',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextfield.customTextField(
                  context: context,
                  hintText: 'What needs to be done?',
                  icon: Icons.title_rounded,
                  controller: title,
                  regex: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z ]')),
                  ],
                  valideter: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a task title.";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // --- TASK DESCRIPTION ---
                Text(
                  'Description',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextfield.customTextField(
                  context: context,
                  hintText: 'Add extra details...',
                  icon: Icons.description_outlined,
                  controller: description,
                  valideter: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a description.";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // --- CATEGORY ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                'Add Category',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              content: Form(
                                key: keyForm,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomTextfield.customTextField(
                                      context: context,
                                      hintText: 'Enter new category',
                                      icon: Icons.category,
                                      controller: newcategory,
                                      valideter: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Name cannot be empty';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextBody
                                          : AppColors.textBody,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (keyForm.currentState!.validate()) {
                                      setState(() {
                                        category.add(newcategory.text);
                                      });
                                      Navigator.pop(context);
                                      newcategory.clear();
                                    }
                                  },
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Add New',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Display Categories using Wrap
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(category.length, (index) {
                    return CategoryCard(
                      category: category[index],
                      isSelected: _selectdvalue == category[index],
                      onTap: () {
                        setState(() {
                          _selectdvalue = category[index];
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          category.removeAt(index);
                        });
                      },
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // --- PRIORITY ---
                Text(
                  'Priority',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPriorityButton(
                      context,
                      'high',
                      const Color(0xFFEF4444),
                    ),
                    _buildPriorityButton(
                      context,
                      'medium',
                      const Color(0xFFF59E0B),
                    ),
                    _buildPriorityButton(
                      context,
                      'low',
                      const Color(0xFF10B981),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- DATE & TIME ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Date',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
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
                                color: isDark
                                    ? AppColors.darkInputFill
                                    : AppColors.inputFill,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    selectedDate != null
                                        ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                                        : "Select Date",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onBackground,
                                      fontWeight: FontWeight.w600,
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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
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
                                color: isDark
                                    ? AppColors.darkInputFill
                                    : AppColors.inputFill,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    SelectedTime != null
                                        ? SelectedTime!.format(context)
                                        : "Select Time",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onBackground,
                                      fontWeight: FontWeight.w600,
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

                // --- SAVE BUTTON ---
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
                      if (!taskFormKey.currentState!.validate()) return;

                      if (_selectdvalue.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a Category'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      if (selectedDate == null || SelectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select Date and Time'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      int selectedMinutes =
                          SelectedTime!.hour * 60 + SelectedTime!.minute;
                      int currentMinutes =
                          TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;

                      if (selectedDate!.day == DateTime.now().day &&
                          selectedDate!.month == DateTime.now().month &&
                          selectedDate!.year == DateTime.now().year) {
                        if (selectedMinutes <= currentMinutes) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select a future time for today.',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                      }

                      TaskService().addTask(
                        title: title.text,
                        description: description.text,
                        category: _selectdvalue,
                        priority: priority,
                        dueDate: selectedDate!,
                        dueTime: SelectedTime.toString(),
                      );

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                    size: 60,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Task Saved!',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your new task has been successfully added to your list.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextBody
                                        : AppColors.textBody,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () async {
                                      SharedPreferences sp =
                                          await SharedPreferences.getInstance();
                                      sp.setStringList('category', category);

                                      if (context.mounted) {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Bottomnavigation(),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Awesome',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Create Task',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
