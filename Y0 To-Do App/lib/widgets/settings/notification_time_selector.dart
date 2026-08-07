// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/settings_provider.dart';

class NotificationTimeSelector extends ConsumerWidget {
  const NotificationTimeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTime = ref.watch(settingsProvider.select((s) => s.notificationMinutesBefore));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'اختر وقت التذكير',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          ...[
            {'minutes': 15, 'text': '15 دقيقة'},
            {'minutes': 30, 'text': '30 دقيقة'},
            {'minutes': 60, 'text': 'ساعة واحدة'},
            {'minutes': 120, 'text': 'ساعتين'},
            {'minutes': 1440, 'text': 'يوم واحد'},
          ].map((option) => ListTile(
            title: Text(option['text'] as String),
            leading: Radio<int>(
              value: option['minutes'] as int,
              groupValue: currentTime,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateNotificationMinutesBefore(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث وقت التذكير')),
                  );
                }
              },
            ),
          )),
        ],
      ),
    );
  }
}
