import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:provider/provider.dart';

// --- REQUIRED IMPORTS ---
import 'package:study_sync/providers/them_provider.dart';
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
  // Button press states
  bool _isEditPressed = false;
  bool _isLogoutPressed = false;

  // Background animation controller
  late AnimationController _meshMovementController;

  @override
  void initState() {
    super.initState();
    _meshMovementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
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

    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color surfaceColor = theme.colorScheme.surface;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color scaffoldColor = theme.scaffoldBackgroundColor;

    final Color dynamicTextBody = onSurfaceColor.withOpacity(0.50);
    final Color dynamicInputFill = Color.alphaBlend(
      primaryColor.withOpacity(isDark ? 0.12 : 0.05),
      surfaceColor,
    );

    // Theme Options Data
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

    if (user == null) {
      return Scaffold(
        backgroundColor: scaffoldColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Stack(
        children: [
          // ===================================================================
          // --- 1. DYNAMIC HYPNOTIC MESH BACKGROUND ---
          // ===================================================================
          AnimatedBuilder(
            animation: _meshMovementController,
            builder: (context, child) {
              final double t = _meshMovementController.value;
              final size = MediaQuery.of(context).size;
              return Stack(
                children: [
                  _buildOrganicBlob(
                    color: primaryColor.withOpacity(isDark ? 0.35 : 0.3),
                    t: t,
                    baseX: size.width * 0.75,
                    baseY: size.height * 0.15,
                    radius: 200,
                    driftSpeed: 1.2,
                    offsetSeed: 0.0,
                  ),
                  _buildOrganicBlob(
                    color: secondaryColor.withOpacity(isDark ? 0.25 : 0.2),
                    t: t,
                    baseX: size.width * 0.15,
                    baseY: size.height * 0.7,
                    radius: 250,
                    driftSpeed: 1.0,
                    offsetSeed: math.pi / 2,
                  ),
                  _buildOrganicBlob(
                    color: (isDark ? primaryColor : secondaryColor).withOpacity(
                      isDark ? 0.2 : 0.15,
                    ),
                    t: t,
                    baseX: size.width * 0.5,
                    baseY: size.height * 0.45,
                    radius: 180,
                    driftSpeed: 1.5,
                    offsetSeed: math.pi,
                  ),
                ],
              );
            },
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 110, sigmaY: 110),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ===================================================================
          // --- 2. MAIN SCROLLING CONTENT ---
          // ===================================================================
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              top: 130,
              left: 20,
              right: 20,
              bottom: 40,
            ),
            children: [
              // --- IDENTITY CARD WITH OVERLAPPING AVATAR ---
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // The Glass Card Base
                  Container(
                    margin: const EdgeInsets.all(
                      55,
                    ), // Space for avatar to overlap
                    padding: const EdgeInsets.fromLTRB(24, 65, 24, 24),
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(isDark ? 0.35 : 0.6),
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
                        const SizedBox(height: 6),
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

                        // Action Buttons Row (Edit & Logout)
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => _isEditPressed = true),
                                onTapUp: (_) =>
                                    setState(() => _isEditPressed = false),
                                onTapCancel: () =>
                                    setState(() => _isEditPressed = false),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const Editprofilescreen(),
                                  ),
                                ),
                                child: AnimatedScale(
                                  scale: _isEditPressed ? 0.95 : 1.0,
                                  duration: const Duration(milliseconds: 100),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [primaryColor, secondaryColor],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.3),
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
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => _isLogoutPressed = true),
                                onTapUp: (_) =>
                                    setState(() => _isLogoutPressed = false),
                                onTapCancel: () =>
                                    setState(() => _isLogoutPressed = false),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LogoutScreen(),
                                  ),
                                ),
                                child: AnimatedScale(
                                  scale: _isLogoutPressed ? 0.95 : 1.0,
                                  duration: const Duration(milliseconds: 100),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
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

                  // The Overlapping Avatar (Now scrolls cleanly)
                  Positioned(
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        // Matches the background perfectly to look like it cuts into the card
                        color: scaffoldColor.withOpacity(0.5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ProfileAvatar(photoUrl: user.photoUrl, radius: 55),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // --- STUDY GAMIFICATION STATS ---
              _buildSectionHeader(
                primaryColor,
                onSurfaceColor,
                "STUDY PROGRESS",
                "Your current learning metrics",
              ),
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
              const SizedBox(height: 36),

              // --- ACCOUNT DETAILS ---
              _buildSectionHeader(
                primaryColor,
                onSurfaceColor,
                "SECURE DATA METRICS",
                "Account contact information",
              ),
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
              const SizedBox(height: 36),

              // --- STUDY VIBES (THEMES) ---
              _buildSectionHeader(
                primaryColor,
                onSurfaceColor,
                "STUDY VIBES",
                "Personalize your workspace",
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: themeItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = themeItems[index];
                  return _buildVibeCard(
                    context,
                    title: item['title'],
                    subtitle: item['subtitle'],
                    icon: item['icon'],
                    type: item['type'],
                    currentType: themeProvider.currentThemeType,
                    bgPreview: item['bgPreview'],
                    accentPreview: item['accentPreview'],
                  );
                },
              ),
            ],
          ),

          // ===================================================================
          // --- 3. FLOATING PILL APP BAR (From Settings) ---
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
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
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
                          // Conditional Back Button (Only shows if pushed)
                          if (Navigator.canPop(context))
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
                                  size: 16,
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 40), // Balance
                          // Centered Title
                          Text(
                            'Account Hub',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                          ),

                          // AI Sparkle Indicator
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
                                return Transform.scale(
                                  scale: scale,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: primaryColor,
                                    size: 18,
                                  ),
                                );
                              },
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

  // --- WIDGET BUILDERS ---

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

  Widget _buildOrganicBlob({
    required Color color,
    required double t,
    required double baseX,
    required double baseY,
    required double radius,
    required double driftSpeed,
    required double offsetSeed,
  }) {
    final breathingVal = math.sin(t * math.pi * 2 + offsetSeed);
    final xOffset = breathingVal * 35 * driftSpeed;
    final yOffset = math.cos(t * math.pi * 1.5 + offsetSeed) * 25 * driftSpeed;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
      top: baseY + yOffset,
      left: baseX + xOffset,
      child: Container(
        height: radius * 2,
        width: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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
                if (!isSelected)
                  Row(
                    children: [
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
                    ],
                  )
                else
                  Container(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
