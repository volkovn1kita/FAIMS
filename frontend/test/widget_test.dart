import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/app_theme.dart';

void main() {
  testWidgets('AppTheme applies correct primary color to MaterialApp', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.themeData,
        home: const Scaffold(body: Text('FAIMS')),
      ),
    );

    expect(find.text('FAIMS'), findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.colorScheme.primary, AppTheme.primary);
  });

  testWidgets('AppTheme scaffold background is white', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.themeData,
        home: const Scaffold(body: SizedBox()),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull);

    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(theme.scaffoldBackgroundColor, Colors.white);
  });
}
