import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/screens/auth/login_screen.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/widgets/custom_textfield.dart';
import 'package:study_sync/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool remember = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    navigation();
    getData();
  }

  void getData() async {
    final SharedPreferences spget = await SharedPreferences.getInstance();
    remember = spget.getBool('logIn') ?? false;
  }

  void navigation() {
    Timer(Duration(milliseconds: 2000), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => remember ? HomeScreen() : LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 70, right: 70),

          child: Column(
            children: [
              /// CENTER CONTENT
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    SizedBox(
                      width: 120,
                      child: Image.asset('assets/icons/ic_appIcon.png'),
                    ),

                    const SizedBox(height: 20),

                    customText.titalText('Study Sync'),

                    const SizedBox(height: 15),

                    customText.opacityText('Study Smart, Stay Focused'),
                  ],
                ),
              ),

              /// BOTTOM CONTENT
              Column(
                children: [
                  const Text(
                    'INITIALIZING HUB...',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: 300,

                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white24,
                      color: AppColors.primary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
