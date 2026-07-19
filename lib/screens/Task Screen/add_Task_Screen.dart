
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
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

  String priority = 'medium';

  bool _isCreatePressed = false;
  bool _isAddCategoryPressed = false;

  @override
  void dispose() {
    newcategory.dispose();
    title.dispose();
    description.dispose();
    super.dispose(); 
  }

  void _showDatePicker(Color primaryColor) {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
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
      initialTime: TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute + 1,
      ),
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
          SelectedTime = value;
        });
      }
    });
  }

  Widget _buildPriorityButton(
    BuildContext context,
    String level,
    Color activeColor,
    Color inputFill,
    Color textBodyColor,
  ) {
    bool isSelected = priority == level;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => priority = level),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : inputFill.withOpacity(0.5),
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
      // --- UPGRADED PREMIUM APP BAR ---
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
                'New Task',
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
                    onTap: () => Navigator.of(context).pop(),
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
          // Dynamic Atmospheric Emitters
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
                    color: primaryColor.withOpacity(0.12),
                    blurRadius: 55,
                    spreadRadius: 15,
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
                key: taskFormKey,
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
                                hintText: 'What needs to be done?',
                                icon: Icons.title_rounded,
                                controller: title,
                                regex: [FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z ]'))],
                                valideter: (value) => (value == null || value.isEmpty) ? "Please enter a task title." : null,
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
                                hintText: 'Add extra details...',
                                icon: Icons.description_outlined,
                                controller: description,
                                valideter: (value) => (value == null || value.isEmpty) ? "Please enter a description." : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- CATEGORY SEGMENTED HUB ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Category Selection',
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: -0.3,
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (_) => setState(() => _isAddCategoryPressed = true),
                          onTapUp: (_) => setState(() => _isAddCategoryPressed = false),
                          onTapCancel: () => setState(() => _isAddCategoryPressed = false),
                          onTap: () => _openAddCategoryDialog(context, isDark, primaryColor, secondaryColor, surfaceColor, onSurfaceColor, dynamicTextBody),
                          child: AnimatedScale(
                            scale: _isAddCategoryPressed ? 0.94 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.add_rounded, size: 16, color: primaryColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Add New',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Display Categories using Wrap
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(category.length, (index) {
                        return CategoryCard(
                          category: category[index],
                          isSelected: _selectdvalue == category[index],
                          onTap: () => setState(() => _selectdvalue = category[index]),
                          onLongPress: () => setState(() => category.removeAt(index)),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // --- PRIORITY MATRIX AREA ---
                    Text(
                      'Task Urgency Mapping',
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
                        _buildPriorityButton(context, 'high', const Color(0xFFEF4444), dynamicInputFill, dynamicTextBody),
                        _buildPriorityButton(context, 'medium', const Color(0xFFF59E0B), dynamicInputFill, dynamicTextBody),
                        _buildPriorityButton(context, 'low', const Color(0xFF10B981), dynamicInputFill, dynamicTextBody),
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
                                      Text(
                                        selectedDate != null ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}" : "Select Date",
                                        style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 13),
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
                                      Text(
                                        SelectedTime != null ? SelectedTime!.format(context) : "Select Time",
                                        style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 13),
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

                    // --- THEME-REACTIVE ANIMATED SUBMIT LAYOUT BUTTON ---
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isCreatePressed = true),
                      onTapUp: (_) => setState(() => _isCreatePressed = false),
                      onTapCancel: () => setState(() => _isCreatePressed = false),
                      onTap: () {
                        if (!taskFormKey.currentState!.validate()) return;
                        if (_selectdvalue.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a Category'), backgroundColor: Colors.redAccent),
                          );
                          return;
                        }
                        if (selectedDate == null || SelectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select Date and Time'), backgroundColor: Colors.redAccent),
                          );
                          return;
                        }

                        int selectedMinutes = SelectedTime!.hour * 60 + SelectedTime!.minute;
                        int currentMinutes = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;

                        if (selectedDate!.day == DateTime.now().day &&
                            selectedDate!.month == DateTime.now().month &&
                            selectedDate!.year == DateTime.now().year) {
                          if (selectedMinutes <= currentMinutes) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a future time for today.'), backgroundColor: Colors.redAccent),
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

                        _showSuccessDialog(context, isDark, primaryColor, secondaryColor, surfaceColor, onSurfaceColor, dynamicTextBody);
                      },
                      child: AnimatedScale(
                        scale: _isCreatePressed ? 0.96 : 1.0,
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
                            'Create Task Blueprint',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UPGRADED ATTRACTIVE ADD CATEGORY DIALOG LAYER ---
  void _openAddCategoryDialog(
    BuildContext context, bool isDark, Color primaryColor, Color secondaryColor,
    Color surfaceColor, Color onSurfaceColor, Color textBodyColor
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AlertDialog(
              backgroundColor: surfaceColor.withOpacity(isDark ? 0.45 : 0.65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                  width: 1.5,
                ),
              ),
              title: Text(
                'New Custom Tag',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: onSurfaceColor, letterSpacing: -0.4),
              ),
              content: Form(
                key: keyForm,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextfield.customTextField(
                      context: context,
                      hintText: 'Enter tag index name...',
                      icon: Icons.tag_rounded,
                      controller: newcategory,
                      valideter: (value) => (value == null || value.isEmpty) ? 'Name cannot be empty' : null,
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: onSurfaceColor.withOpacity(0.6), fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  child: const Text('Append Tag', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- UPGRADED ATTRACTIVE SUCCESS DIALOG LAYER ---
  void _showSuccessDialog(
    BuildContext context, bool isDark, Color primaryColor, Color secondaryColor,
    Color surfaceColor, Color onSurfaceColor, Color textBodyColor
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
                side: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                  width: 1.5,
                ),
              ),
              backgroundColor: surfaceColor.withOpacity(isDark ? 0.45 : 0.65),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, val, child) {
                      return Transform.scale(scale: val, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1.5),
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 54),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Task Synchronized!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: onSurfaceColor, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your new task has been successfully integrated into your production list.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textBodyColor, fontSize: 14, height: 1.45, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: onSurfaceColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        SharedPreferences sp = await SharedPreferences.getInstance();
                        sp.setStringList('category', category);

                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const Bottomnavigation()),
                          );
                        }
                      },
                      child: Text(
                        'Perfect',
                        style: TextStyle(color: surfaceColor, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
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