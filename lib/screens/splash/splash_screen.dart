import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/models/user_model.dart';
import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/auth/login_screen.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/services/auth_service.dart';
import 'package:study_sync/widgets/custom_textfield.dart';
import 'package:study_sync/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();

    getData();
  }

  Future<void> loadUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      UserModel? userData = await AuthService().getCurrentUserData();

      if (userData != null) {
        context.read<Authprovider>().setUser(userData);
      }
    }
  }

  void getData() async {
    final SharedPreferences spget = await SharedPreferences.getInstance();
    bool remember = spget.getBool('logIn') ?? false;

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => remember ? HomeScreen() : LoginScreen(),
      ),
    );
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
