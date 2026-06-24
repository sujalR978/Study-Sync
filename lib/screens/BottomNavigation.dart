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
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_navigatorKeys[currentIndex].currentState?.canPop() ?? false) {
          _navigatorKeys[currentIndex].currentState?.pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: [
            _buildNavigator(0, const HomeScreen()),
            _buildNavigator(1, const Notes()),
            _buildNavigator(2, const Profilescreen()),
            _buildNavigator(3, const SettingScreen()),
          ],
        ),
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
      ),
    );
  }

  Widget _buildNavigator(int index, Widget initialPage) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (context) => initialPage,
        );
      },
    );
  }
}
