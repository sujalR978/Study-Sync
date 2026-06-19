import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/providers/them_provider.dart';

import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/screens/BottomNavigation.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onBackground,
          ), 
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => Bottomnavigation())),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // Visual Header Title
          const Text(
            "Appearance",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          // --- MODERN LIGHT/DARK MODE TOGGLE CARD ---
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              title: const Text(
                'Dark Theme',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                isDark
                    ? 'Using dark contrast layout'
                    : 'Using vibrant light layout',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Switch(
                value: isDark,
                activeColor: AppColors.primary,
                onChanged: (bool value) {
                  context.read<ThemeProvider>().toggleTheme(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
