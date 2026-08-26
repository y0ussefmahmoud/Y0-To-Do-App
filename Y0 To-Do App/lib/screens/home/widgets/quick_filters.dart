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
import '../../../models/task_filter.dart';
import '../../../models/task_category.dart';
import '../../../providers/task_provider.dart';

class QuickFilters extends ConsumerWidget {
  const QuickFilters({super.key});

  void _handleViewAll(BuildContext context, WidgetRef ref) {
    ref.read(taskFilterProvider.notifier).state = const TaskFilter();
  }

  IconData _getDateFilterIcon(DateFilter filter) {
    switch (filter) {
      case DateFilter.today:
        return Icons.today;
      case DateFilter.thisWeek:
        return Icons.date_range;
      case DateFilter.overdue:
        return Icons.warning;
      case DateFilter.all:
        return Icons.calendar_today;
    }
  }

  String _getDateFilterName(BuildContext context, DateFilter filter) {
    switch (filter) {
      case DateFilter.today:
        return context.l10n.filterToday;
      case DateFilter.thisWeek:
        return context.l10n.filterThisWeek;
      case DateFilter.overdue:
        return context.l10n.filterOverdue;
      case DateFilter.all:
        return context.l10n.filterAll;
    }
  }

  String _getPriorityText(BuildContext context, int priority) {
    switch (priority) {
      case 2:
        return context.l10n.priorityHigh;
      case 1:
        return context.l10n.priorityMedium;
      case 0:
      default:
        return context.l10n.priorityLow;
    }
  }

