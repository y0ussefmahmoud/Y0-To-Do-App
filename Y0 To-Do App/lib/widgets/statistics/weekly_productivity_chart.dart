// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/y0_design_system.dart';
import '../../widgets/neo_morphic_card.dart';
import '../../models/task.dart';

class WeeklyProductivityChart extends StatelessWidget {
  final List<Task> tasks;
  final bool isDark;

  const WeeklyProductivityChart({
    super.key,
    required this.tasks,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final weeklyData = List.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      final dayTasks = tasks.where((task) =>
        task.dueDate != null &&
        DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day)
            .isAtSameMomentAs(DateTime(day.year, day.month, day.day)) &&
        task.isDone
      ).length;
      return (dayTasks * 10).clamp(0, 100).toDouble();
    });

    final locale = Localizations.localeOf(context).languageCode;
    final weekDayLabels = List.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      return DateFormat('E', locale).format(day);
    });

    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeoMorphicCard(
                padding: const EdgeInsets.all(Y0DesignSystem.spacing2),
                borderRadius: BorderRadius.circular(Y0DesignSystem.radiusSmall),
                color: isDark 
                    ? const Color(0xFF126d27).withValues(alpha: 0.1)
                    : context.colorScheme.primaryContainer.withValues(alpha: 0.2),
                child: Icon(
                  Icons.insights,
                  color: isDark 
                      ? const Color(0xFF66bb6a)
                      : context.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: Y0DesignSystem.spacing2),
              Expanded(
                child: Text(
                  context.l10n.weeklyProductivityTitle,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : context.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Y0DesignSystem.spacing3),
          SizedBox(
            height: 192,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? const Color(0xFF2D2D2D)
                                  : context.colorScheme.surfaceContainerLow,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.bottomCenter,
                              heightFactor: (weeklyData[index] / 100).clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: isDark ? [
                                      const Color(0xFF66bb6a),
                                      const Color(0xFF126d27),
                                    ] : [
                                      context.colorScheme.primary.withValues(alpha: 0.8),
                                      context.colorScheme.primaryContainer,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          weekDayLabels[index],
                          style: context.textTheme.labelSmall?.copyWith(
                            color: isDark 
                                ? const Color(0xFFB3B3B3)
                                : context.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
