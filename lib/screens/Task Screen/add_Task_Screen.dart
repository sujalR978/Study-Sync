import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/services/Task_service.dart';
import 'package:study_sync/widgets/category_card.dart';
import 'package:study_sync/widgets/custom_textfield.dart';
import 'package:custom_popup_dialog/custom_popup_dialog.dart';

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
  String priority = 'meduim';
  @override
  void dispose() {
    // TODO: implement dispose
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
    ).then(
      (value) => setState(() {
        selectedDate = value;
      }),
    );
  }

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute + 1,
      ),
    ).then(
      (Value) => setState(() {
        SelectedTime = Value;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(title.hashCode);
    print(description.hashCode);
    print(title.text);
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: taskFormKey,
          child: Column(
            children: [
              Text('Task title'),

              CustomTextfield.customTextField(
                hintText: 'add task',
                icon: Icons.add,
                controller: title,
                regex: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z ]')),
                ],
                valideter: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter task";
                  }
                  return null;
                },
              ),
              Text('Task Description'),
              CustomTextfield.customTextField(
                hintText: 'add  Description',
                icon: Icons.add,
                controller: description,
                valideter: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter Description";
                  }
                  return null;
                },
              ),
              Text('Category'),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Add Category'),
                        content: Form(
                          key: keyForm,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextfield.customTextField(
                                hintText: 'Enter category',
                                icon: Icons.category,
                                controller: newcategory,
                                valideter: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter Category';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              if (keyForm.currentState!.validate()) {
                                setState(() {
                                  category.add(newcategory.text);
                                });

                                Navigator.pop(context);
                                newcategory.clear();
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Add Category'),
              ),

              SizedBox(
                width: 350,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: category.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 6,
                    childAspectRatio: 2.7,
                  ),
                  itemBuilder: (context, index) {
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
                  },
                ),
              ),

              Text('due date'),
              ElevatedButton(
                onPressed: () {
                  _showDatePicker();
                },
                child: Row(
                  children: [
                    Icon(Icons.calendar_month),
                    Text(selectedDate.toString()),
                  ],
                ),
              ),

              Text('due time'),
              ElevatedButton(
                onPressed: () {
                  _showTimePicker();
                },
                child: Row(
                  children: [Icon(Icons.watch), Text(SelectedTime.toString())],
                ),
              ),
              Text('priority'),
              TextButton(
                onPressed: () {
                  setState(() {
                    priority = 'high';
                  });
                },
                child: Text('High'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    priority = 'meduim';
                  });
                },
                child: Text('Meduim'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    priority = 'Low';
                  });
                },
                child: Text('Low'),
              ),

              ElevatedButton(
                onPressed: () {
                  int selectedMinutes =
                      SelectedTime!.hour * 60 + SelectedTime!.minute;
                  int currentMinutes =
                      TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
                  if (taskFormKey.currentState!.validate() &&
                      SelectedTime != null) {
                    if (selectedMinutes <= currentMinutes) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a future time'),
                        ),
                      );
                      return;
                    }

                    TaskService().addTask(
                      title: title.text,
                      description: description.text,
                      category: _selectdvalue,
                      priority: priority,
                      dueDate: selectedDate!,
                      dueTime: SelectedTime.toString(),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  }
                },
                child: Text('save task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
