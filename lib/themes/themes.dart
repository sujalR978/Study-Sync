import 'package:flutter/material.dart';


class AppThemes {
  // 1. MINIMAL LIGHT (Clean, distraction-free daytime studying)
  static ThemeData get minimalLight => _buildTheme(
        brightness: Brightness.light,
        bg: const Color(0xFFF8F9FA),
        primary: const Color(0xFF3B82F6),
        surface: Colors.white,
        text: const Color(0xFF1E293B),
      );

  // 2. MINIMAL DARK (Deep slate for standard night studying)
  static ThemeData get minimalDark => _buildTheme(
        brightness: Brightness.dark,
        bg: const Color(0xFF0F172A),
        primary: const Color(0xFF60A5FA),
        surface: const Color(0xFF1E293B),
        text: const Color(0xFFF8FAFC),
      );

  // 3. LO-FI AESTHETIC (Warm, pastel paper feel)
  static ThemeData get loFiAesthetic => _buildTheme(
        brightness: Brightness.light,
        bg: const Color(0xFFFAF6F0),
        primary: const Color(0xFFE5989B),
        surface: Colors.white,
        text: const Color(0xFF5C4D4D),
        secondaryAccent: const Color(0xFFFFB4A2),
      );

  // 4. MATCHA ZEN (Calming greens to reduce study anxiety)
  static ThemeData get matchaZen => _buildTheme(
        brightness: Brightness.light,
        bg: const Color(0xFFF4F7F4),
        primary: const Color(0xFF7D9D7C),
        surface: Colors.white,
        text: const Color(0xFF2C3B2D),
        secondaryAccent: const Color(0xFFA3B899),
      );

  // 5. NIGHT OWL (OLED black, amber accents to cut blue light late at night)
  static ThemeData get nightOwl => _buildTheme(
        brightness: Brightness.dark,
        bg: const Color(0xFF000000),
        primary: const Color(0xFFF59E0B),
        surface: const Color(0xFF121212),
        text: const Color(0xFFD4D4D8),
        secondaryAccent: const Color(0xFFFBBF24),
      );

  // 6. AI SPARK (Futuristic but professional for AI interaction focus)
  static ThemeData get aiSpark => _buildTheme(
        brightness: Brightness.dark,
        bg: const Color(0xFF13111C),
        primary: const Color(0xFF8B5CF6),
        surface: const Color(0xFF1F1B2E),
        text: const Color(0xFFEDE9FE),
        secondaryAccent: const Color(0xFF38BDF8),
      );

  // DRY Refactoring Principle: Reusable baseline internal constructor builder
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color primary,
    required Color surface,
    required Color text,
    Color? secondaryAccent,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      // Tip: Uncomment the line below if you add the Google Fonts package (e.g., Inter or Poppins)
      // fontFamily: 'Inter', 
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        secondary: secondaryAccent ?? primary,
        surface: surface,
        onSurface: text,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      // Upgraded Card Theme for a modern, flat UI look
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: text.withOpacity(0.05), width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent, // Prevents Material 3 color shifting on scroll
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: TextStyle(
          color: text, 
          fontSize: 20, 
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      // Upgraded FAB for consistent rounded aesthetic
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}