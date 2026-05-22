import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Accent Palette ──────────────────────────────────────────────────
  static const Color primary   = Color(0xFF6366F1); // Indigo
  static const Color accent    = Color(0xFF38BDF8); // Sky Blue
  static const Color accent2   = Color(0xFF10B981); // Emerald
  static const Color accent3   = Color(0xFFF43F5E); // Rose
  static const Color amber     = Color(0xFFF59E0B); // Amber / Streak
  static const Color indigoLight = Color(0xFFA5B4FC); // Indigo tint

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color backgroundDark  = Color(0xFF080B14); // Deep night
  static const Color backgroundLight = Color(0xFFF0F4FF); // Soft indigo-tinted white
  static const Color surfaceDark     = Color(0xFF0D1225); // Card dark
  static const Color surfaceLight    = Color(0xFFFFFFFF); // Card light

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textLight      = Color(0xFFF8FAFC);
  static const Color textDark       = Color(0xFF0F172A);
  static const Color textMutedDark  = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surfaceDark,
      ),
      textTheme: _buildTextTheme(textLight),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          color: textLight, fontSize: 20, fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textMutedLight),
      ),
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surfaceLight,
      ),
      textTheme: _buildTextTheme(textDark),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          color: textDark, fontSize: 20, fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textMutedDark),
      ),
    );
  }

  // ── Shared Text Theme ────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge:  GoogleFonts.outfit(color: color, fontWeight: FontWeight.w800, fontSize: 44),
      displayMedium: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w700, fontSize: 36),
      displaySmall:  GoogleFonts.outfit(color: color, fontWeight: FontWeight.w700, fontSize: 30),
      headlineLarge:  GoogleFonts.outfit(color: color, fontWeight: FontWeight.w700, fontSize: 26),
      headlineMedium: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w600, fontSize: 22),
      headlineSmall:  GoogleFonts.outfit(color: color, fontWeight: FontWeight.w600, fontSize: 18),
      titleLarge:  GoogleFonts.outfit(color: color, fontWeight: FontWeight.w600, fontSize: 20),
      titleMedium: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w600, fontSize: 18),
      titleSmall:  GoogleFonts.outfit(color: color, fontWeight: FontWeight.w500, fontSize: 16),
      bodyLarge:  GoogleFonts.inter(color: color, fontSize: 15, height: 1.5),
      bodyMedium: GoogleFonts.inter(color: color, fontSize: 13, height: 1.5),
      bodySmall:  GoogleFonts.inter(color: color, fontSize: 11, height: 1.5),
      labelLarge:  GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 14),
      labelMedium: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      labelSmall:  GoogleFonts.inter(color: color, fontWeight: FontWeight.w500, fontSize: 10),
    );
  }
}
