import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/providers/them_provider.dart';

import 'package:study_sync/screens/splash/splash_screen.dart';
import 'package:study_sync/services/notification_service.dart';

import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationService = NotificationService();
  tz.initializeTimeZones();
  await notificationService.initializeNotification();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Authprovider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      builder: (context, child) {
        return const MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidgeet {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Flutter Demo',

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
      ),

      // --- CONFIGURING DARK MODE ---
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
      ),

      // ThemeMode.system adapts automatically if the phone toggles Dark Mode globally!
      themeMode: themProvider.themeMode,

      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
