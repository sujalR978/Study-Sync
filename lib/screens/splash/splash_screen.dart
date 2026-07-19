import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/models/user_model.dart';
import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/screens/auth/login_screen.dart';
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
    super.initState();
    // Execute everything sequentially in a single structured pipeline
    _initializeApplication();
  }

  Future<void> _initializeApplication() async {
    // 1. Start a minimum timing benchmark so the screen doesn't flicker away too fast
    final stopwatch = Stopwatch()..start();

    // 2. Fetch User Data if Firebase has an active token session
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        UserModel? userData = await AuthService().getCurrentUserData();
        if (userData != null && mounted) {
          // Safely set your provider state profile values
          Provider.of<Authprovider>(context, listen: false).setUser(userData);
        }
      } catch (e) {
        debugPrint("Error fetching user session data: $e");
      }
    }

    // 3. Look up client authorization preferences from disk
    final SharedPreferences spget = await SharedPreferences.getInstance();
    bool remember = spget.getBool('logIn') ?? false;

    // 4. Stop the watch and calculate remaining structural layout display delay
    stopwatch.stop();
    int elapsedMilliseconds = stopwatch.elapsedMilliseconds;
    int remainingDelay = 2000 - elapsedMilliseconds;

    if (remainingDelay > 0) {
      await Future.delayed(Duration(milliseconds: remainingDelay));
    }

    if (!mounted) return;

    // 5. Route seamlessly out of the initialization phase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            remember ? const Bottomnavigation() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 70),
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
                    customText.titalText('Study Sync', context: context),
                    const SizedBox(height: 15),
                    customText.opacityText(
                      'Study Smart, Stay Focused',
                      context: context,
                    ),
                  ],
                ),
              ),

              /// BOTTOM CONTENT
              Column(
                children: [
                  Text(
                    'INITIALIZING HUB...',
                    style: TextStyle(
                      color: isDark ? AppColors.darkNeutral : AppColors.neutral,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 300,
                    child: LinearProgressIndicator(
                      backgroundColor: isDark ? Colors.white10 : Colors.black12,
                      color: AppColors.primary,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
