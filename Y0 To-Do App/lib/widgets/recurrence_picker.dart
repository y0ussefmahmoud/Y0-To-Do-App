// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../models/recurrence_rule.dart';
import '../../theme/y0_design_system.dart';

/// منتقي قاعدة تكرار المهمة (Recurrence Picker Widget)
///
/// يعرض خيارات تكرار المهمة: بدون تكرار، يومي، أسبوعي، شهري، مخصص.
class RecurrencePicker extends StatelessWidget {
  final RecurrenceRule? selectedRule;
  final void Function(RecurrenceRule?) onChanged;

  const RecurrencePicker({
    super.key,
    required this.selectedRule,
    required this.onChanged,
  });

  String _labelFor(BuildContext context, RecurrenceFrequency freq) {
    switch (freq) {
      case RecurrenceFrequency.daily:
        return context.l10n.recurrenceDaily;
      case RecurrenceFrequency.weekly:
        return context.l10n.recurrenceWeekly;
      case RecurrenceFrequency.monthly:
        return context.l10n.recurrenceMonthly;
      case RecurrenceFrequency.custom:
        return context.l10n.recurrenceCustom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.repeat_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.recurrenceTitle,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // بدون تكرار
            _RecurrenceChip(
              label: context.l10n.recurrenceNone,
              icon: Icons.remove_circle_outline,
              isSelected: selectedRule == null,
              onTap: () => onChanged(null),
            ),
            // خيارات التكرار
            ...RecurrenceFrequency.values.map((freq) {
              final isSelected = selectedRule?.frequency == freq;
              return _RecurrenceChip(
                label: _labelFor(context, freq),
                icon: _iconFor(freq),
                isSelected: isSelected,
                onTap: () => onChanged(
                  RecurrenceRule(frequency: freq, interval: 1),
                ),
              );
            }),
          ],
        ),
        // عرض ملخص التكرار المختار
        if (selectedRule != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.loop_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedRule!.label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  IconData _iconFor(RecurrenceFrequency freq) {
    switch (freq) {
      case RecurrenceFrequency.daily:
        return Icons.today_rounded;
      case RecurrenceFrequency.weekly:
        return Icons.view_week_rounded;
      case RecurrenceFrequency.monthly:
        return Icons.calendar_month_rounded;
      case RecurrenceFrequency.custom:
        return Icons.tune_rounded;
    }
  }
}

class _RecurrenceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecurrenceChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Y0DesignSystem.animationMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withValues(alpha: 0.4),
          ),
          boxShadow: isSelected ? Y0DesignSystem.ambientShadow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
