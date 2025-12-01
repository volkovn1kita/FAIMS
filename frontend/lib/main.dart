import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/home_screen.dart';
import 'package:frontend/presentation/screens/user_home_screen.dart';
import 'presentation/screens/login_screen.dart';
//import 'package:google_fonts/google_fonts.dart';

// === 1. ІМПОРТИ ДЛЯ ЛОКАЛІЗАЦІЇ ===
import 'package:frontend/presentation/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// ===================================


void main() {
  // === 2. ОБГОРТАЄМО ДОДАТОК У PROVIDER ===
  // Це робить LocaleProvider доступним у будь-якому віджеті
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
  // ======================================
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // === 3. ОТРИМУЄМО ПРОВАЙДЕР ===
    // Тепер MyApp "слухає" зміни мови
    final localeProvider = Provider.of<LocaleProvider>(context);
    // =============================

    return MaterialApp(
      title: 'First Aid Kit Management', // Цей тайтл не локалізується (видно тільки в ОС)
      // === 4. ПАРАМЕТРИ ЛОКАЛІЗАЦІЇ ===
      locale: localeProvider.locale, // Встановлюємо поточну мову
      localizationsDelegates: const [
        AppLocalizations.delegate, // Наш згенерований словник
        GlobalMaterialLocalizations.delegate, // Для кнопок "OK", "Cancel" у діалогах
        GlobalWidgetsLocalizations.delegate, // Для напрямку тексту
        GlobalCupertinoLocalizations.delegate, // Для iOS віджетів
      ],
      supportedLocales: const [
        Locale('en', ''), // Англійська (за замовчуванням)
        Locale('uk', ''), // Українська
      ],
      // ===================================

      // theme: ThemeData(
      //   primarySwatch: Colors.blue, 
      //   textTheme: GoogleFonts.notoSansTextTheme(
      //     Theme.of(context).textTheme,
      //   ),
        
      //   elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //         textStyle: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold),
      //     ),
      //   ),
      // ),
      initialRoute: '/login',
      routes: {
        // Твої роути залишаються без змін
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(
              userName: 'Demo User',
              userRole: 'Admin',
            ),
        '/userHome': (context) => const UserHomeScreen(
              userName: 'Demo User',
            ),
      },
    );
  }
}