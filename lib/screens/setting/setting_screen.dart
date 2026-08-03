import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math; // Used for organic movement calculations
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
  // Controller for the faster, organic breathing movement of the background mesh
  late AnimationController _meshMovementController;

  @override
  void initState() {
    super.initState();
    // Initialize mesh movement (moderate speed for hypnotic flow)
    _meshMovementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true); // organic breathing effect
  }

  @override
  void dispose() {
    _meshMovementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<Authprovider>();
    final user = authProvider.user;

    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Abstracting color tokens for the dynamic background
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
          // --- THE UNIQUE ENHANCED HYPNOTIC ANIMATED MESH BACKGROUND ---
          // Creates layers of drifting, organic gradients that attract users
          // ===================================================================
          AnimatedBuilder(
            animation: _meshMovementController,
            builder: (context, child) {
              final double t = _meshMovementController.value;
              final size = MediaQuery.of(context).size;

              return Stack(
                children: [
                  // --- Blob 1 (Primary Deep Drift - organically moving) ---
                  _buildOrganicBlob(
                    color: primaryColor.withOpacity(isDark ? 0.35 : 0.3),
                    t: t,
                    baseX: size.width * 0.75,
                    baseY: size.height * 0.15,
                    radius: 200,
                    driftSpeed: 1.2,
                    offsetSeed: 0.0,
                  ),

                  // --- Blob 2 (Secondary Wide Flow - different drift) ---
                  _buildOrganicBlob(
                    color: secondaryColor.withOpacity(isDark ? 0.25 : 0.2),
                    t: t,
                    baseX: size.width * 0.15,
                    baseY: size.height * 0.7,
                    radius: 250,
                    driftSpeed: 1.0,
                    offsetSeed: math.pi / 2, // 90 degree phase shift
                  ),

                  // --- Blob 3 (Alternative Pulse - center-focused) ---
                  _buildOrganicBlob(
                    color: (isDark ? primaryColor : secondaryColor).withOpacity(
                      isDark ? 0.2 : 0.15,
                    ),
                    t: t,
                    baseX: size.width * 0.5,
                    baseY: size.height * 0.45,
                    radius: 180,
                    driftSpeed: 1.5,
                    offsetSeed: math.pi, // 180 degree phase shift
                  ),
                ],
              );
            },
          ),
          // Intense Global Blur Mask to create the "Deep Mesh" look
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 110, sigmaY: 110),
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
              _buildSectionHeader(
                primaryColor,
                onSurfaceColor,
                "ACCOUNT",
                "Your personal student info",
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

                        // --- THE UPDATED EDIT PROFILE ACTION BUTTON (NEW!) ---
                        // Replaced icon with stadium button containing name 'Edit'
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const Editprofilescreen(),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor, // solid prominent color
                              borderRadius: BorderRadius.circular(
                                100,
                              ), // Stadium shape
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons
                                      .manage_accounts_rounded, // New professional edit icon
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Edit', // Add Name
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ========================================================
              // --- STUDENT ACHIEVEMENTS SECTION (ADDITION!) ---
              // Gamification acts as attraction to keep students engaged
              // ========================================================
              _buildSectionHeader(
                primaryColor,
                onSurfaceColor,
                "STUDY STREAK & AWARDS",
                "You are killing it this week!",
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(isDark ? 0.35 : 0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: onSurfaceColor.withOpacity(0.06),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: secondaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.local_fire_department,
                                color: secondaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "12 Day Streak",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: onSurfaceColor,
                                  ),
                                ),
                                Text(
                                  "Last studied: 2h ago",
                                  style: TextStyle(
                                    color: onSurfaceColor.withOpacity(0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Small award icon teaser
                        Icon(
                          Icons.emoji_events_rounded,
                          color: primaryColor.withOpacity(0.7),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ========================================================
              // --- STUDY VIBES SECTION ---
              // ========================================================
              _buildSectionHeader(
                primaryColor,
                onSurfaceColor,
                "STUDY VIBES",
                "Personalize your workspace",
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
          // --- THE FIXED FLOATING PILL HEADER & APP BAR NAV ---
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
                          // Custom Back Button styled to match premium look
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
                                size: 16, // premium slightly smaller size
                              ),
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

  // Reusable Section Header builder to maintain consistency
  Widget _buildSectionHeader(
    Color primaryColor,
    Color onSurfaceColor,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: primaryColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: onSurfaceColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // Redesigned Vibe Card for a horizontal row layout
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
  // --- ORGANIC DYNAMIC BACKGROUND BLOB BUILDER ---
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
    // organic Breathing/pulsing effect via sine over time (ticker reverses for smoothness)
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
      ), // Smooth time updates to prevent banding
      curve: Curves.linear, // keep movement constant based on ticker
      top: baseY + yOffset,
      left: baseX + xOffset,
      child: Container(
        height: radius * 2,
        width: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          // Subtle glow effect
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
