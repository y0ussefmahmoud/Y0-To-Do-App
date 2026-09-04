// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/y0_design_system.dart';

class EditorialHeroHeader extends StatelessWidget {
  final int completionRate;
  final bool isDark;

  const EditorialHeroHeader({
    super.key,
    required this.completionRate,
    required this.isDark,
  });

  String _getMotivationalMessage(BuildContext context) {
    if (completionRate == 100) {
      return '🎉 100%';
    } else if (completionRate >= 75) {
      return context.l10n.progressNearEnd;
    } else if (completionRate >= 50) {
      return context.l10n.progressGood;
    } else {
      return context.l10n.progressStart;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'V3.4.0 • ${context.l10n.statisticsSubtitle}',
          style: context.textTheme.labelMedium?.copyWith(
            color: isDark 
                ? const Color(0xFF66bb6a)
                : context.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Y0DesignSystem.spacing2),
        Text(
          context.l10n.statisticsTitle,
          style: context.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark 
                ? Colors.white
                : context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.statisticsOverviewSubtitle,
          style: context.textTheme.labelMedium?.copyWith(
            color: isDark 
                ? const Color(0xFF66bb6a).withValues(alpha: 0.8)
                : context.colorScheme.primary.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: Y0DesignSystem.spacing3),
        Text(
          _getMotivationalMessage(context),
          style: context.textTheme.bodyLarge?.copyWith(
            color: isDark 
                ? const Color(0xFFB3B3B3)
                : context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
