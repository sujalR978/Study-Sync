import 'dart:io';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/auth/logout_screen.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/screens/profile/editProfileScreen.dart';
import 'package:study_sync/constants/app_colors.dart'; // Adjust path if needed

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<Authprovider>().user;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const HomeScreen())),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // --- AVATAR SECTION ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: isDark
                      ? AppColors.darkInputFill
                      : AppColors.inputFill,
                  backgroundImage: _getProfileImage(
                    user.photoUrl,
                    user.loginMethod,
                  ),
                  child: (user.photoUrl.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: isDark
                              ? AppColors.darkTextBody
                              : AppColors.textBody,
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              // --- NAME & USERNAME ---
              Text(
                user.fullname,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@${user.username}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),

              const SizedBox(height: 32),

              // --- CONTACT INFO CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface, 
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black26
                          : Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      context,
                      Icons.email_outlined,
                      "Email Address",
                      user.email,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        color: isDark
                            ? AppColors.darkInputFill
                            : AppColors.inputFill,
                        thickness: 1,
                      ),
                    ),
                    _buildInfoTile(
                      context,
                      Icons.phone_outlined,
                      "Phone Number",
                      user.phone,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- EDIT PROFILE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Editprofilescreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- LOGOUT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LogoutScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER METHODS ---
  ImageProvider? _getProfileImage(String url, String method) {
    if (url.isEmpty) return null;

    if (url.startsWith('http') || method == 'google') {
      return NetworkImage(url);
    } else if (url.startsWith('/data/')) {
      return FileImage(File(url));
    } else {
      return AssetImage(url);
    }
  }

 
  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextBody : AppColors.textBody,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isNotEmpty ? value : "Not provided",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}