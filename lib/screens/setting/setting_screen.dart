import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math; // Used for random movement calculations
import 'package:provider/provider.dart';

// --- REQUIRED IMPORTS (Update paths if necessary) ---
// TODO: Replace with the actual path to your ThemeProvider
import 'package:study_sync/providers/them_provider.dart';
// TODO: Replace with the actual path to your AuthProvider
import 'package:study_sync/providers/auth_provider.dart';
// TODO: Replace with the actual path to your EditProfileScreen
import 'package:study_sync/screens/profile/editProfileScreen.dart';
// TODO: Replace with the actual path to your ProfileAvatar widget
import 'package:study_sync/widgets/profile_avatar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with TickerProviderStateMixin {
  // Animation controller for the slow, dynamic movement of the background blobs
  late AnimationController _backgroundMovementController;

  @override
  void initState() {
    super.initState();
    // Initialize movement controller (slow, continuous loop)
    _backgroundMovementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(); // Keep repeating the movement
  }

  @override
  void dispose() {
    _backgroundMovementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<Authprovider>();
    final user = authProvider.user;

    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Abstracting color tokens for the background movement
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color surfaceColor = theme.colorScheme.surface;
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    final List<Map<String, dynamic>> themeItems = [
      {
        'title': 'Minimal Light',
        'subtitle': 'Clean & distraction-free',
        'icon': Icons.wb_sunny_rounded,
        'type': AppThemeType.minimalLight,
        'bgPreview': const Color(0xFFF8F9FA),
        'accentPreview': const Color(0xFF3B82F6),
      },
      {
        'title': 'Minimal Dark',
        'subtitle': 'Deep focus & reduced glare',
        'icon': Icons.nightlight_round,
        'type': AppThemeType.minimalDark,
        'bgPreview': const Color(0xFF0F172A),
        'accentPreview': const Color(0xFF60A5FA),
      },
      {
        'title': 'Lo-Fi Aesthetic',
        'subtitle': 'Cozy, warm study sessions',
        'icon': Icons.headphones_rounded,
        'type': AppThemeType.loFiAesthetic,
        'bgPreview': const Color(0xFFFAF6F0),
        'accentPreview': const Color(0xFFE5989B),
      },
      {
        'title': 'Matcha Zen',
        'subtitle': 'Calming & anxiety-reducing',
        'icon': Icons.spa_rounded,
        'type': AppThemeType.matchaZen,
        'bgPreview': const Color(0xFFF4F7F4),
        'accentPreview': const Color(0xFF7D9D7C),
      },
      {
        'title': 'Night Owl',
        'subtitle': 'Late night anti-blue light',
        'icon': Icons.bedtime_rounded,
        'type': AppThemeType.nightOwl,
        'bgPreview': const Color(0xFF000000),
        'accentPreview': const Color(0xFFF59E0B),
      },
      {
        'title': 'AI Spark',
        'subtitle': 'Futuristic AI workspace',
        'icon': Icons.auto_awesome_rounded,
        'type': AppThemeType.aiSpark,
        'bgPreview': const Color(0xFF13111C),
        'accentPreview': const Color(0xFF8B5CF6),
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ===================================================================
          // --- THE UNIQUE UNIQUE DYNAMIC MOVING BACKGROUND MESH ---
          // This creates the layers needed to make glass effects visible
          // ===================================================================
          AnimatedBuilder(
            animation: _backgroundMovementController,
            builder: (context, child) {
              final double value = _backgroundMovementController.value;
              final size = MediaQuery.of(context).size;

              return Stack(
                children: [
                  // --- Blob 1 (Primary Color - Top Right) ---
                  _buildAnimatedBlob(
                    color: primaryColor.withOpacity(isDark ? 0.25 : 0.2),
                    t: value,
                    baseX: size.width * 0.7,
                    baseY: size.height * 0.1,
                    radius: 180,
                    driftSpeed: 1.5,
                  ),

                  // --- Blob 2 (Secondary Color - Bottom Left) ---
                  _buildAnimatedBlob(
                    color: secondaryColor.withOpacity(isDark ? 0.2 : 0.15),
                    t: value + 0.3, // Offset time for unique movement
                    baseX: size.width * 0.1,
                    baseY: size.height * 0.6,
                    radius: 220,
                    driftSpeed: 1.2,
                  ),

                  // --- Blob 3 (Alternative Color - Center) ---
                  _buildAnimatedBlob(
                    color: (isDark ? primaryColor : secondaryColor).withOpacity(
                      isDark ? 0.15 : 0.1,
                    ),
                    t: value + 0.7, // Offset time
                    baseX: size.width * 0.5,
                    baseY: size.height * 0.4,
                    radius: 150,
                    driftSpeed: 1.8,
                  ),
                ],
              );
            },
          ),
          // A global heavy blur mask to turn the blobs into a mesh
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(color: Colors.transparent),
            ),
          ),

          // --- MAIN SCROLLING CONTENT ---
          ListView(
            physics: const BouncingScrollPhysics(),
            // Added large top padding so the list starts below our floating header
            padding: const EdgeInsets.only(
              top: 130,
              left: 20,
              right: 20,
              bottom: 40,
            ),
            children: [
              // ========================================================
              // --- ACCOUNT SECTION ---
              // ========================================================
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ACCOUNT",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your personal student info",
                      style: TextStyle(
                        fontSize: 14,
                        color: onSurfaceColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Glassmorphic Account Overview Card
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(isDark ? 0.35 : 0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: onSurfaceColor.withOpacity(0.06),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Dynamic Avatar Display
                        ProfileAvatar(
                          photoUrl: user?.photoUrl ?? '',
                          radius: 36, // Large display size
                        ),
                        const SizedBox(width: 18),

                        // User Text Info (Expanded to take up space)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullname ?? 'Student',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: onSurfaceColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "@${user?.username ?? 'username'}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: onSurfaceColor.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- THE EDIT PROFILE ACTION BUTTON ---
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const Editprofilescreen(),
                              ),
                            );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface
                                .withOpacity(0.6),
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.05,
                              ),
                              width: 1,
                            ),
                          ),
                          icon: Icon(
                            Icons
                                .edit_note_rounded, // Premium looking edit icon
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 32,
              ), // Space between ACCOUNT and STUDY VIBES
              // ========================================================
              // --- STUDY VIBES SECTION ---
              // ========================================================
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "STUDY VIBES",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Personalize your workspace",
                      style: TextStyle(
                        fontSize: 14,
                        color: onSurfaceColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Existing theme list view builder (unchanged)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: themeItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = themeItems[index];

                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    builder: (context, animValue, child) {
                      return Opacity(
                        opacity: animValue,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1.0 - animValue)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildVibeCard(
                      context,
                      title: item['title'],
                      subtitle: item['subtitle'],
                      icon: item['icon'],
                      type: item['type'],
                      currentType: themeProvider.currentThemeType,
                      bgPreview: item['bgPreview'],
                      accentPreview: item['accentPreview'],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),

          // ===================================================================
          // --- THE UNIQUE FLOATING PILL HEADER ---
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
                    filter: ImageFilter.blur(
                      sigmaX: 25,
                      sigmaY: 25,
                    ), // Stronger blur for header
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
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
                          // Custom Back Button
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: onSurfaceColor.withOpacity(0.05),
                              shape: const CircleBorder(),
                            ),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: onSurfaceColor,
                              size: 18,
                            ),
                          ),

                          // Centered Title
                          Text(
                            'Settings',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                          ),

                          // Subtle Animated AI Sparkle Indicator
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.8, end: 1.2),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOut,
                              builder: (context, scale, child) {
                                // Creates a continuous pulsing effect
                                return Transform.scale(
                                  scale: scale,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: primaryColor,
                                    size: 18,
                                  ),
                                );
                              },
                              // Repeats the pulse animation indefinitely
                              onEnd: () {},
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
        ],
      ),
    );
  }

  // Redesigned Card for a horizontal row layout
  Widget _buildVibeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required AppThemeType type,
    required AppThemeType currentType,
    required Color bgPreview,
    required Color accentPreview,
  }) {
    final bool isSelected = type == currentType;
    final theme = Theme.of(context);
    final bool isDarkCard = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().setTheme(type),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Using AnimatedContainer ensures background glows change smoothly
              color: theme.colorScheme.surface.withOpacity(
                isDarkCard ? 0.35 : 0.6,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? accentPreview
                    : (isDarkCard
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05)),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: accentPreview.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Icon Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentPreview.withOpacity(0.15)
                        : theme.colorScheme.onSurface.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? accentPreview
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Color Previews & Checkmark
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSelected) ...[
                      // Show color dots when NOT selected
                      Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                          color: bgPreview,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                          color: accentPreview,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ] else ...[
                      // Show elegant checkmark when selected
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: accentPreview,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================================================================
  // --- BACKGROUND BLOB BUILDER WITH DYNAMIC DRIFT ---
  // Calculates slow random movement based on Ticker T
  // ===================================================================
  Widget _buildAnimatedBlob({
    required Color color,
    required double t,
    required double baseX,
    required double baseY,
    required double radius,
    required double driftSpeed,
  }) {
    // Math logic to calculate slow circular drift based on time
    final xOffset =
        math.sin(t * math.pi * 2 * driftSpeed) * 30; // 30 is drift range
    final yOffset = math.cos(t * math.pi * 2 * driftSpeed) * 20;

    return AnimatedPositioned(
      // Animated Positioned for smooth updates
      duration: const Duration(milliseconds: 100), // Smooth time updates
      top: baseY + yOffset,
      left: baseX + xOffset,
      child: Container(
        height: radius * 2,
        width: radius * 2,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
