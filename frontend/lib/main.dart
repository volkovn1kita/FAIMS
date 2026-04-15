import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:faims/l10n/app_localizations.dart';
import 'package:faims/presentation/providers/locale_provider.dart';
import 'package:faims/presentation/providers/theme_provider.dart';
import 'package:faims/data/services/notification_service.dart';
import 'package:faims/core/firebase_config.dart';
import 'package:faims/core/router.dart';
import 'package:faims/core/app_theme.dart';
import 'package:faims/utils/session_service.dart';
import 'package:faims/utils/token_storage_service.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<void>? _sessionSub;
  final _tokenStorage = TokenStorageService();

  @override
  void initState() {
    super.initState();
    // Listen for forced logouts triggered by API 401 responses.
    // Clear all stored credentials and redirect to the login screen.
    _sessionSub = SessionService.instance.onForceLogout.listen((_) async {
      await _tokenStorage.deleteToken();
      // appRouter is a GoRouter — navigate anywhere via the router directly.
      appRouter.go('/login');
    });
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FAIMS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
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
