import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/task_category.dart';
import '../models/task_filter.dart';
import '../providers/task_provider.dart';

class TaskFilterChips extends ConsumerWidget {
  const TaskFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    final filterNotifier = ref.read(taskFilterProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الفلاتر
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(
                  'تصفية المهام',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (filter.isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filter.activeFiltersCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // الفلاتر الأفقية
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 32,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: [
                  // الحالة
                  _buildCompactStatusFilters(filter, filterNotifier, context),
                  
                  // الأولوية
                  _buildCompactPriorityFilters(filter, filterNotifier, context),
                  
                  // التصنيف
                  _buildCompactCategoryFilters(filter, filterNotifier, context),
                  
                  // التاريخ
                  _buildCompactDateFilters(filter, filterNotifier, context),
                ],
              ),
            ),
          ),

          // زر إعادة تعيين الفلاتر
          if (filter.isActive)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                onPressed: () => filterNotifier.state = filter.reset(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('إعادة تعيين الفلاتر'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, duration: 300.ms);
  }

  Widget _buildCompactCategoryFilters(
    TaskFilter filter,
    StateController<TaskFilter> filterNotifier,
    BuildContext context,
  ) {
    return Wrap(
      spacing: 4,
      children: [
        const Text(
          'التصنيف: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        FilterChip(
          label: const Text('الكل', style: TextStyle(fontSize: 10)),
          selected: filter.category == null,
          onSelected: (selected) {
            filterNotifier.state = filter.copyWith(
              clearCategory: !selected,
              category: selected ? null : null,
            );
          },
          backgroundColor: Colors.grey.shade100,
          selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          checkmarkColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(
            color: filter.category == null
                ? Theme.of(context).primaryColor
                : Colors.grey.shade700,
            fontSize: 10,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        ),
        ...TaskCategory.values.map((category) {
          final isSelected = filter.category == category;
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 12,
                  color: isSelected ? category.color : category.color.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 2),
                Text(category.displayName, style: const TextStyle(fontSize: 10)),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              filterNotifier.state = filter.copyWith(
                clearCategory: !selected,
                category: selected ? category : null,
              );
            },
            backgroundColor: category.color.withValues(alpha: 0.1),
            selectedColor: category.color.withValues(alpha: 0.3),
            checkmarkColor: category.color,
            labelStyle: TextStyle(
              color: isSelected ? category.color : category.color.withValues(alpha: 0.8),
              fontSize: 10,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          );
        }),
      ],
    );
  }

  // Compact filter methods for Wrap layout
  Widget _buildCompactStatusFilters(
    TaskFilter filter,
    StateController<TaskFilter> filterNotifier,
    BuildContext context,
  ) {
    return Wrap(
      spacing: 4,
      children: [
        const Text(
          'الحالة: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        ...TaskStatus.values.map((status) {
          final isSelected = filter.status == status;
          return FilterChip(
            label: Text(status.displayName, style: const TextStyle(fontSize: 10)),
            selected: isSelected,
            onSelected: (selected) {
              filterNotifier.state = filter.copyWith(
                clearStatus: !selected,
                status: selected ? status : null,
              );
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            checkmarkColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade700,
              fontSize: 10,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          );
        }),
      ],
    );
  }

  Widget _buildCompactPriorityFilters(
    TaskFilter filter,
    StateController<TaskFilter> filterNotifier,
    BuildContext context,
  ) {
    final priorities = [
      {'value': null, 'label': 'الكل', 'color': Colors.grey},
      {'value': 0, 'label': 'منخفضة', 'color': Colors.green},
      {'value': 1, 'label': 'متوسطة', 'color': Colors.orange},
      {'value': 2, 'label': 'عالية', 'color': Colors.red},
    ];

    return Wrap(
      spacing: 4,
      children: [
        const Text(
          'الأولوية: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        ...priorities.map((priority) {
          final isSelected = filter.priority == priority['value'];
          final color = priority['color'] as Color;
          return FilterChip(
            label: Text(priority['label'] as String, style: const TextStyle(fontSize: 10)),
            selected: isSelected,
            onSelected: (selected) {
              filterNotifier.state = filter.copyWith(
                clearPriority: !selected,
                priority: selected ? priority['value'] as int? : null,
              );
            },
            backgroundColor: color.withValues(alpha: 0.1),
            selectedColor: color.withValues(alpha: 0.3),
            checkmarkColor: color,
            labelStyle: TextStyle(
              color: isSelected ? color : color.withValues(alpha: 0.8),
              fontSize: 10,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          );
        }),
      ],
    );
  }

  Widget _buildCompactDateFilters(
    TaskFilter filter,
    StateController<TaskFilter> filterNotifier,
    BuildContext context,
  ) {
    return Wrap(
      spacing: 4,
      children: [
        const Text(
          'التاريخ: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        ...DateFilter.values.map((dateFilter) {
          final isSelected = filter.dateFilter == dateFilter;
          return FilterChip(
            label: Text(dateFilter.displayName, style: const TextStyle(fontSize: 10)),
            selected: isSelected,
            onSelected: (selected) {
              filterNotifier.state = filter.copyWith(
                clearDateFilter: !selected,
                dateFilter: selected ? dateFilter : null,
              );
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            checkmarkColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade700,
              fontSize: 10,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          );
        }),
      ],
    );
  }
}
