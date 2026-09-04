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

class NotificationTimeSelector extends ConsumerWidget {
  const NotificationTimeSelector({super.key});

  String _getTimeLabel(BuildContext context, int minutes) {
    if (minutes < 60) {
      return context.l10n.minutesFormat(minutes);
    } else if (minutes == 60) {
      return context.l10n.oneHour;
    } else if (minutes < 1440) {
      return context.l10n.hoursFormat(minutes ~/ 60);
    } else {
      return context.l10n.oneDay;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTime =
        ref.watch(settingsProvider.select((s) => s.notificationMinutesBefore));

    const minuteOptions = [15, 30, 60, 120, 1440];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.reminderTimeSelectTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          ...minuteOptions.map(
            (minutes) => RadioListTile<int>(
              title: Text(_getTimeLabel(context, minutes)),
              value: minutes,
              groupValue: currentTime,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateNotificationMinutesBefore(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.reminderTimeUpdated)),
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
