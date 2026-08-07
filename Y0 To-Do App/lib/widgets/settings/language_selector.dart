// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/settings_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(settingsProvider.select((s) => s.language));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'اختر اللغة',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('العربية'),
            subtitle: const Text('قريباً'),
            leading: Radio<String>(
              value: 'ar',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguage(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('قريباً: دعم اللغة العربية')),
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text('English'),
            subtitle: const Text('Coming soon'),
            leading: Radio<String>(
              value: 'en',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguage(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon: English support')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
