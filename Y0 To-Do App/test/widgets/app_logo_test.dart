// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:y0_todo_app/widgets/app_logo.dart';
import 'package:y0_todo_app/theme/y0_design_system.dart';
import 'package:y0_todo_app/l10n/app_localizations.dart';

void main() {
  group('AppLogo and AppBrandHeader Tests (v1.0.12)', () {
    testWidgets('AppLogo renders with specified dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLogo(size: 40.0),
          ),
        ),
      );

      final appLogoFinder = find.byType(AppLogo);
      expect(appLogoFinder, findsOneWidget);
    });

    testWidgets('AppBrandHeader renders logo and localized app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('ar')],
          locale: Locale('ar'),
          home: Scaffold(
            body: AppBrandHeader(
              logoSize: 32.0,
              showTitle: true,
              showVersionBadge: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AppBrandHeader), findsOneWidget);
      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('Y0 To-Do'), findsOneWidget);
      expect(find.text('v1.0.12'), findsOneWidget);
    });

    test('Theme elevatedButtonTheme in Light Mode has high contrast non-transparent background', () {
      final lightTheme = Y0DesignSystem.lightTheme;
      final elevatedStyle = lightTheme.elevatedButtonTheme.style;

      final bgColor = elevatedStyle?.backgroundColor?.resolve({});
      final fgColor = elevatedStyle?.foregroundColor?.resolve({});

      // Must NOT be transparent in Light Mode
      expect(bgColor, isNot(equals(Colors.transparent)));
      expect(bgColor, equals(Y0DesignSystem.primary));
      expect(fgColor, equals(Y0DesignSystem.onPrimary));
    });

    test('Theme elevatedButtonTheme in Dark Mode has high contrast botanical background', () {
      final darkTheme = Y0DesignSystem.darkTheme;
      final elevatedStyle = darkTheme.elevatedButtonTheme.style;

      final bgColor = elevatedStyle?.backgroundColor?.resolve({});
      final fgColor = elevatedStyle?.foregroundColor?.resolve({});

      // Must NOT be transparent in Dark Mode
      expect(bgColor, isNot(equals(Colors.transparent)));
      expect(bgColor, equals(Y0DesignSystem.primaryContainer));
      expect(fgColor, equals(const Color(0xFF00390E)));
    });
  });
}
