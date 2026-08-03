import 'package:flutter/material.dart';
import 'package:study_sync/themes/themes.dart';


// The updated 6 student-focused themes
enum AppThemeType { 
  minimalLight, 
  minimalDark, 
  loFiAesthetic, 
  matchaZen,
  nightOwl,
  aiSpark
}

class ThemeProvider with ChangeNotifier {
  // Defaulting to the clean, distraction-free light mode
  AppThemeType _currentThemeType = AppThemeType.minimalLight;

  AppThemeType get currentThemeType => _currentThemeType;

  // Modifies the active theme globally across all listener nodes
  void setTheme(AppThemeType type) {
    _currentThemeType = type;
    notifyListeners();
  }

  // Resolves the baseline engine layer configuration mode for system overlays
  ThemeMode get themeMode {
    switch (_currentThemeType) {
      case AppThemeType.minimalDark:
      case AppThemeType.nightOwl:
      case AppThemeType.aiSpark:
        return ThemeMode.dark;
      case AppThemeType.minimalLight:
      case AppThemeType.loFiAesthetic:
      case AppThemeType.matchaZen:
        return ThemeMode.light;
    }
  }

  // Fetches the active theme directly from your new AppThemes class
  ThemeData get currentTheme {
    switch (_currentThemeType) {
      case AppThemeType.minimalLight:
        return AppThemes.minimalLight;
      case AppThemeType.minimalDark:
        return AppThemes.minimalDark;
      case AppThemeType.loFiAesthetic:
        return AppThemes.loFiAesthetic;
      case AppThemeType.matchaZen:
        return AppThemes.matchaZen;
      case AppThemeType.nightOwl:
        return AppThemes.nightOwl;
      case AppThemeType.aiSpark:
        return AppThemes.aiSpark;
    }
  }
}