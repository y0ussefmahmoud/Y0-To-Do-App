// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/y0_design_system.dart';
import '../../../widgets/neo_morphic_card.dart';
import '../../../providers/settings_provider.dart';

class GreetingCard extends ConsumerWidget {
  const GreetingCard({super.key});

  String _getGreetingMessage(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return context.l10n.morningGreeting;
    } else if (hour >= 12 && hour < 17) {
      return context.l10n.afternoonGreeting;
    } else {
      return context.l10n.eveningGreeting;
    }
  }

  String _getCurrentDateFormatted(BuildContext context, String language) {
    final now = DateTime.now();
    try {
      final formatter = DateFormat('EEEE، d MMMM', language);
      return formatter.format(now);
    } catch (_) {
      return DateFormat('EEEE, d MMMM').format(now);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final userName = settings.userName;
    final language = settings.language;

    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.homeGreeting(userName),
              style: context.textTheme.displayLarge?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: Y0DesignSystem.spacing2),
            Text(
              _getGreetingMessage(context),
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Y0DesignSystem.spacing3),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Y0DesignSystem.spacing3,
                vertical: Y0DesignSystem.spacing2,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    color: context.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: Y0DesignSystem.spacing2),
                  Text(
                    _getCurrentDateFormatted(context, language),
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
