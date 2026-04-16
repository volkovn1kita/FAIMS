import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF8F58E1);
  static const Color primaryDark = Color(0xFF7B44CD);
  static const Color primaryLight = Color(0xFFA36CF5);
  static const Color primaryContainer = Color(0xFFF5F3FF);
  static const Color primaryBorder = Color(0xFFE8E0FF);
  static const Color primaryLabel = Color(0xFF9E86C8);

  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkCard = Color(0xFF2A2A3C);
  static const Color darkBackground = Color(0xFF16161E);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static TextTheme _applyNumericFeatures(TextTheme base) {
    const features = [FontFeature.tabularFigures(), FontFeature.liningFigures()];
    return base.copyWith(
      displayLarge:  base.displayLarge?.copyWith(fontFeatures: features),
      displayMedium: base.displayMedium?.copyWith(fontFeatures: features),
      displaySmall:  base.displaySmall?.copyWith(fontFeatures: features),
      headlineLarge:  base.headlineLarge?.copyWith(fontFeatures: features),
      headlineMedium: base.headlineMedium?.copyWith(fontFeatures: features),
      headlineSmall:  base.headlineSmall?.copyWith(fontFeatures: features),
      titleLarge:  base.titleLarge?.copyWith(fontFeatures: features),
      titleMedium: base.titleMedium?.copyWith(fontFeatures: features),
      titleSmall:  base.titleSmall?.copyWith(fontFeatures: features),
      bodyLarge:  base.bodyLarge?.copyWith(fontFeatures: features),
      bodyMedium: base.bodyMedium?.copyWith(fontFeatures: features),
      bodySmall:  base.bodySmall?.copyWith(fontFeatures: features),
      labelLarge:  base.labelLarge?.copyWith(fontFeatures: features),
      labelMedium: base.labelMedium?.copyWith(fontFeatures: features),
      labelSmall:  base.labelSmall?.copyWith(fontFeatures: features),
    );
  }

  static ThemeData get lightTheme {
    final base = _applyNumericFeatures(GoogleFonts.plusJakartaSansTextTheme());
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primaryDark,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      textTheme: base,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
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
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey.shade400,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = _applyNumericFeatures(GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme));
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primaryLight,
        secondary: primaryLight,
        surface: darkSurface,
        brightness: Brightness.dark,
      ),
      textTheme: base,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryLight,
        unselectedItemColor: Colors.grey.shade600,
      ),
      dividerColor: Colors.grey.shade800,
    );
  }

  static ThemeData get themeData => lightTheme;
}
