import 'dart:nativewrappers/_internal/vm/bin/vmservice_io.dart';

import 'package:flutter/material.dart';
import 'package:study_sync/services/notification_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(80),
            child: ElevatedButton(
              onPressed: () {
                NotificationService().showNotification(
                  title: 'howae',
                  body: 'khkjdshkdhfhsdf',
                );
              },
              child: Text('turn on notification'),
            ),
          ),
        ],
      ),
    );
  }
}
