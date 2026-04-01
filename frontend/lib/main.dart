import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/providers/locale_provider.dart';
import 'package:frontend/data/services/notification_service.dart';
import 'package:frontend/core/firebase_config.dart';
import 'package:frontend/core/router.dart';
import 'package:frontend/core/app_theme.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
      await Firebase.initializeApp(options: FirebaseConfig.webOptions);
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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'First Aid Kit Management',
      theme: AppTheme.themeData,
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
      routerConfig: appRouter,
    );
  }
}
