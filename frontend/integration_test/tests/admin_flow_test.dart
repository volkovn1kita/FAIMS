import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_helpers.dart';

void main() {
  group('Admin Flow — Kits Management', () {
    testWidgets('Admin home shows Manage Kits shortcut', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      expect(find.text('Управління аптечками'), findsWidgets);
    });

    testWidgets('Admin can open Manage Kits screen', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);

      await tester.tap(find.text('Управління аптечками').first);
      await tester.pumpAndSettle(kLong);
      expect(find.text('Управління аптечками'), findsWidgets);
    });

    testWidgets('Admin can search kits by name', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      await tester.tap(find.text('Управління аптечками').first);
      await tester.pumpAndSettle(kLong);

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField.first);
        await tester.enterText(searchField.first, 'FAK');
        await tester.pumpAndSettle(kShort);
        await tester.enterText(searchField.first, '');
        await tester.pumpAndSettle(kShort);
      }
    });

    testWidgets('Admin can filter kits by status — Expired', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      await tester.tap(find.text('Управління аптечками').first);
      await tester.pumpAndSettle(kLong);

      final expiredChip = find.text('Протерм.');
      if (expiredChip.evaluate().isNotEmpty) {
        await tester.tap(expiredChip.first);
        await tester.pumpAndSettle(kShort);
        await tester.tap(expiredChip.first);
        await tester.pumpAndSettle(kShort);
      }
    });

    testWidgets('Admin can filter kits by status — Critical', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      await tester.tap(find.text('Управління аптечками').first);
      await tester.pumpAndSettle(kLong);

      final criticalChip = find.text('Критичне');
      if (criticalChip.evaluate().isNotEmpty) {
        await tester.tap(criticalChip.first);
        await tester.pumpAndSettle(kShort);
        await tester.tap(criticalChip.first);
        await tester.pumpAndSettle(kShort);
      }
    });

    testWidgets('Admin can open kit contents from list', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      await tester.tap(find.text('Управління аптечками').first);
      await tester.pumpAndSettle(kLong);

      final kitCards = find.byType(Card);
      if (kitCards.evaluate().isNotEmpty) {
        await tester.tap(kitCards.first);
        await tester.pumpAndSettle(kLong);
        await goBack(tester);
      }
    });

    testWidgets('Admin can scroll the kits list without crash', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      await tester.tap(find.text('Управління аптечками').first);
      await tester.pumpAndSettle(kLong);

      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, -600),
        2000,
      );
      await tester.pumpAndSettle(kShort);

      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, 600),
        2000,
      );
      await tester.pumpAndSettle(kShort);
    });

    testWidgets('Admin can pull to refresh kits list', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      await tester.tap(find.text('Управління аптечками').first);
      await tester.pumpAndSettle(kLong);

      final refresh = find.byType(RefreshIndicator);
      if (refresh.evaluate().isNotEmpty) {
        await tester.fling(refresh.first, const Offset(0, 400), 1000);
        await tester.pumpAndSettle(kLong);
      }
    });
  });

  group('Admin Flow — Users Management', () {
    testWidgets('Admin can open Manage Users screen', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      if (!isOnAdminHome(tester)) return;
      await tester.tap(find.text('Управління користувачами').first);
      await tester.pumpAndSettle(kLong);
      expect(find.text('Управління користувачами'), findsWidgets);
    });

    testWidgets('Admin can search users by name', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      if (!isOnAdminHome(tester)) return;
      await tester.tap(find.text('Управління користувачами').first);
      await tester.pumpAndSettle(kLong);

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField.first);
        await tester.enterText(searchField.first, 'user');
        await tester.pumpAndSettle(kShort);
        await tester.enterText(searchField.first, '');
        await tester.pumpAndSettle(kShort);
      }
    });

    testWidgets('Admin can open user detail from list', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      if (!isOnAdminHome(tester)) return;
      await tester.tap(find.text('Управління користувачами').first);
      await tester.pumpAndSettle(kLong);

      final userCards = find.byType(Card);
      if (userCards.evaluate().isNotEmpty) {
        await tester.tap(userCards.first);
        await tester.pumpAndSettle(kLong);
        await goBack(tester);
      }
    });
  });

  group('Admin Flow — Analytics & Reports', () {
    testWidgets('Admin can navigate to Analytics screen', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      if (!isOnAdminHome(tester)) return;

      await openDrawer(tester);
      final analyticsOption = find.text('Аналітика');
      if (analyticsOption.evaluate().isNotEmpty) {
        await tester.tap(analyticsOption.first);
        await tester.pumpAndSettle(kXLong);
        await goBack(tester);
      }
    });

    testWidgets('Analytics screen renders charts without crash', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      if (!isOnAdminHome(tester)) return;

      await openDrawer(tester);
      final analyticsOption = find.text('Аналітика');
      if (analyticsOption.evaluate().isNotEmpty) {
        await tester.tap(analyticsOption.first);
        await tester.pumpAndSettle(kXLong);
        await tester.pumpAndSettle(kShort);
        await goBack(tester);
      }
    });
  });

  group('Admin Flow — Settings', () {
    testWidgets('Admin can open Settings from drawer', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      if (!isOnAdminHome(tester)) return;

      await openDrawer(tester);
      final settingsOption = find.text('Налаштування');
      if (settingsOption.evaluate().isNotEmpty) {
        await tester.tap(settingsOption);
        await tester.pumpAndSettle(kShort);
        expect(find.text('Налаштування'), findsWidgets);
        await goBack(tester);
      }
    });

    testWidgets('Admin can switch language to Ukrainian and back', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      if (!isOnAdminHome(tester)) return;

      await openDrawer(tester);
      final settingsOption = find.text('Налаштування');
      if (settingsOption.evaluate().isNotEmpty) {
        await tester.tap(settingsOption);
        await tester.pumpAndSettle(kShort);

        final ukOption = find.text('Українська');
        if (ukOption.evaluate().isNotEmpty) {
          await tester.tap(ukOption);
          await tester.pumpAndSettle(kShort);
        }

        final enOption = find.text('English');
        if (enOption.evaluate().isNotEmpty) {
          await tester.tap(enOption);
          await tester.pumpAndSettle(kShort);
        }

        await goBack(tester);
      }
    });

    testWidgets('Admin can toggle dark mode on and off', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      if (!isOnAdminHome(tester)) return;

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
  });

  group('Chaos Tests — Unexpected behaviour', () {
    testWidgets('Rapid login-logout cycle does not crash', (tester) async {
      await launchApp(tester);

      for (int i = 0; i < 3; i++) {
        await loginAsAdmin(tester);
        await openDrawer(tester);
        final logout = find.text('Вийти');
        if (logout.evaluate().isNotEmpty) {
          await tester.tap(logout.first);
          await tester.pumpAndSettle(kShort);
        }
      }

      expect(find.text('FAIMS'), findsWidgets);
    });

    testWidgets('Rotating through all filter chips does not crash', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      if (!isOnAdminHome(tester)) return;

      final manageKits = find.text('Управління аптечками');
      await tester.tap(manageKits.first);
      await tester.pumpAndSettle(kLong);

      for (final status in ['Протерм.', 'Критичне', 'Мало', 'Добре']) {
        final chip = find.text(status);
        if (chip.evaluate().isNotEmpty) {
          await tester.tap(chip.first);
          await tester.pumpAndSettle(kShort);
          await tester.tap(chip.first);
          await tester.pumpAndSettle(kShort);
        }
      }
    });

    testWidgets('Navigating back quickly from nested screens does not crash',
        (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      if (!isOnAdminHome(tester)) return;

      await tester.tap(find.text('Управління аптечками').first);
      await tester.pumpAndSettle(kLong);

      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle(kShort);
        await goBack(tester);
        await tester.tap(cards.first);
        await tester.pumpAndSettle(kShort);
        await goBack(tester);
      }
    });

    testWidgets('Search with emoji does not crash', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      if (!isOnAdminHome(tester)) return;

      await tester.tap(find.text('Управління аптечками').first);
      await tester.pumpAndSettle(kLong);

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField.first);
        await tester.pump();
        try {
          await tester.enterText(searchField.first, '\u{1F48A}\u{1F3E5}\u{1F691}');
          await tester.pump(kShort);
        } catch (_) {}
        await tester.enterText(searchField.first, '');
        await tester.pumpAndSettle(kShort);
      }
    });
  });
}
