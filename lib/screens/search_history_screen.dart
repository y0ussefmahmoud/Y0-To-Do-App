import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/search_history.dart';
import '../providers/search_provider.dart';
import '../providers/task_provider.dart';

class SearchHistoryScreen extends ConsumerWidget {
  const SearchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('تاريخ البحث'),
        actions: [
          if (searchState.searchHistory.isNotEmpty)
            IconButton(
              onPressed: () async {
                final confirmed = await _showClearAllDialog(context);
                if (confirmed == true) {
                  await ref.read(searchProvider.notifier).clearAllHistory();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم مسح تاريخ البحث')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.clear_all),
              tooltip: 'مسح الكل',
            ),
        ],
      ),
      body: searchState.searchHistory.isEmpty
          ? _buildEmptyState(context, theme)
          : _buildHistoryList(context, ref, searchState.searchHistory, theme),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ).animate().scale(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد تاريخ بحث',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'ابدأ بالبحث عن مهام وسيظهر هنا تاريخ البحث',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, WidgetRef ref, List<SearchHistory> history, ThemeData theme) {
    // Group history by date
    final groupedHistory = _groupHistoryByDate(history);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedHistory.length,
      itemBuilder: (context, index) {
        final group = groupedHistory[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                group['date'],
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ).animate().slideX(
              duration: const Duration(milliseconds: 300),
              begin: -0.2,
            ),
            
            // History Items for this date
            ...group['items'].map<Widget>((item) => _buildHistoryItem(context, ref, item, theme)).toList(),
            
            if (index < groupedHistory.length - 1)
              Divider(
                height: 32,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, WidgetRef ref, SearchHistory historyItem, ThemeData theme) {
    return Dismissible(
      key: Key(historyItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white),
            Text(
              'حذف',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      onDismissed: (direction) async {
        await ref.read(searchProvider.notifier).deleteHistoryItem(historyItem.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف عنصر من تاريخ البحث')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.search,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            historyItem.query,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${historyItem.resultCount} نتيجة',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatRelativeTime(historyItem.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              // Navigate back to home and perform search
              Navigator.of(context).pop();
              final tasks = ref.read(tasksProvider);
              ref.read(searchProvider.notifier).updateQuery(historyItem.query, tasks);
              // Execute the search
              ref.read(searchProvider.notifier).performSearch(historyItem.query, tasks);
            },
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'بحث مرة أخرى',
          ),
        ),
      ).animate().slideX(
        duration: const Duration(milliseconds: 300),
        begin: 0.2,
      ).fadeIn(
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  List<Map<String, dynamic>> _groupHistoryByDate(List<SearchHistory> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));
    
    final groups = <String, List<SearchHistory>>{};
    
    for (final item in history) {
      final itemDate = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      
      String dateLabel;
      if (itemDate.isAtSameMomentAs(today)) {
        dateLabel = 'اليوم';
      } else if (itemDate.isAtSameMomentAs(yesterday)) {
        dateLabel = 'أمس';
      } else if (itemDate.isAfter(weekAgo)) {
        dateLabel = 'هذا الأسبوع';
      } else {
        dateLabel = DateFormat('MMMM yyyy', 'ar').format(item.timestamp);
      }
      
      groups.putIfAbsent(dateLabel, () => []).add(item);
    }
    
    return groups.entries.map((entry) => {
      'date': entry.key,
      'items': entry.value,
    }).toList();
  }

  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('dd MMMM، HH:mm', 'ar').format(timestamp);
    }
  }

  Future<bool?> _showClearAllDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح تاريخ البحث'),
        content: const Text('هل أنت متأكد من أنك تريد مسح كل تاريخ البحث؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }
}
