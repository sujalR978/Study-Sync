import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:study_sync/providers/them_provider.dart';
import 'package:study_sync/constants/app_colors.dart';


class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Abstracting semantic token pointers for maximum theme compliance
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color surfaceColor = theme.colorScheme.surface;

    // Defined item configuration matrix tracking all 8 themes explicitly
    final List<Map<String, dynamic>> themeItems = [
      {
        'title': 'Default Light',
        'icon': Icons.light_mode_rounded,
        'type': AppThemeType.light,
        'bgPreview': AppColors.background,
        'accentPreview': AppColors.primary,
      },
      {
        'title': 'Default Dark',
        'icon': Icons.dark_mode_rounded,
        'type': AppThemeType.dark,
        'bgPreview': AppColors.darkBackground,
        'accentPreview': AppColors.primary,
      },
      {
        'title': 'Nordic Mint',
        'icon': Icons.eco_rounded,
        'type': AppThemeType.nordicMint,
        'bgPreview': AppColors.mintBackground,
        'accentPreview': AppColors.mintPrimary,
      },
      {
        'title': 'Midnight Crimson',
        'icon': Icons.auto_awesome_motion_rounded,
        'type': AppThemeType.midnightCrimson,
        'bgPreview': AppColors.crimsonBackground,
        'accentPreview': AppColors.crimsonPrimary,
      },
      {
        'title': 'Cyberpunk Neon',
        'icon': Icons.electric_bolt_rounded,
        'type': AppThemeType.cyberpunkNeon,
        'bgPreview': const Color(0xFF0D0E15),
        'accentPreview': const Color(0xFFFF007F),
      },
      {
        'title': 'Muted Desert',
        'icon': Icons.landscape_rounded,
        'type': AppThemeType.mutedDesert,
        'bgPreview': const Color(0xFFF7F4EB),
        'accentPreview': const Color(0xFFC97A53),
      },
      {
        'title': 'Deep Ocean',
        'icon': Icons.water_rounded,
        'type': AppThemeType.deepOcean,
        'bgPreview': const Color(0xFF06141D),
        'accentPreview': const Color(0xFF38BDF8),
      },
      {
        'title': 'Amethyst Orchid',
        'icon': Icons.auto_awesome_rounded,
        'type': AppThemeType.amethystOrchid,
        'bgPreview': const Color(0xFF120E1E),
        'accentPreview': const Color(0xFFA855F7),
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // --- UPGRADED ULTRA-PREMIUM APP BAR ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.02),
                width: 1.0,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 70,
            centerTitle: true,
            title: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, secondaryColor],
              ).createShader(bounds),
              child: const Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors
                      .white, // Color set to white to act as gradient mask
                  fontSize: 22,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            leadingWidth: 72,
            
          ),
        ),
      ),
      body: Stack(
        children: [
          // Dynamic Glowing Orbs Background to enhance the glass distortion layers
          Positioned(
            top: 40,
            left: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.08),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.secondary.withOpacity(0.05),
                ),
              ),
            ),
          ),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1.0 - value)),
                  child: child,
                ),
              );
            },
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // --- SECTION HEADER ---
                Text(
                  "THEME EXPRESSIONS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // --- 8 THEME INTERACTIVE GRID SELECTOR WITH SCROLL PROTECTION ---
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: themeItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.35,
                  ),
                  itemBuilder: (context, index) {
                    final item = themeItems[index];

                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (index * 60)),
                      curve: Curves.easeOutBack,
                      builder: (context, animValue, child) {
                        return Transform.scale(
                          scale: 0.85 + (0.15 * animValue),
                          child: Opacity(
                            opacity: animValue.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: _buildThemeCard(
                        context,
                        title: item['title'],
                        icon: item['icon'],
                        type: item['type'],
                        currentType: themeProvider.currentThemeType,
                        bgPreview: item['bgPreview'],
                        accentPreview: item['accentPreview'],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required AppThemeType type,
    required AppThemeType currentType,
    required Color bgPreview,
    required Color accentPreview,
  }) {
    final bool isSelected = type == currentType;
    final theme = Theme.of(context);
    final isDarkCard = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        context.read<ThemeProvider>().setTheme(type);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ), // Upgraded High-fidelity frosted glass parameters
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              // Translucent acrylic styling blend maps cleanly across all 8 configurations
              color: theme.colorScheme.surface.withOpacity(
                isDarkCard ? 0.35 : 0.45,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? accentPreview
                    : (isDarkCard
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.04)),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? accentPreview.withOpacity(0.15)
                      : (isDarkCard
                            ? Colors.black26
                            : Colors.black.withOpacity(0.02)),
                  blurRadius: isSelected ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentPreview.withOpacity(
                            isSelected ? 0.2 : 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: accentPreview, size: 18),
                      ),
                      if (isSelected)
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 200),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: accentPreview,
                                size: 20,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: bgPreview,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: accentPreview,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
