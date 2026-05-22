import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Sophisticated/Modern palette for all ages
  static const Color primary = Color(0xFF4F46E5); // Deep Indigo
  static const Color accent = Color(0xFF38BDF8); // Light Blue
  static const Color accent2 = Color(0xFF10B981); // Emerald Green
  static const Color accent3 = Color(0xFFF43F5E); // Rose Red
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

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
        titleTextStyle: TextStyle(color: textLight, fontSize: 22, fontWeight: FontWeight.w600),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

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
        titleTextStyle: TextStyle(color: textDark, fontSize: 22, fontWeight: FontWeight.w600),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(color: color, fontWeight: FontWeight.w800, fontSize: 48),
      displayMedium: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700, fontSize: 40),
      displaySmall: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700, fontSize: 36),
      headlineLarge: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700, fontSize: 32),
      headlineMedium: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 28),
      headlineSmall: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 24),
      titleLarge: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 22),
      titleMedium: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 20),
      titleSmall: GoogleFonts.inter(color: color, fontWeight: FontWeight.w500, fontSize: 18),
      bodyLarge: GoogleFonts.inter(color: color, fontSize: 16),
      bodyMedium: GoogleFonts.inter(color: color, fontSize: 14),
      bodySmall: GoogleFonts.inter(color: color, fontSize: 12),
      labelLarge: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 16),
      labelMedium: GoogleFonts.inter(color: color, fontWeight: FontWeight.w500, fontSize: 14),
      labelSmall: GoogleFonts.inter(color: color, fontWeight: FontWeight.w500, fontSize: 12),
    );
  }
}
