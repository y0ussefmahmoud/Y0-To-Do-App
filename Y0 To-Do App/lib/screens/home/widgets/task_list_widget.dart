// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/y0_design_system.dart';
import '../../../widgets/neo_morphic_card.dart';
import '../../../providers/task_provider.dart';
import 'task_card_widget.dart';

class TaskListWidget extends ConsumerWidget {
  const TaskListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مراقبة معرفات المهام المفلترة فقط لتفادي التحديثات عند تغير تفاصيل المهام
    final taskIds = ref.watch(filteredTasksProvider.select(
      (list) => list.map((t) => t.id).toList(),
    ));

    if (taskIds.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Y0DesignSystem.spacing4),
          child: NeoMorphicCard(
            padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: context.colorScheme.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: Y0DesignSystem.spacing2),
                Text(
                  'لا توجد مهام حالياً',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: Y0DesignSystem.spacing2),
                Text(
                  'إما أنك أنهيت كل المهام أو لا توجد نتائج مطابقة',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: taskIds.length,
      itemBuilder: (context, index) {
        final taskId = taskIds[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: Y0DesignSystem.spacing2),
          child: TaskCardWidget(
            key: ValueKey(taskId),
            taskId: taskId,
          ),
        );
      },
    );
  }
}
