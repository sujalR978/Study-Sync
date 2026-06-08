import 'package:flutter/material.dart';
import 'package:study_sync/services/notification_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(80),
            child: ElevatedButton(
              onPressed: () async {
                await notificationService.showNotification(
                  title: 'Study Sync',
                  body: 'Notification is working!',
                  scheduledTime: DateTime.now().add(const Duration(seconds: 5))
                );
              },
              child: const Text('turn on notification'),
            ),
          ),
        ],
      ),
    );
  }
}
