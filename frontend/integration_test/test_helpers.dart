import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:faims/main.dart' as app;
import 'package:faims/core/router.dart';

const String kAdminEmail = 'admin@org1.faims';
const String kAdminPassword = 'Admin123!';
const String kUserEmail = 'user1@org1.faims';
const String kUserPassword = 'User123!';

const Duration kShort = Duration(seconds: 1);
const Duration kLong = Duration(seconds: 3);
const Duration kXLong = Duration(seconds: 5);

Future<void> clearAuthStorage() async {
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'jwt_token');
  await storage.delete(key: 'refresh_token');
  await storage.delete(key: 'user_name');
}

Future<void> launchApp(WidgetTester tester) async {
  await clearAuthStorage();
  app.main();
  await tester.pump();
  appRouter.go('/login');
  // Give _checkAutoLogin() time to read secure storage and set _isLoading=false
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle(kLong);
}

Future<void> login(WidgetTester tester, String email, String password) async {
  final emailFields = find.byType(TextField);
  if (emailFields.evaluate().isEmpty) return;

  final emailField = emailFields.first;
  await tester.ensureVisible(emailField);
  await tester.pumpAndSettle();
  await tester.tap(emailField, warnIfMissed: false);
  await tester.pumpAndSettle();
  await tester.enterText(emailField, email);
  await tester.pumpAndSettle();

  await tester.testTextInput.receiveAction(TextInputAction.next);
  await tester.pumpAndSettle();

  final allFields = find.byType(TextField);
  if (allFields.evaluate().length < 2) return;
  final passwordField = allFields.at(1);

  await tester.ensureVisible(passwordField);
  await tester.pumpAndSettle();
  await tester.tap(passwordField, warnIfMissed: false);
  await tester.pumpAndSettle();
  await tester.enterText(passwordField, password);
  await tester.pumpAndSettle();

  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();

  final buttons = find.byType(ElevatedButton);
  if (buttons.evaluate().isEmpty) return;
  await tester.ensureVisible(buttons.first);
  await tester.pumpAndSettle();
  await tester.tap(buttons.first, warnIfMissed: false);
  await tester.pumpAndSettle(kXLong);
}

Future<void> loginAsAdmin(WidgetTester tester) async {
  await login(tester, kAdminEmail, kAdminPassword);
  // Wait for dashboard API response and grid rebuild (_overviewData != null)
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle(kShort);
}

Future<void> loginAsUser(WidgetTester tester) =>
    login(tester, kUserEmail, kUserPassword);

Future<void> openDrawer(WidgetTester tester) async {
  final menu = find.byIcon(Icons.menu_rounded);
  if (menu.evaluate().isNotEmpty) {
    await tester.tap(menu);
    await tester.pumpAndSettle(kShort);
  } else {
    await tester.dragFrom(const Offset(0, 300), const Offset(200, 300));
    await tester.pumpAndSettle(kShort);
  }
}

Future<void> goBack(WidgetTester tester) async {
  final back = find.byIcon(Icons.arrow_back_ios_new);
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back.first);
    await tester.pumpAndSettle(kShort);
  }
}

bool isOnAdminHome(WidgetTester tester) =>
    find.text('Управління аптечками').evaluate().isNotEmpty;

bool isOnUserHome(WidgetTester tester) =>
    find.textContaining(RegExp(r'FAK-|Аптечка')).evaluate().isNotEmpty;