  String _getStatusName(BuildContext context, TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return context.l10n.filterPending;
      case TaskStatus.completed:
        return context.l10n.filterCompleted;
      case TaskStatus.archived:
        return context.l10n.filterArchive;
      case TaskStatus.all:
        return context.l10n.filterAll;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(taskFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.tasksSectionTitle,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _handleViewAll(context, ref),
              child: Text(
                context.l10n.viewAll,
                style: TextStyle(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Y0DesignSystem.spacing2),
        // Filter Buttons with Neo-morphic design - Horizontal Scrollable
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildArchiveFilterButton(context, ref),
              _buildStatusFilterButton(context, TaskStatus.completed, currentFilter.status, ref),
              _buildStatusFilterButton(context, TaskStatus.pending, currentFilter.status, ref),
              _buildDateFilterButton(context, DateFilter.today, currentFilter.dateFilters, ref),
              _buildDateFilterButton(context, DateFilter.thisWeek, currentFilter.dateFilters, ref),
              _buildPriorityFilterButton(context, 2, currentFilter.priorities, ref), // عالي
              _buildPriorityFilterButton(context, 1, currentFilter.priorities, ref), // متوسط
              _buildPriorityFilterButton(context, 0, currentFilter.priorities, ref), // منخفض
              _buildCategoryFilterButton(context, TaskCategory.work, currentFilter.categories, ref),
              _buildCategoryFilterButton(context, TaskCategory.personal, currentFilter.categories, ref),
              _buildCategoryFilterButton(context, TaskCategory.study, currentFilter.categories, ref),
              _buildCategoryFilterButton(context, TaskCategory.health, currentFilter.categories, ref),
              _buildCategoryFilterButton(context, TaskCategory.general, currentFilter.categories, ref),
              _buildCategoryFilterButton(context, TaskCategory.shopping, currentFilter.categories, ref),
              _buildCategoryFilterButton(context, TaskCategory.entertainment, currentFilter.categories, ref),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterButton(BuildContext context, TaskStatus status, TaskStatus? currentStatus, WidgetRef ref) {
    final isActive = status == currentStatus;
    final filteredCount = ref.watch(taskCountsProvider.select((c) =>
        status == TaskStatus.completed ? c.completed : c.pending));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: NeoMorphicCard(
        padding: const EdgeInsets.symmetric(
          horizontal: Y0DesignSystem.spacing2,
          vertical: Y0DesignSystem.spacing2 / 2,
        ),
        borderRadius: BorderRadius.circular(50),
        color: isActive 
            ? context.colorScheme.primary 
            : context.colorScheme.surfaceContainerLow,
        onTap: () {
          ref.read(taskFilterProvider.notifier).update((f) => f.toggleStatus(status));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status == TaskStatus.completed ? Icons.check_circle : Icons.pending,
              size: 14,
              color: isActive 
                  ? context.colorScheme.onPrimary 
                  : context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _getStatusName(context, status),
              style: TextStyle(
                color: isActive 
                    ? context.colorScheme.onPrimary 
                    : context.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive 
                    ? context.colorScheme.onPrimary.withValues(alpha: 0.2)
                    : context.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                filteredCount.toString(),
                style: TextStyle(
                  color: isActive 
                      ? context.colorScheme.onPrimary 
                      : context.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterButton(BuildContext context, DateFilter filter, Set<DateFilter> activeFilters, WidgetRef ref) {
    final isActive = activeFilters.contains(filter);
    final filteredCount = ref.watch(taskCountsProvider.select((c) {
      switch (filter) {
        case DateFilter.today: return c.today;
        case DateFilter.thisWeek: return c.thisWeek;
        case DateFilter.overdue: return c.overdue;
        case DateFilter.all: return c.completed + c.pending;
      }
    }));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: NeoMorphicCard(
        padding: const EdgeInsets.symmetric(
          horizontal: Y0DesignSystem.spacing2,
          vertical: Y0DesignSystem.spacing2 / 2,
        ),
        borderRadius: BorderRadius.circular(50),
        color: isActive 
            ? context.colorScheme.primary 
            : context.colorScheme.surfaceContainerLow,
        onTap: () {
          ref.read(taskFilterProvider.notifier).update((f) => f.toggleDateFilter(filter));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getDateFilterIcon(filter),
              size: 14,
              color: isActive 
                  ? context.colorScheme.onPrimary 
                  : context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _getDateFilterName(context, filter),
              style: context.textTheme.labelSmall?.copyWith(
                color: isActive 
                    ? context.colorScheme.onPrimary 
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (filteredCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive 
                      ? context.colorScheme.onPrimary.withValues(alpha: 0.2)
                      : context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$filteredCount',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isActive 
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onPrimaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityFilterButton(BuildContext context, int priority, Set<int> currentPriorities, WidgetRef ref) {
    final isActive = currentPriorities.contains(priority);
    final filteredCount = ref.watch(taskCountsProvider.select((c) {
      if (priority == 2) return c.priorityHigh;
      if (priority == 1) return c.priorityMedium;
      return c.priorityLow;
    }));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: NeoMorphicCard(
        padding: const EdgeInsets.symmetric(
          horizontal: Y0DesignSystem.spacing2,
          vertical: Y0DesignSystem.spacing2 / 2,
        ),
        borderRadius: BorderRadius.circular(50),
        color: isActive 
            ? context.colorScheme.primary 
            : context.colorScheme.surfaceContainerLow,
        onTap: () {
          ref.read(taskFilterProvider.notifier).update((f) => f.togglePriority(priority));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flag,
              size: 14,
              color: isActive 
                  ? context.colorScheme.onPrimary 
                  : context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _getPriorityText(context, priority),
              style: context.textTheme.labelSmall?.copyWith(
                color: isActive 
                    ? context.colorScheme.onPrimary 
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (filteredCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive 
                      ? context.colorScheme.onPrimary.withValues(alpha: 0.2)
                      : context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$filteredCount',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isActive 
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onPrimaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterButton(BuildContext context, TaskCategory category, Set<TaskCategory> currentCategories, WidgetRef ref) {
    final isActive = currentCategories.contains(category);
    final filteredCount = ref.watch(taskCountsProvider.select((c) =>
        c.categoryCounts[category] ?? 0));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: NeoMorphicCard(
        padding: const EdgeInsets.symmetric(
          horizontal: Y0DesignSystem.spacing2,
          vertical: Y0DesignSystem.spacing2 / 2,
        ),
        borderRadius: BorderRadius.circular(50),
        color: isActive 
            ? context.colorScheme.primary 
            : context.colorScheme.surfaceContainerLow,
        onTap: () {
          ref.read(taskFilterProvider.notifier).update((f) => f.toggleCategory(category));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 14,
              color: isActive 
                  ? context.colorScheme.onPrimary 
                  : context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              category.localizedName(context),
              style: context.textTheme.labelSmall?.copyWith(
                color: isActive 
                    ? context.colorScheme.onPrimary 
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (filteredCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive 
                      ? context.colorScheme.onPrimary.withValues(alpha: 0.2)
                      : context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$filteredCount',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isActive 
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onPrimaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveFilterButton(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(taskFilterProvider);
    final isArchivedActive = currentFilter.status == TaskStatus.archived;
    final archivedCount = ref.watch(archivedTasksProvider.select((list) => list.length));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: NeoMorphicCard(
        padding: const EdgeInsets.symmetric(
          horizontal: Y0DesignSystem.spacing2,
          vertical: Y0DesignSystem.spacing2 / 2,
        ),
        borderRadius: BorderRadius.circular(50),
        color: isArchivedActive 
            ? context.colorScheme.primary 
            : context.colorScheme.surfaceContainerLow,
        onTap: () {
          ref.read(taskFilterProvider.notifier).update((f) => f.toggleStatus(TaskStatus.archived));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.archive,
              size: 14,
              color: isArchivedActive 
                  ? context.colorScheme.onPrimary 
                  : context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              context.l10n.filterArchive,
              style: TextStyle(
                color: isArchivedActive 
                    ? context.colorScheme.onPrimary 
                    : context.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isArchivedActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isArchivedActive 
                    ? context.colorScheme.onPrimary.withValues(alpha: 0.2)
                    : context.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                archivedCount.toString(),
                style: TextStyle(
                  color: isArchivedActive 
                      ? context.colorScheme.onPrimary 
                      : context.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
