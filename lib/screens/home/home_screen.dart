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

                return ReorderableListView(
                  children: [
                    for (final task in tasks)
                      ListTile(key: ValueKey(task), title: Text(task['title'])),
                  ],
                  onReorder: (oldindex, newindex) => () {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
