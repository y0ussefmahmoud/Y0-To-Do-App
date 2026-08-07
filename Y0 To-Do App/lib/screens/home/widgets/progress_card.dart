// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/y0_design_system.dart';
import '../../../widgets/daily_progress_orb.dart';
import '../../../providers/task_provider.dart';

class ProgressCard extends ConsumerWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // التحسين: مراقبة الـ taskCountsProvider المهيأ مسبقاً
    final counts = ref.watch(taskCountsProvider);
    final completedTasks = counts.completed;
    final totalTasks = completedTasks + counts.pending;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

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
          // معلومات التقدم
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'إنجازك لليوم: ${(progress * 100).round()}%',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: Y0DesignSystem.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: Y0DesignSystem.spacing2),
                Text(
                  progress >= 0.75
                      ? 'أنت قريب جداً من إنهاء خطتك اليومية!'
                      : progress >= 0.5
                          ? 'أنت تسير بخطى جيدة، استمر!'
                          : 'لنبدأ اليوم بإنجاز مهامك!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Y0DesignSystem.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: Y0DesignSystem.spacing2),
                // إحصائيات المهام
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
                        '$completedTasks من $totalTasks مهمة',
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
                    alignment: Alignment.centerRight,
                    widthFactor: progress,
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
