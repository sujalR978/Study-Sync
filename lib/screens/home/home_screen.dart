import 'package:flutter/material.dart';
import 'package:study_sync/screens/auth/logout_screen.dart';
import 'package:study_sync/screens/profile/profileScreen.dart';

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
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => LogoutScreen()));
              },
              child: Text('logout'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Profilescreen()),
                );
              },
              child: Text('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
