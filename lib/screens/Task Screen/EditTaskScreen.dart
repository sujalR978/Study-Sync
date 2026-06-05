import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  void _showDatePicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    ).then(
      (value) => setState(() {
        selectedDate = value!;
      }),
    );
  }

  void _showTimePicker() {
    showTimePicker(context: context, initialTime: TimeOfDay.now()).then(
      (value) => setState(() {
        selectedTime = value!.toString();
      }),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
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

      setState(() {
        selectedDate = (taskData['dueDate'] as Timestamp).toDate();
        selectedTime = taskData['dueTime'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextfield.customTextField(
              hintText: 'Enter Text',
              icon: Icons.abc,
              controller: taskName,
              regex: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
              valideter: (Value) {
                if (Value == null || Value.isEmpty) {
                  return 'Enter task';
                }
                return null;
              },
            ),
            CustomTextfield.customTextField(
              hintText: 'Enter description',
              icon: Icons.abc,
              controller: taskDescription,
              valideter: (Value) {
                if (Value == null || Value.isEmpty) {
                  return 'Enter Description';
                }
                return null;
              },
            ),

            SizedBox(
              height: 320,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: Category.length,
                itemBuilder: (context, index) {
                  String cat = Category[index];
                  bool _isSelected() => categorySelected == cat;
                  void _onTap() {
                    setState(() {
                      categorySelected = cat;
                    });
                  }

                  void _onLongPress() {}

                  return CategoryCard(
                    category: cat,
                    isSelected: _isSelected(),
                    onTap: _onTap,
                    onLongPress: _onLongPress,
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: () {
                _showDatePicker();
              },
              child: Text(selectedDate.toString()),
            ),
            ElevatedButton(
              onPressed: () {
                _showTimePicker();
              },
              child: Text(selectedTime.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
