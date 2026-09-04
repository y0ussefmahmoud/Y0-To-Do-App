// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:y0_todo_app/l10n/app_localizations.dart';
import 'package:y0_todo_app/models/task_category.dart';

void main() {
  group('Localization Tests (Arabic & English)', () {
    testWidgets('Arabic AppLocalizations provides full Arabic text', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.appTitle),
                    Text(l10n.navHome),
                    Text(l10n.navStatistics),
                    Text(l10n.navSettings),
                    Text(TaskCategory.work.localizedName(context)),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(l10n.navHome, equals('الرئيسية'));
      expect(l10n.navStatistics, equals('الإحصائيات'));
      expect(l10n.navSettings, equals('الإعدادات'));
      expect(l10n.filterArchive, equals('الأرشيف'));
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('عمل'), findsOneWidget);
    });

    testWidgets('English AppLocalizations provides full English text', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.appTitle),
                    Text(l10n.navHome),
                    Text(l10n.navStatistics),
                    Text(l10n.navSettings),
                    Text(TaskCategory.work.localizedName(context)),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(l10n.navHome, equals('Home'));
      expect(l10n.navStatistics, equals('Statistics'));
      expect(l10n.navSettings, equals('Settings'));
      expect(l10n.filterArchive, equals('Archive'));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });
  });
}
