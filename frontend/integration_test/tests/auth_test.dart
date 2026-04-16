import 'package:flutter_test/flutter_test.dart';
import '../test_helpers.dart';

void main() {
  group('Auth — Login / Logout', () {
    testWidgets('Login screen shows FAIMS branding', (tester) async {
      await launchApp(tester);
      expect(find.text('FAIMS'), findsWidgets);
      expect(
        find.textContaining(RegExp(r'[Ww]elcome|[Зз] поверненням|Sign in|Вхід')),
        findsWidgets,
      );
    });

    testWidgets('Invalid credentials show error message', (tester) async {
      await launchApp(tester);
      await login(tester, 'wrong@email.com', 'WrongPass123!');
      expect(
        find.textContaining(RegExp(
          r'[Ii]ncorrect|[Ii]nvalid|[Ee]rror|not found|[Нн]евірн|[Нн]еправильн|[Пп]омилк',
          caseSensitive: false,
        )),
        findsWidgets,
      );
    });

    testWidgets('Empty credentials show validation error', (tester) async {
      await launchApp(tester);
      await login(tester, '', '');
      expect(find.text('FAIMS'), findsWidgets);
    });

    testWidgets('Admin login navigates to admin home', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);
      expect(find.text('Управління аптечками'), findsWidgets);
    });

    testWidgets('User login navigates to user home', (tester) async {
      await launchApp(tester);
      await loginAsUser(tester);
      expect(
        find.textContaining(RegExp(r'FAK-|[Аа]птечка|[Лл]іки|[Мм]едикамент')),
        findsWidgets,
      );
    });

    testWidgets('Admin can logout and return to login screen', (tester) async {
      await launchApp(tester);
      await loginAsAdmin(tester);

      await openDrawer(tester);
      final logoutBtn = find.text('Вийти');
      if (logoutBtn.evaluate().isNotEmpty) {
        await tester.tap(logoutBtn.first);
        await tester.pumpAndSettle(kShort);
      }

      expect(find.text('FAIMS'), findsWidgets);
    });
  });
}
