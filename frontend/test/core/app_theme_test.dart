import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/app_theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppTheme colors', () {
    test('primary color has correct value', () {
      expect(AppTheme.primary, const Color(0xFF8F58E1));
    });

    test('primaryDark is darker than primary', () {
      expect(AppTheme.primaryDark.computeLuminance(),
          lessThan(AppTheme.primary.computeLuminance()));
    });

    test('primaryLight is lighter than primary', () {
      expect(AppTheme.primaryLight.computeLuminance(),
          greaterThan(AppTheme.primary.computeLuminance()));
    });

    test('primaryContainer is very light', () {
      expect(AppTheme.primaryContainer.computeLuminance(), greaterThan(0.8));
    });

    test('primaryGradient has two colors', () {
      expect(AppTheme.primaryGradient.colors.length, 2);
    });

    test('primaryGradient goes from light to dark', () {
      expect(AppTheme.primaryGradient.colors.first, AppTheme.primaryLight);
      expect(AppTheme.primaryGradient.colors.last, AppTheme.primaryDark);
    });
  });

  group('AppTheme.themeData', () {
    testWidgets('uses Material 3', (tester) async {
      expect(AppTheme.themeData.useMaterial3, isTrue);
    });

    testWidgets('colorScheme primary matches AppTheme.primary', (tester) async {
      expect(AppTheme.themeData.colorScheme.primary, AppTheme.primary);
    });

    testWidgets('scaffold background is white', (tester) async {
      expect(AppTheme.themeData.scaffoldBackgroundColor, Colors.white);
    });

    testWidgets('elevated button background is primary', (tester) async {
      final buttonStyle = AppTheme.themeData.elevatedButtonTheme.style;
      final bg = buttonStyle?.backgroundColor?.resolve({});
      expect(bg, AppTheme.primary);
    });
  });
}
