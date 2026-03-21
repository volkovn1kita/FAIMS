import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/providers/locale_provider.dart';
import 'package:frontend/presentation/screens/home_screen.dart';
import 'package:frontend/presentation/screens/user_home_screen.dart';
import 'package:frontend/presentation/screens/login_screen.dart';
import 'package:frontend/data/services/notification_service.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBmiUMf6xBzbnDwhYfTPXQvl2QKccXA_No",
          authDomain: "faims-baaab.firebaseapp.com",
          projectId: "faims-baaab",
          storageBucket: "faims-baaab.firebasestorage.app",
          messagingSenderId: "352090524800",
          appId: "1:352090524800:web:e0074b8fbb1e0d14052a65",
          measurementId: "G-4SMTN95PYJ",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }

  if (!kIsWeb) {
    try {
      await NotificationService().initNotifications();
    } catch (e) {
      debugPrint('FCM Init Error: $e');
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'First Aid Kit Management',
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('uk', ''),
      ],
      initialRoute: '/login',
      routes: {
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