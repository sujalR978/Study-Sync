import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/auth/logout_screen.dart';

import 'package:study_sync/screens/profile/editProfileScreen.dart';
import 'package:study_sync/widgets/profile_avatar.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  bool _isEditPressed = false;
  bool _isLogoutPressed = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<Authprovider>().user;
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color surfaceColor = theme.colorScheme.surface;

    final Color dynamicTextBody = onSurfaceColor.withOpacity(0.50);
    final Color dynamicInputFill = Color.alphaBlend(
      primaryColor.withOpacity(isDark ? 0.12 : 0.05),
      surfaceColor,
    );

    if (user == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // --- TRANSITIONAL BACKDROP OVERLAYS ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [primaryColor, secondaryColor],
            ).createShader(bounds),
            child: const Text(
              'Account Hub',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 22,
                letterSpacing: -0.6,
              ),
            ),
          ),
          centerTitle: true,
          leadingWidth: 72,
    
        ),
      ),
      body: Stack(
        children: [
          // Background Light Emitters
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) {
                  return Opacity(
                    opacity: val,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1.0 - val)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. THE GLASS IDENTITY HEADER SCREEN ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: surfaceColor.withOpacity(
                              isDark ? 0.30 : 0.45,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.04),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              ProfileAvatar(
                                photoUrl: user.photoUrl,
                                radius: 56,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user.fullname,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: onSurfaceColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${user.username}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Inline Mini Actions Strip
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTapDown: (_) =>
                                          setState(() => _isEditPressed = true),
                                      onTapUp: (_) => setState(
                                        () => _isEditPressed = false,
                                      ),
                                      onTapCancel: () => setState(
                                        () => _isEditPressed = false,
                                      ),
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Editprofilescreen(),
                                        ),
                                      ),
                                      child: AnimatedScale(
                                        scale: _isEditPressed ? 0.96 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 100,
                                        ),
                                        child: Container(
                                          height: 46,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                primaryColor,
                                                secondaryColor,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.edit_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Edit Profile',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTapDown: (_) =>
                                        setState(() => _isLogoutPressed = true),
                                    onTapUp: (_) => setState(
                                      () => _isLogoutPressed = false,
                                    ),
                                    onTapCancel: () => setState(
                                      () => _isLogoutPressed = false,
                                    ),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LogoutScreen(),
                                      ),
                                    ),
                                    child: AnimatedScale(
                                      scale: _isLogoutPressed ? 0.94 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 100,
                                      ),
                                      child: Container(
                                        height: 46,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.05)
                                              : Colors.black.withOpacity(0.04),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.power_settings_new_rounded,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      "SECURE DATA METRICS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- 2. ASYMMETRIC METRIC BLOCK LAYOUT MESH ---
                    _buildAsymmetricTile(
                      context,
                      icon: Icons.alternate_email_rounded,
                      title: "Primary Communication",
                      value: user.email,
                      fillColor: dynamicInputFill,
                      textColor: dynamicTextBody,
                    ),
                    const SizedBox(height: 14),
                    _buildAsymmetricTile(
                      context,
                      icon: Icons.phone_android_rounded,
                      title: "Verified Mobile Network",
                      value: user.phone,
                      fillColor: dynamicInputFill,
                      textColor: dynamicTextBody,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsymmetricTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color fillColor,
    required Color textColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(isDark ? 0.25 : 0.45),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value.isNotEmpty ? value : "Not Configured",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
