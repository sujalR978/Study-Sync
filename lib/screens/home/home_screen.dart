import 'package:flutter/material.dart';
import 'package:study_sync/models/Task_model.dart';
import 'package:study_sync/screens/Task%20Screen/add_Task_Screen.dart';
import 'package:study_sync/screens/auth/googleInfo_screen.dart';
import 'package:study_sync/screens/auth/logout_screen.dart';
import 'package:study_sync/screens/profile/profileScreen.dart';
import 'package:study_sync/services/Task_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Profilescreen()),
                );
              },
              child: Text('profile'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddTaskScreen()),
                );
              },
              child: Text('Task add'),
            ),

            StreamBuilder(
              stream: TaskService().getTask(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No Tasks Found'));
                }

                final tasks = snapshot.data!.docs;

                return SizedBox(
                  height: 300,
                  child: ReorderableListView(
                    children: [
                      for (final task in tasks)
                        ListTile(
                          key: ValueKey(task.id),
                          title: Text(task['title']),
                          leading: Checkbox(
                            value: task['isCompleted'],
                            onChanged: (value) {
                              setState(() {
                                isClick = value!;
                              });
                            },
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task['category']),
                              Text(task['priority']),
                              Text(task['dueDate'].toString()),
                            ],
                          ),
                          trailing: const Icon(Icons.drag_handle),
                        ),
                    ],
                    onReorder: (oldindex, newindex) =>
                        updateMyTiel(oldindex, newindex, tasks),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
