// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/task_category.dart';
import '../models/task_filter.dart';
import '../providers/task_provider.dart';

class TaskFilterChips extends ConsumerWidget {
  final TaskFilter filter;
  
  const TaskFilterChips({super.key, required this.filter});

  void _handleFilterSelection(String value, TaskFilter filter, StateController<TaskFilter> filterNotifier) {
    switch (value) {
      case 'status_all':
        filterNotifier.state = filter.copyWith(clearStatus: true);
        break;
      case 'status_pending':
        filterNotifier.state = filter.toggleStatus(TaskStatus.pending);
        break;
      case 'status_completed':
        filterNotifier.state = filter.toggleStatus(TaskStatus.completed);
        break;
      case 'priority_all':
        filterNotifier.state = filter.copyWith(priorities: const {});
        break;
      case 'priority_high':
        filterNotifier.state = filter.togglePriority(2);
        break;
      case 'priority_medium':
        filterNotifier.state = filter.togglePriority(1);
        break;
      case 'priority_low':
        filterNotifier.state = filter.togglePriority(0);
        break;
      case 'date_all':
        filterNotifier.state = filter.copyWith(dateFilters: const {});
        break;
      case 'date_today':
        filterNotifier.state = filter.toggleDateFilter(DateFilter.today);
        break;
      case 'date_week':
        filterNotifier.state = filter.toggleDateFilter(DateFilter.thisWeek);
        break;
      case 'category_all':
        filterNotifier.state = filter.copyWith(categories: const {});
        break;
      case 'reset':
        filterNotifier.state = filter.reset();
        break;
      default:
        if (value.startsWith('category_')) {
          final categoryName = value.substring(9);
          final category = TaskCategory.values.firstWhere(
            (cat) => cat.name == categoryName,
            orElse: () => TaskCategory.personal,
          );
          filterNotifier.state = filter.toggleCategory(category);
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
                const SizedBox(width: 6),
                Text(
                  'تصفية المهام',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (filter.isActive) ...[
                  const SizedBox(width: 6),
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
                            const SizedBox(width: 6),
                            const Text('الحالة: الكل'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status_pending',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 16),
                            const SizedBox(width: 6),
                            Text('الحالة: معلقة ${filter.status == TaskStatus.pending ? '✓' : ''}'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status_completed',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16),
                            const SizedBox(width: 6),
                            Text('الحالة: مكتملة ${filter.status == TaskStatus.completed ? '✓' : ''}'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'priority_all',
                        child: Row(
                          children: [
                            Icon(Icons.flag, size: 16),
                            const SizedBox(width: 6),
                            const Text('الأولوية: إعادة ضبط'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'priority_high',
                        child: Row(
                          children: [
                            Icon(Icons.priority_high, size: 16, color: Colors.red),
                            const SizedBox(width: 6),
                            Text('الأولوية: عالية ${filter.priorities.contains(2) ? '✓' : ''}'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'priority_medium',
                        child: Row(
                          children: [
                            Icon(Icons.remove, size: 16, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text('الأولوية: متوسطة ${filter.priorities.contains(1) ? '✓' : ''}'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'priority_low',
                        child: Row(
                          children: [
                            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                            Text('الأولوية: منخفضة ${filter.priorities.contains(0) ? '✓' : ''}'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'date_all',
                        child: Row(
                          children: [
                            Icon(Icons.date_range, size: 16),
                            const SizedBox(width: 6),
                            const Text('التاريخ: إعادة ضبط'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'date_today',
                        child: Row(
                          children: [
                            Icon(Icons.today, size: 16),
                            const SizedBox(width: 6),
                            Text('التاريخ: اليوم ${filter.dateFilters.contains(DateFilter.today) ? '✓' : ''}'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'date_week',
                        child: Row(
                          children: [
                            Icon(Icons.view_week, size: 16),
                            const SizedBox(width: 6),
                            Text('التاريخ: هذا الأسبوع ${filter.dateFilters.contains(DateFilter.thisWeek) ? '✓' : ''}'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'category_all',
                        child: Row(
                          children: [
                            Icon(Icons.category, size: 16),
                            const SizedBox(width: 6),
                            const Text('التصنيف: إعادة ضبط'),
                          ],
                        ),
                      ),
                      ...TaskCategory.values.map((category) => PopupMenuItem(
                        value: 'category_${category.name}',
                        child: Row(
                          children: [
                            Icon(category.icon, size: 16, color: category.color),
                            const SizedBox(width: 6),
                            Text('التصنيف: ${category.displayName} ${filter.categories.contains(category) ? '✓' : ''}'),
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
                              const SizedBox(width: 6),
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

          if (!isSmallScreen) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 32,
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildCompactStatusFilters(filter, filterNotifier, context),
                    _buildCompactPriorityFilters(filter, filterNotifier, context),
                    _buildCompactCategoryFilters(filter, filterNotifier, context),
                    _buildCompactDateFilters(filter, filterNotifier, context),
                  ],
                ),
              ),
            ),

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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.9)
                            : Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ...filter.priorities.map((priority) => Chip(
                        label: Text('الأولوية: ${_getPriorityLabel(priority)}'),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          filterNotifier.state = filter.togglePriority(priority);
                        },
                        backgroundColor: _getPriorityColor(priority).withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: _getPriorityColor(priority),
                          fontSize: 12,
                        ),
                      )),
                  ...filter.categories.map((category) => Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(category.icon, size: 12),
                            const SizedBox(width: 4),
                            Text(category.displayName),
                          ],
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          filterNotifier.state = filter.toggleCategory(category);
                        },
                        backgroundColor: category.color.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: category.color,
                          fontSize: 12,
                        ),
                      )),
                  ...filter.dateFilters.map((dateFilter) => Chip(
                        label: Text('التاريخ: ${dateFilter.displayName}'),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          filterNotifier.state = filter.toggleDateFilter(dateFilter);
                        },
                        backgroundColor: const Color(0xFF66BB6A).withValues(alpha: 0.3),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      )),
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
          selected: filter.categories.isEmpty,
          onSelected: (selected) {
            if (selected) {
              filterNotifier.state = filter.copyWith(categories: const {});
            }
          },
          backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          selectedColor: const Color(0xFF66BB6A).withValues(alpha: 0.3),
          checkmarkColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(
            color: filter.categories.isEmpty
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 10,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        ),
        ...TaskCategory.values.map((category) {
          final isSelected = filter.categories.contains(category);
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
              filterNotifier.state = filter.toggleCategory(category);
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
              filterNotifier.state = filter.toggleStatus(status);
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: const Color(0xFF66BB6A).withValues(alpha: 0.3),
            checkmarkColor: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.3),
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
        FilterChip(
          label: const Text('الكل', style: TextStyle(fontSize: 10)),
          selected: filter.priorities.isEmpty,
          onSelected: (selected) {
            if (selected) {
              filterNotifier.state = filter.copyWith(priorities: const {});
            }
          },
          backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          selectedColor: const Color(0xFF66BB6A).withValues(alpha: 0.3),
          checkmarkColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(
            color: filter.priorities.isEmpty
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 10,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        ),
        ...priorities.map((priorityInfo) {
          final priorityVal = priorityInfo['value'] as int;
          final isSelected = filter.priorities.contains(priorityVal);
          final color = priorityInfo['color'] as Color;
          return FilterChip(
            label: Text(priorityInfo['label'] as String, style: const TextStyle(fontSize: 10)),
            selected: isSelected,
            onSelected: (selected) {
              filterNotifier.state = filter.togglePriority(priorityVal);
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
        FilterChip(
          label: const Text('الكل', style: TextStyle(fontSize: 10)),
          selected: filter.dateFilters.isEmpty,
          onSelected: (selected) {
            if (selected) {
              filterNotifier.state = filter.copyWith(dateFilters: const {});
            }
          },
          backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          selectedColor: const Color(0xFF66BB6A).withValues(alpha: 0.3),
          checkmarkColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(
            color: filter.dateFilters.isEmpty
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 10,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        ),
        ...DateFilter.values.where((d) => d != DateFilter.all).map((dateFilter) {
          final isSelected = filter.dateFilters.contains(dateFilter);
          return FilterChip(
            label: Text(dateFilter.displayName, style: const TextStyle(fontSize: 10)),
            selected: isSelected,
            onSelected: (selected) {
              filterNotifier.state = filter.toggleDateFilter(dateFilter);
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: const Color(0xFF66BB6A).withValues(alpha: 0.3),
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
