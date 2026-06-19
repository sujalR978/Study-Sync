import 'package:flutter/material.dart';

class AppColors {
  // Lucid Flow Core Palette (Shared brand colors)
  static const Color primary = Color(0xFF6366F1); // Indigo Accent
  static const Color secondary = Color(0xFF0EA5E9); // Light Blue Accent
  static const Color tertiary = Color(0xFFB95F00); // Deep Amber Accent

  // ==========================================
  // LIGHT MODE PALETTE
  // ==========================================

    
  static const Color background = Color( 
    0xFFF0F4F8,
  ); // Light blue/grey app background
  static const Color surface = Colors.white; // Card background
  static const Color inputFill = Color(0xFFF1F5F9); // Input field background
  static const Color neutral = Color(0xFF1F2937); // Dark header/title text
  static const Color textBody = Color(0xFF6B7280); // Muted grey body text

  // ==========================================
  // DARK MODE PALETTE (Newly Added)
  // ==========================================
  static const Color darkBackground = Color(0xFF0F172A); // Premium Deep Slate
  static const Color darkSurface = Color(
    0xFF1E293B,
  ); // Slightly lighter card/elevated layer
  static const Color darkInputFill = Color(0xFF334155); // Field backgrounds
  static const Color darkNeutral = Color(
    0xFFF8FAFC,
  ); // Crisp white/grey for bold headers
  static const Color darkTextBody = Color(
    0xFF94A3B8,
  ); // Soft readable grey for structural text
}
