import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
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

class _ProfilescreenState extends State<Profilescreen>
    with TickerProviderStateMixin {
  bool _isEditPressed = false;
  bool _isLogoutPressed = false;

  // Animation controller for the ambient background breathing effect
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

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
      extendBodyBehindAppBar:
          true, // Allows the background to flow under the app bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Account Hub',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: onSurfaceColor,
              fontSize: 22,
              letterSpacing: -0.6,
            ),
          ),
          centerTitle: true,
          leadingWidth: 72,
        ),
      ),
      body: Stack(
        children: [
          // ==========================================
          // --- AMBIENT BREATHING BACKGROUND ---
          // ==========================================
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final double t = _bgController.value;
              final size = MediaQuery.of(context).size;

              return Stack(
                children: [
                  Positioned(
                    top: size.height * 0.1 + (math.sin(t * math.pi) * 30),
                    left: size.width * 0.1 - (math.cos(t * math.pi) * 20),
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.4 - (math.sin(t * math.pi) * 40),
                    right: size.width * 0.05 + (math.cos(t * math.pi) * 20),
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: secondaryColor.withOpacity(0.06),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ==========================================
          // --- MAIN SCROLLABLE CONTENT ---
          // ==========================================
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    const SizedBox(height: 40), // Space for overlapping avatar
                    // --- 1. OVERLAPPING GLASS IDENTITY HEADER ---
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        // The Glass Card
                        Container(
                          margin: const EdgeInsets.only(50), // Push card down
                          padding: const EdgeInsets.fromLTRB(
                            24,
                            70,
                            24,
                            24,
                          ), // Extra top padding for avatar
                          decoration: BoxDecoration(
                            color: surfaceColor.withOpacity(
                              isDark ? 0.35 : 0.6,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.04),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '@${user.username}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Action Buttons Row
                              Row(
                                children: [
                                  // Edit Button
                                  Expanded(
                                    flex: 2,
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
                                        scale: _isEditPressed ? 0.95 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 100,
                                        ),
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                primaryColor,
                                                secondaryColor,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryColor.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.manage_accounts_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Edit Profile',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Logout Button
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTapDown: (_) => setState(
                                        () => _isLogoutPressed = true,
                                      ),
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
                                        scale: _isLogoutPressed ? 0.95 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 100,
                                        ),
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.error
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: theme.colorScheme.error
                                                  .withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.logout_rounded,
                                            color: theme.colorScheme.error,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // The Overlapping Avatar
                        Positioned(
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ProfileAvatar(
                              photoUrl: user.photoUrl,
                              radius: 56,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ==========================================
                    // --- 2. NEW: STUDY GAMIFICATION STATS ---
                    // ==========================================
                    Text(
                      "STUDY PROGRESS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          icon: Icons.local_fire_department_rounded,
                          value: "12",
                          label: "Day Streak",
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          context,
                          icon: Icons.timer_rounded,
                          value: "48",
                          label: "Hours",
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          context,
                          icon: Icons.task_alt_rounded,
                          value: "105",
                          label: "Tasks",
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ==========================================
                    // --- 3. CONTACT INFO MESH ---
                    // ==========================================
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
                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW: Gamification Stat Card Builder ---
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(
                isDark ? 0.25 : 0.45,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UPDATED: Contact Info Tile Builder ---
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
