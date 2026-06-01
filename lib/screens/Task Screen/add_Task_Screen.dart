import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/widgets/category_card.dart';
import 'package:study_sync/widgets/custom_textfield.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  String _selectdvalue = '';
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
              RadioGroup(
                groupValue: _selectdvalue,
                onChanged: (String? value) {
                  setState(() {
                    _selectdvalue = value!;
                  });
                },
                child: Container(
                  height: 500,
                  child: Column(
                    children: [
                      ListView.builder(
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          return category_card();
                        },
                      ),
                      Radio(value: 'value'),
                      Text('value'),
                      Radio(value: 'hi'),
                      Text('hi'),

                      Radio(value: 'hello'),
                      Text('hello'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
