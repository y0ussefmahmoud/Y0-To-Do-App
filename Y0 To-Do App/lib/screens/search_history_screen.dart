// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../l10n/l10n_extension.dart';
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
        title: Text(context.l10n.searchHistoryTitle),
        actions: [
          if (searchState.searchHistory.isNotEmpty)
            IconButton(
              onPressed: () async {
                final confirmed = await _showClearAllDialog(context);
                if (confirmed == true) {
                  await ref.read(searchProvider.notifier).clearAllHistory();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.searchCleared)),
                    );
                  }
                }
              },
              icon: const Icon(Icons.clear_all),
              tooltip: context.l10n.clearAllHistory,
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
            context.l10n.noSearchHistoryTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            context.l10n.noSearchHistorySubtitle,
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
    final groupedHistory = _groupHistoryByDate(context, history);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedHistory.length,
      itemBuilder: (context, index) {
        final group = groupedHistory[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete, color: Colors.white),
            Text(
              context.l10n.delete,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      onDismissed: (direction) async {
        await ref.read(searchProvider.notifier).deleteHistoryItem(historyItem.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.taskDeletedSnackBar)),
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
                '${historyItem.resultCount}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatRelativeTime(context, historyItem.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              final tasks = ref.read(tasksProvider);
              ref.read(searchProvider.notifier).updateQuery(historyItem.query, tasks);
              ref.read(searchProvider.notifier).performSearch(historyItem.query, tasks);
            },
            icon: const Icon(Icons.arrow_forward),
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

  List<Map<String, dynamic>> _groupHistoryByDate(BuildContext context, List<SearchHistory> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));
    final locale = Localizations.localeOf(context).languageCode;
    
    final groups = <String, List<SearchHistory>>{};
    
    for (final item in history) {
      final itemDate = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      
      String dateLabel;
      if (itemDate.isAtSameMomentAs(today)) {
        dateLabel = context.l10n.filterToday;
      } else if (itemDate.isAtSameMomentAs(yesterday)) {
        dateLabel = 'Yesterday';
      } else if (itemDate.isAfter(weekAgo)) {
        dateLabel = context.l10n.filterThisWeek;
      } else {
        dateLabel = DateFormat('MMMM yyyy', locale).format(item.timestamp);
      }
      
      groups.putIfAbsent(dateLabel, () => []).add(item);
    }
    
    return groups.entries.map((entry) => {
      'date': entry.key,
      'items': entry.value,
    }).toList();
  }

  String _formatRelativeTime(BuildContext context, DateTime timestamp) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd MMMM, HH:mm', locale).format(timestamp);
  }

  Future<bool?> _showClearAllDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.clearAllHistory),
        content: Text(context.l10n.clearAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(context.l10n.clearAllHistory),
          ),
        ],
      ),
    );
  }
}
