import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:y0_todo_app/screens/add_edit_task_screen.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../providers/search_provider.dart';
import '../providers/task_provider.dart';

class SearchResultsWidget extends ConsumerWidget {
  const SearchResultsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);
    
    if (searchState.query.isEmpty) {
      return const SizedBox.shrink();
    }
    
    if (searchState.isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (searchState.searchResults.isEmpty) {
      return _buildEmptyState(context, searchState.query);
    }
    
    return Column(
      children: [
        // Results Header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${searchState.searchResults.length} نتيجة لـ "${searchState.query}"',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'اضغط على مسح البحث للعودة لجميع المهام',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  ref.read(searchProvider.notifier).clearSearch();
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('مسح البحث'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ).animate().slideY(
          duration: const Duration(milliseconds: 300),
          begin: 0,
          curve: Curves.easeOut,
        ).fadeIn(
          duration: const Duration(milliseconds: 300),
        ),
        
        // Results List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchState.searchResults.length,
            itemBuilder: (context, index) {
              final task = searchState.searchResults[index];
              return _buildTaskCard(context, ref, task, index, searchState.query);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String query) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ).animate().scale(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج لـ "$query"',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'جرب كلمات مفتاحية مختلفة أو تحقق من التهجئة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),
          
          // Alternative Search Suggestions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اقتراحات بحث بديلة:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'مهام اليوم',
                    'مهام عالية الأولوية',
                    'مهام العمل',
                    'مهام متأخرة',
                    if (query.contains('غدا')) 'مهام هذا الأسبوع',
                    if (query.contains('مهم')) 'مهام عادية',
                  ].map((suggestion) {
                    return ActionChip(
                      label: Text(suggestion),
                      onPressed: () {
                        // Update search with suggestion
                        // This would need to be handled by the parent widget
                        // or through a callback
                      },
                      backgroundColor: theme.colorScheme.surface,
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task, int index, String query) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) {
            ref.read(tasksProvider.notifier).toggleDone(task.id);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: _highlightMatch(
          task.title,
          query,
          theme.textTheme.titleMedium?.copyWith(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
            color: task.isDone ? Colors.grey : const Color(0xFF1E293B),
          ) ?? const TextStyle(),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.note != null && task.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _highlightMatch(
                task.note!,
                query,
                theme.textTheme.bodyMedium?.copyWith(
                  color: task.isDone ? Colors.grey : const Color(0xFF64748B),
                ) ?? const TextStyle(),
              ),
            ],
            if (task.dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: _getDueDateColor(task.dueDate!),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, HH:mm').format(task.dueDate!),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDueDateColor(task.dueDate!),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: task.category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                task.category.icon,
                size: 14,
                color: task.category.color,
              ),
            ),
            const SizedBox(width: 8),
            // Priority Indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('تعديل'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditTaskScreen(task: task),
                    ),
                  );
                } else if (value == 'delete') {
                  await ref.read(tasksProvider.notifier).delete(task.id);
                }
              },
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
      .fadeIn()
      .slideX();
  }

  Widget _highlightMatch(String text, String query, TextStyle baseStyle) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }
    
    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    
    if (!textLower.contains(queryLower)) {
      return Text(text, style: baseStyle);
    }
    
    final List<TextSpan> spans = [];
    int start = 0;
    
    while (true) {
      final index = textLower.indexOf(queryLower, start);
      if (index == -1) break;
      
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: baseStyle.copyWith(
          backgroundColor: Colors.yellow.withValues(alpha: 0.3),
          fontWeight: FontWeight.bold,
        ),
      ));
      
      start = index + query.length;
    }
    
    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2: return const Color(0xFFDC2626); // High - Red
      case 1: return const Color(0xFFF59E0B); // Medium - Orange
      default: return const Color(0xFF10B981); // Low - Green
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) return const Color(0xFFDC2626); // Overdue - Red
    if (difference == 0) return const Color(0xFFF59E0B); // Today - Orange
    if (difference <= 3) return const Color(0xFF0891B2); // Soon - Blue
    return const Color(0xFF64748B); // Future - Gray
  }
}
