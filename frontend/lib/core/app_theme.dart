import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF8F58E1);
  static const Color primaryDark = Color(0xFF7B44CD);
  static const Color primaryLight = Color(0xFFA36CF5);
  static const Color primaryContainer = Color(0xFFF5F3FF);
  static const Color primaryBorder = Color(0xFFE8E0FF);
  static const Color primaryLabel = Color(0xFF9E86C8);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get themeData {
    final base = GoogleFonts.notoSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primaryDark,
        surface: Colors.white,
      ),
      textTheme: base,
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
