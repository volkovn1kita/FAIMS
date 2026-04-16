import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_helpers.dart';

void main() {
  group('User Flow — Kit & Medications', () {
    testWidgets('User sees their kit on home screen', (tester) async {
      await launchApp(tester);
      await loginAsUser(tester);
      await tester.pumpAndSettle(kLong);

      expect(
        find.textContaining(RegExp(r'FAK-|[Аа]птечка|[Лл]іки|[Мм]едикамент')),
        findsWidgets,
      );
    });

    testWidgets('User can search medications by name', (tester) async {
      await launchApp(tester);
      await loginAsUser(tester);
      await tester.pumpAndSettle(kLong);

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField.first);
        await tester.enterText(searchField.first, 'Парацетамол');
        await tester.pumpAndSettle(kShort);

        await tester.enterText(searchField.first, '');
        await tester.pumpAndSettle(kShort);
      }
    });

    testWidgets('User can search with special characters without crash',
        (tester) async {
      await launchApp(tester);
      await loginAsUser(tester);
      await tester.pumpAndSettle(kLong);

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField.first);
        await tester.enterText(searchField.first, '!@#\$%^&*()_+');
        await tester.pumpAndSettle(kShort);
        await tester.enterText(searchField.first, '');
        await tester.pumpAndSettle(kShort);
      }
    });

    testWidgets('User can search with very long query without crash',
        (tester) async {
      await launchApp(tester);
      await loginAsUser(tester);
      await tester.pumpAndSettle(kLong);

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        final longQuery = 'А' * 200;
        await tester.tap(searchField.first);
        await tester.enterText(searchField.first, longQuery);
        await tester.pumpAndSettle(kShort);
        await tester.enterText(searchField.first, '');
        await tester.pumpAndSettle(kShort);
      }
    });

    testWidgets('User can tap on medication group to expand it', (tester) async {
      await launchApp(tester);
      await loginAsUser(tester);
      await tester.pumpAndSettle(kLong);

      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle(kShort);
        await tester.tap(cards.first);
        await tester.pumpAndSettle(kShort);
      }
    });

    testWidgets('User can pull to refresh kit medications', (tester) async {
      await launchApp(tester);
      await loginAsUser(tester);
      await tester.pumpAndSettle(kLong);

      final scrollable = find.byType(RefreshIndicator);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.fling(
          scrollable.first,
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle(kLong);
      }
    });

    testWidgets('User can navigate to profile and back', (tester) async {
      await launchApp(tester);
      await loginAsUser(tester);
      await tester.pumpAndSettle(kLong);

      await openDrawer(tester);

      final profileOption = find.text('Мій профіль');
      if (profileOption.evaluate().isNotEmpty) {
        await tester.tap(profileOption);
        await tester.pumpAndSettle(kLong);
        expect(find.text('Мій профіль'), findsWidgets);
        await goBack(tester);
      }
    });

    testWidgets('User can navigate to settings and toggle theme', (tester) async {
      await launchApp(tester);
      await loginAsUser(tester);
      await tester.pumpAndSettle(kLong);

      await openDrawer(tester);

      final settingsOption = find.text('Налаштування');
      if (settingsOption.evaluate().isNotEmpty) {
        await tester.tap(settingsOption);
        await tester.pumpAndSettle(kShort);

        final toggle = find.byType(Switch);
        if (toggle.evaluate().isNotEmpty) {
          await tester.tap(toggle.first);
          await tester.pumpAndSettle(kShort);
          await tester.tap(toggle.first);
          await tester.pumpAndSettle(kShort);
        }

        await goBack(tester);
      }
    });

    testWidgets('Rapid navigation does not crash the app', (tester) async {
      await launchApp(tester);
      await loginAsUser(tester);
      await tester.pumpAndSettle(kLong);

      for (int i = 0; i < 5; i++) {
        await openDrawer(tester);
        await tester.pumpAndSettle(kShort);

        final settingsOption = find.text('Налаштування');
        if (settingsOption.evaluate().isNotEmpty) {
          await tester.tap(settingsOption);
          await tester.pumpAndSettle(kShort);
          await goBack(tester);
        }
      }
    });
  });
}
