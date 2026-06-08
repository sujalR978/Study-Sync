import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/providers/auth_provider.dart';

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
      providers: [ChangeNotifierProvider(create: (_) => Authprovider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // FIXED: Added 'ColorScheme' class before '.fromSeed'
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
