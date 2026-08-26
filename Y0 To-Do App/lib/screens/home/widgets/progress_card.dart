// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/y0_design_system.dart';
import '../../../widgets/daily_progress_orb.dart';
import '../../../providers/task_provider.dart';

class ProgressCard extends ConsumerWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(taskCountsProvider);
    final completedTasks = counts.todayCompleted;
    final totalTasks = counts.todayTotal;
    final progress = counts.todayProgress;
    final progressPercent = counts.todayProgressPercent;

    return Container(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      decoration: BoxDecoration(
        gradient: Y0DesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
        boxShadow: Y0DesignSystem.floatingShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // معلومات التقدم لمهام اليوم
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.l10n.dailyProgress(progressPercent),
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: Y0DesignSystem.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: Y0DesignSystem.spacing2),
                Text(
                  totalTasks == 0
                      ? context.l10n.progressStart
                      : progress >= 0.75
                          ? context.l10n.progressNearEnd
                          : progress >= 0.5
                              ? context.l10n.progressGood
                              : context.l10n.progressStart,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Y0DesignSystem.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: Y0DesignSystem.spacing2),
                // إحصائيات مهام اليوم
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Y0DesignSystem.spacing2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Y0DesignSystem.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        context.l10n.completedOutOfTotal(completedTasks, totalTasks),
                        style: context.textTheme.labelMedium?.copyWith(
                          color: Y0DesignSystem.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Y0DesignSystem.spacing3),
                // شريط التقدم الخطي
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Y0DesignSystem.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Y0DesignSystem.onPrimary,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Y0DesignSystem.onPrimary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // المؤشر الدائري
          Expanded(
            flex: 1,
            child: DailyProgressOrb(
              progress: progress,
              size: 80,
              progressColor: Y0DesignSystem.onPrimary,
              backgroundColor: Y0DesignSystem.onPrimary.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
