import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart';

class UserAsk extends StatefulWidget {
  final String lastUserPrompt;
  const UserAsk({super.key, required this.lastUserPrompt});

  @override
  State<UserAsk> createState() => _UserAskState();
}

class _UserAskState extends State<UserAsk> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.primary, // Brand color remains static
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Text(
          widget.lastUserPrompt,
          style: const TextStyle(
            color: Colors.white, // Text remains white on primary background
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
