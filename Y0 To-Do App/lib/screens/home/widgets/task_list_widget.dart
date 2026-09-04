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
import '../../../widgets/neo_morphic_card.dart';
import '../../../providers/task_provider.dart';
import 'task_card_widget.dart';

/// قائمة المهام مع دعم السحب والإفلات (Drag-and-Drop Reordering)
class TaskListWidget extends ConsumerWidget {
  const TaskListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  context.l10n.noTasksTitle,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: Y0DesignSystem.spacing2),
                Text(
                  context.l10n.noTasksSubtitle,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isFilterActive = ref.watch(taskFilterProvider.select((f) => f.isActive));

    if (!isFilterActive) {
      return SliverReorderableList(
        itemCount: taskIds.length,
        onReorder: (oldIndex, newIndex) {
          ref.read(tasksProvider.notifier).reorderTasks(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final taskId = taskIds[index];
          return ReorderableDelayedDragStartListener(
            key: ValueKey(taskId),
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: Y0DesignSystem.spacing2),
              child: TaskCardWidget(
                key: ValueKey('card_$taskId'),
                taskId: taskId,
              ),
            ),
          );
        },
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Material(
                elevation: 8 * animation.value,
                borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
                shadowColor: context.colorScheme.primary.withValues(alpha: 0.3),
                child: child,
              );
            },
            child: child,
          );
        },
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
