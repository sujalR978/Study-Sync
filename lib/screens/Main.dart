import 'package:flutter/material.dart';
import 'package:study_sync/screens/Task%20Screen/add_Task_Screen.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/screens/profile/profileScreen.dart';

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int currentIndex = 0;

  final List<Widget> page = [
    const HomeScreen(),
    const AddTaskScreen(),
    const Profilescreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: page[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_task),
            label: "Add Task",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
