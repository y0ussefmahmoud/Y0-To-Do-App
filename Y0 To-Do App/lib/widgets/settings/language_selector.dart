// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../providers/settings_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage =
        ref.watch(settingsProvider.select((s) => s.language));

    void selectLanguage(String lang) {
      ref.read(settingsProvider.notifier).updateLanguage(lang);
      Navigator.pop(context);
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.languageSelectTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          RadioListTile<String>(
            title: Text(context.l10n.languageArabic),
            value: 'ar',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) selectLanguage(value);
            },
          ),
          RadioListTile<String>(
            title: Text(context.l10n.languageEnglish),
            value: 'en',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) selectLanguage(value);
            },
          ),
        ],
      ),
    );
  }
}
