import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/task_category.dart';
import '../models/task_filter.dart';
import '../providers/task_provider.dart';

class TaskFilterChips extends ConsumerWidget {
  const TaskFilterChips({super.key});

  void _handleFilterSelection(String value, TaskFilter filter, StateController<TaskFilter> filterNotifier) {
    switch (value) {
      case 'status_all':
        filterNotifier.state = filter.copyWith(clearStatus: true);
        break;
      case 'status_pending':
        filterNotifier.state = filter.copyWith(status: TaskStatus.pending);
        break;
      case 'status_completed':
        filterNotifier.state = filter.copyWith(status: TaskStatus.completed);
        break;
      case 'priority_all':
        filterNotifier.state = filter.copyWith(clearPriority: true);
        break;
      case 'priority_high':
        filterNotifier.state = filter.copyWith(priority: 2);
        break;
      case 'priority_medium':
        filterNotifier.state = filter.copyWith(priority: 1);
        break;
      case 'priority_low':
        filterNotifier.state = filter.copyWith(priority: 0);
        break;
      case 'date_all':
        filterNotifier.state = filter.copyWith(clearDateFilter: true);
        break;
      case 'date_today':
        filterNotifier.state = filter.copyWith(dateFilter: DateFilter.today);
        break;
      case 'date_week':
        filterNotifier.state = filter.copyWith(dateFilter: DateFilter.thisWeek);
        break;
      case 'category_all':
        filterNotifier.state = filter.copyWith(clearCategory: true);
        break;
      case 'reset':
        filterNotifier.state = filter.reset();
        break;
      default:
        // Handle category filters (format: 'category_categoryName')
        if (value.startsWith('category_')) {
          final categoryName = value.substring(9); // Remove 'category_' prefix
          final category = TaskCategory.values.firstWhere(
            (cat) => cat.name == categoryName,
            orElse: () => TaskCategory.personal,
          );
          filterNotifier.state = filter.copyWith(category: category);
        }
        break;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 0:
        return 'منخفضة';
      case 1:
        return 'متوسطة';
      case 2:
        return 'عالية';
      default:
        return 'غير محدد';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    final filterNotifier = ref.read(taskFilterProvider.notifier);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

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
                const Spacer(),
                // Hamburger menu for small screens
                if (isSmallScreen)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    tooltip: 'خيارات التصفية',
                    onSelected: (value) {
                      _handleFilterSelection(value, filter, filterNotifier);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'status_all',
                        child: Row(
                          children: [
                            Icon(Icons.filter_list, size: 16),
                            const SizedBox(width: 8),
                            const Text('الحالة: الكل'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status_pending',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 16),
                            const SizedBox(width: 8),
                            const Text('الحالة: معلقة'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status_completed',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16),
                            const SizedBox(width: 8),
                            const Text('الحالة: مكتملة'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'priority_all',
                        child: Row(
                          children: [
                            Icon(Icons.flag, size: 16),
                            const SizedBox(width: 8),
                            const Text('الأولوية: الكل'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'priority_high',
                        child: Row(
                          children: [
                            Icon(Icons.priority_high, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            const Text('الأولوية: عالية'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'priority_medium',
                        child: Row(
                          children: [
                            Icon(Icons.remove, size: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Text('الأولوية: متوسطة'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'priority_low',
                        child: Row(
                          children: [
                            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text('الأولوية: منخفضة'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'date_all',
                        child: Row(
                          children: [
                            Icon(Icons.date_range, size: 16),
                            const SizedBox(width: 8),
                            const Text('التاريخ: الكل'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'date_today',
                        child: Row(
                          children: [
                            Icon(Icons.today, size: 16),
                            const SizedBox(width: 8),
                            const Text('التاريخ: اليوم'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'date_week',
                        child: Row(
                          children: [
                            Icon(Icons.view_week, size: 16),
                            const SizedBox(width: 8),
                            const Text('التاريخ: هذا الأسبوع'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'category_all',
                        child: Row(
                          children: [
                            Icon(Icons.category, size: 16),
                            const SizedBox(width: 8),
                            const Text('التصنيف: الكل'),
                          ],
                        ),
                      ),
                      ...TaskCategory.values.map((category) => PopupMenuItem(
                        value: 'category_${category.name}',
                        child: Row(
                          children: [
                            Icon(category.icon, size: 16, color: category.color),
                            const SizedBox(width: 8),
                            Text('التصنيف: ${category.displayName}'),
                          ],
                        ),
                      )),
                      if (filter.isActive) ...[
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'reset',
                          child: Row(
                            children: [
                              Icon(Icons.refresh, size: 16),
                              const SizedBox(width: 8),
                              const Text('إعادة تعيين الفلاتر'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),

          // Show full filters on larger screens, hide on small screens
          if (!isSmallScreen) ...[
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
          ] else ...[
            // Show current active filters as chips on small screens
            if (filter.isActive)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (filter.status != null)
                    Chip(
                      label: Text('الحالة: ${filter.status!.displayName}'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        filterNotifier.state = filter.copyWith(clearStatus: true);
                      },
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  if (filter.priority != null)
                    Chip(
                      label: Text('الأولوية: ${_getPriorityLabel(filter.priority!)}'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        filterNotifier.state = filter.copyWith(clearPriority: true);
                      },
                      backgroundColor: _getPriorityColor(filter.priority!).withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: _getPriorityColor(filter.priority!),
                        fontSize: 12,
                      ),
                    ),
                  if (filter.category != null)
                    Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(filter.category!.icon, size: 12),
                          const SizedBox(width: 4),
                          Text(filter.category!.displayName),
                        ],
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        filterNotifier.state = filter.copyWith(clearCategory: true);
                      },
                      backgroundColor: filter.category!.color.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: filter.category!.color,
                        fontSize: 12,
                      ),
                    ),
                  if (filter.dateFilter != null)
                    Chip(
                      label: Text('التاريخ: ${filter.dateFilter!.displayName}'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        filterNotifier.state = filter.copyWith(clearDateFilter: true);
                      },
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
          ],
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
