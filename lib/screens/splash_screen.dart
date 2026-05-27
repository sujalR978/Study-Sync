import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart';

class splsh_screen extends StatelessWidget {
  const splsh_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Text('INITIALIZING HUB...'),
              SizedBox(
                width: 300,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.white,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
