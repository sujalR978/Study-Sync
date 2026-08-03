import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;


import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

import 'login_screen.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen>
    with TickerProviderStateMixin {
  bool isLoading = false;

  // Animation states for the buttons
  bool _isLogoutPressed = false;
  bool _isCancelPressed = false;

  // Background mesh animation controller
  late AnimationController _meshMovementController;

  @override
  void initState() {
    super.initState();
    // Initialize the energetic background movement
    _meshMovementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _meshMovementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color surfaceColor = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Extends body behind app bar for seamless frosted header look
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ===================================================================
          // --- 1. DYNAMIC ENERGETIC MOVING BACKGROUND MESH ---
          // ===================================================================
          AnimatedBuilder(
            animation: _meshMovementController,
            builder: (context, child) {
              final double t = _meshMovementController.value;
              final size = MediaQuery.of(context).size;

              return Stack(
                children: [
                  // --- Blob 1 (Primary Blue - Top Left) ---
                  _buildOrganicBlob(
                    color: const Color(
                      0xFF0052FF,
                    ).withOpacity(isDark ? 0.25 : 0.2),
                    t: t,
                    baseX: size.width * 0.7,
                    baseY: size.height * 0.1,
                    radius: 200,
                    driftSpeed: 1.2,
                    offsetSeed: 0.0,
                  ),

                  // --- Blob 2 (Cyan - Bottom Right) ---
                  _buildOrganicBlob(
                    color: const Color(
                      0xFF00D1FF,
                    ).withOpacity(isDark ? 0.2 : 0.15),
                    t: t,
                    baseX: size.width * 0.1,
                    baseY: size.height * 0.6,
                    radius: 220,
                    driftSpeed: 1.0,
                    offsetSeed: math.pi / 2, // 90 degree phase shift
                  ),
                ],
              );
            },
          ),
          // Intense Global Blur Mask to create the "Deep Mesh" gradient look
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                // Padding ensures content is placed below the floating header
                padding: const EdgeInsets.only(
                  top: 130,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ==========================================
                    // --- 2. PREMIUM GLASS LOGOUT CARD ---
                    // ==========================================
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            // Adaptive surface color switching
                            color: surfaceColor.withOpacity(
                              isDark ? 0.35 : 0.6,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: onSurfaceColor.withOpacity(0.06),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.15 : 0.04,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // ICON GLOW DOCK (Student-focused "rest" icon)
                              Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0052FF),
                                      Color(0xFF00D1FF),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00D1FF,
                                      ).withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.bedtime_rounded,
                                  size: 44,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // TITLE
                              Text(
                                "See You Soon 👋",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: onSurfaceColor,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // SUBTITLE (Dynamic descriptions lookup)
                              Text(
                                "Are you sure you want to rest?\nYour study data has been safely synced.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF64748B),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // --- TACTILE LOGOUT BUTTON ---
                              GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => _isLogoutPressed = true),
                                onTapUp: (_) =>
                                    setState(() => _isLogoutPressed = false),
                                onTapCancel: () =>
                                    setState(() => _isLogoutPressed = false),
                                onTap: () async {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  // 1. Perform backend logout
                                  await AuthService().logOut();

                                  if (!mounted) return;

                                  // 2. Clear local provider state
                                  context.read<Authprovider>().clearUser();

                                  setState(() {
                                    isLoading = false;
                                  });

                                  // 3. Navigate to Login (prevent back navigation)
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );

                                  // 4. SHOW SUCCESS MESSAGE
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Logged out successfully. Study hard! 📚',
                                      ),
                                      backgroundColor: Colors.green.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                child: AnimatedScale(
                                  scale: _isLogoutPressed ? 0.96 : 1.0,
                                  duration: const Duration(milliseconds: 100),
                                  child: Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF0052FF),
                                          Color(0xFF00D1FF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF00D1FF,
                                          ).withOpacity(0.25),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.logout_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Log out',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // --- TACTILE CANCEL BUTTON ---
                              GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => _isCancelPressed = true),
                                onTapUp: (_) =>
                                    setState(() => _isCancelPressed = false),
                                onTapCancel: () =>
                                    setState(() => _isCancelPressed = false),
                                onTap: () {
                                  // 1. POP context to previous screen
                                  Navigator.of(context).pop();

                                  // 2. SHOW CANCEL MESSAGE ("Logout Called")
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Logout Called.'),
                                      backgroundColor: onSurfaceColor
                                          .withOpacity(0.7),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: AnimatedScale(
                                  scale: _isCancelPressed ? 0.95 : 1.0,
                                  duration: const Duration(milliseconds: 100),
                                  child: Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      // Adaptive input fill colors lookup
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.06)
                                            : Colors.black.withOpacity(0.04),
                                        width: 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF475569),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- 3. SYNC STATUS INDICATOR ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(isDark ? 0.4 : 0.7),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: onSurfaceColor.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_done_rounded,
                            color: Color(0xFF0052FF),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "All changes synced",
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===================================================================
          // --- 4. FLOATING PILL HEADER ---
          // Includes Pulsing AI Icon
          // ===================================================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    100,
                  ), // Perfect pill shape
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(isDark ? 0.35 : 0.65),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: onSurfaceColor.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Custom Back Button scaled directly context consistency
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: onSurfaceColor.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: onSurfaceColor,
                                size: 18,
                              ),
                            ),
                          ),

                          // Centered Title teases AI integration focus AI AI
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                          ),

                          // AI Sparkle Indicator (consistent with other command centers)
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: primaryColor,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- LOADING OVERLAY MESH ---
          if (isLoading)
            Container(
              color: isDark ? Colors.black54 : Colors.white.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF0052FF)),
              ),
            ),
        ],
      ),
    );
  }

  // ===================================================================
  // --- BACKGROUND BLOB BUILDER WITH DYNAMIC DRIFT ---
  // Uses sine wave calculations on a reversed Repeat loop to simulate breathing/drift
  // ===================================================================
  Widget _buildOrganicBlob({
    required Color color,
    required double t,
    required double baseX,
    required double baseY,
    required double radius,
    required double driftSpeed,
    required double offsetSeed,
  }) {
    // organic Breathing/pulsing effect via sine over time
    final breathingVal = math.sin(t * math.pi * 2 + offsetSeed);

    // Slow organic drift calculation combining baseX/Y with breathing values
    final xOffset = breathingVal * 35 * driftSpeed; // x drift range
    final yOffset =
        math.cos(t * math.pi * 1.5 + offsetSeed) *
        25 *
        driftSpeed; // y unique path

    return AnimatedPositioned(
      // Animated Positioned for silky smooth updates based on movement controller
      duration: const Duration(
        milliseconds: 200,
      ), // Smooth time updates consistent across across nodes Listen globally across all nodes global Execute Execution
      curve: Curves.linear, // keep movement constant based on ticker
      top: baseY + yOffset,
      left: baseX + xOffset,
      child: Container(
        height: radius * 2,
        width: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          // Subtle glow effect Active theme Resolves configs Matrix mapping adaptive colors surface adaptive elevation configuration Adapt surface elevation looking configurations Matrix defined
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
