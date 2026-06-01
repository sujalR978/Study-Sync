import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();
  List<String> category = ["Study", "Work", "Personal", "Health", "Shopping"];
  String _selectdvalue = '';

  @override
  void dispose() {
    // TODO: implement dispose
    newcategory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text('Task title'),
              CustomTextfield.customTextField(
                hintText: 'add task',
                icon: Icons.add,
                controller: TextEditingController(),
                regex: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]')),
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
                controller: TextEditingController(),
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
            ],
          ),
        ),
      ),
    );
  }
}
