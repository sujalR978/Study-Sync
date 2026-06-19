import 'package:flutter/material.dart';
import 'package:study_sync/screens/Notes/Notes.dart';

import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/screens/profile/profileScreen.dart';
import 'package:study_sync/screens/setting/setting_screen.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _MainState();
}

class _MainState extends State<Bottomnavigation> {
  int currentIndex = 0;

  final List<Widget> page = [
    const HomeScreen(),
    const Notes(),
    const Profilescreen(),
    const SettingScreen(),
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
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 89, 33, 243),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notes), label: "Notes"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
        ],
      ),
    );
  }
}
