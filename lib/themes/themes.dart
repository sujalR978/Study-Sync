import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart';

class AppThemes {
  // 1. DEFAULT LIGHT MODE
  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        bg: AppColors.background,
        primary: AppColors.primary,
        surface: AppColors.surface,
        text: AppColors.neutral,
      );

  // 2. DEFAULT DARK MODE
  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        bg: AppColors.darkBackground,
        primary: AppColors.primary,
        surface: AppColors.darkSurface,
        text: AppColors.darkNeutral,
      );

  // 3. NORDIC MINT THEME
  static ThemeData get nordicMintTheme => _buildTheme(
        brightness: Brightness.light,
        bg: AppColors.mintBackground,
        primary: AppColors.mintPrimary,
        surface: AppColors.mintSurface,
        text: AppColors.mintNeutral,
      );

  // 4. MIDNIGHT CRIMSON THEME
  static ThemeData get midnightCrimsonTheme => _buildTheme(
        brightness: Brightness.dark,
        bg: AppColors.crimsonBackground,
        primary: AppColors.crimsonPrimary,
        surface: AppColors.crimsonSurface,
        text: AppColors.crimsonNeutral,
      );

  // 5. CYBERPUNK NEON THEME (NEW - Dark Mode Variant)
  static ThemeData get cyberpunkNeonTheme => _buildTheme(
        brightness: Brightness.dark,
        bg: const Color(0xFF0D0E15), // Deep Midnight Cyber Black
        primary: const Color(0xFFFF007F), // Neon Pink/Magenta Accent
        surface: const Color(0xFF161925), // Dark Slate Card
        text: const Color(0xFFE2E8F0), // Cool White Text
        secondaryAccent: const Color(0xFF00F5FF), // Electric Cyan Subtext Accent
      );

  // 6. MUTED DESERT THEME (NEW - Light Mode Variant)
  static ThemeData get mutedDesertTheme => _buildTheme(
        brightness: Brightness.light,
        bg: const Color(0xFFF7F4EB), // Soft Warm Sand Cream
        primary: const Color(0xFFC97A53), // Terracotta/Warm Clay Accent
        surface: Colors.white,
        text: const Color(0xFF3E3631), // Deep Earthy Brown Text
        secondaryAccent: const Color(0xFF8A9A86), // Sage Green Subtext Accent
      );

  // 7. DEEP OCEAN THEME (NEW - Dark Mode Variant)
  static ThemeData get deepOceanTheme => _buildTheme(
        brightness: Brightness.dark,
        bg: const Color(0xFF06141D), // Abyss Dark Indigo
        primary: const Color(0xFF38BDF8), // Sky Blue Ripple Accent
        surface: const Color(0xFF0B2535), // Deep Sea Navy Card
        text: const Color(0xFFF0F9FF), // Ice Cap White Text
        secondaryAccent: const Color(0xFF34D399), // Seafoam Emerald Accent
      );

  // 8. AMETHYST ORCHID THEME (NEW - Dark Mode Variant)
  static ThemeData get amethystOrchidTheme => _buildTheme(
        brightness: Brightness.dark,
        bg: const Color(0xFF120E1E), // Velvet Black Grape
        primary: const Color(0xFFA855F7), // Radiant Purple Accent
        surface: const Color(0xFF1E1730), // Dark Lavender Card
        text: const Color(0xFFFAF5FF), // Orchid Tinted Light Text
        secondaryAccent: const Color(0xFFF472B6), // Soft Pink Highlights
      );

  // DRY Refactoring Principle: Reusable baseline internal constructor builder
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color primary,
    required Color surface,
    required Color text,
    Color secondaryAccent = AppColors.secondary,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        secondary: secondaryAccent,
        surface: surface,
        onSurface: text,
        error: Colors.redAccent,
        onError: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}