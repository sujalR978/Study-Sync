import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart';

// Expanded enum explicitly incorporating all 8 premium visual themes
enum AppThemeType { 
  light, 
  dark, 
  nordicMint, 
  midnightCrimson,
  cyberpunkNeon,
  mutedDesert,
  deepOcean,
  amethystOrchid
}

class ThemeProvider with ChangeNotifier {
  AppThemeType _currentThemeType = AppThemeType.light;

  AppThemeType get currentThemeType => _currentThemeType;

  // Modifies the active theme execution pointer globally across all listener nodes
  void setTheme(AppThemeType type) {
    _currentThemeType = type;
    notifyListeners();
  }

  // Resolves the baseline engine layer configuration mode for system overlays
  ThemeMode get themeMode {
    switch (_currentThemeType) {
      case AppThemeType.dark:
      case AppThemeType.midnightCrimson:
      case AppThemeType.cyberpunkNeon:
      case AppThemeType.deepOcean:
      case AppThemeType.amethystOrchid:
        return ThemeMode.dark;
      case AppThemeType.light:
      case AppThemeType.nordicMint:
      case AppThemeType.mutedDesert:
        return ThemeMode.light;
    }
  }

  // Active theme constructor matrix mapped directly to the active configuration values
  ThemeData get currentTheme {
    switch (_currentThemeType) {
      case AppThemeType.light:
        return _buildTheme(Brightness.light, AppColors.background, AppColors.primary, AppColors.surface, AppColors.neutral);
      case AppThemeType.nordicMint:
        return _buildTheme(Brightness.light, AppColors.mintBackground, AppColors.mintPrimary, AppColors.mintSurface, AppColors.mintNeutral);
      case AppThemeType.mutedDesert:
        return _buildTheme(Brightness.light, const Color(0xFFF7F4EB), const Color(0xFFC97A53), Colors.white, const Color(0xFF3E3631), secondaryAccent: const Color(0xFF8A9A86));
      
      case AppThemeType.dark:
        return _buildTheme(Brightness.dark, AppColors.darkBackground, AppColors.primary, AppColors.darkSurface, AppColors.darkNeutral);
      case AppThemeType.midnightCrimson:
        return _buildTheme(Brightness.dark, AppColors.crimsonBackground, AppColors.crimsonPrimary, AppColors.crimsonSurface, AppColors.crimsonNeutral);
      case AppThemeType.cyberpunkNeon:
        return _buildTheme(Brightness.dark, const Color(0xFF0D0E15), const Color(0xFFFF007F), const Color(0xFF161925), const Color(0xFFE2E8F0), secondaryAccent: const Color(0xFF00F5FF));
      case AppThemeType.deepOcean:
        return _buildTheme(Brightness.dark, const Color(0xFF06141D), const Color(0xFF38BDF8), const Color(0xFF0B2535), const Color(0xFFF0F9FF), secondaryAccent: const Color(0xFF34D399));
      case AppThemeType.amethystOrchid:
        return _buildTheme(Brightness.dark, const Color(0xFF120E1E), const Color(0xFFA855F7), const Color(0xFF1E1730), const Color(0xFFFAF5FF), secondaryAccent: const Color(0xFFF472B6));
    }
  }

  // Fallback dark engine reference matching baseline systems
  ThemeData get currentDarkTheme => _buildTheme(Brightness.dark, AppColors.darkBackground, AppColors.primary, AppColors.darkSurface, AppColors.darkNeutral);

  // Central baseline constructor config passing elements downstream into the Material 3 generation layer
  ThemeData _buildTheme(
    Brightness brightness, 
    Color bg, 
    Color primary, 
    Color surface, 
    Color text, {
    Color? secondaryAccent,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        secondary: secondaryAccent ?? AppColors.secondary,
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