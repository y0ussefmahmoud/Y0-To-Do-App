// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n_extension.dart';
import '../theme/y0_design_system.dart';
import '../widgets/bottom_navigation.dart';
import '../providers/task_provider.dart';
import '../widgets/statistics/editorial_hero_header.dart';
import '../widgets/statistics/quick_stats_cards.dart';
import '../widgets/statistics/weekly_productivity_chart.dart';
import '../widgets/statistics/achievement_badges.dart';
import '../widgets/statistics/archive_summary_card.dart';

/// 📊 Y0 To-Do App - Statistics Screen
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasks = ref.watch(tasksProvider);
    final counts = ref.watch(taskCountsProvider);
    final todayProgressPercent = counts.todayProgressPercent;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : context.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Y0DesignSystem.spacing3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar
            _buildTopAppBar(context, isDark),
            
            const SizedBox(height: Y0DesignSystem.spacing4),
            
            // Editorial Hero Header (Today's Progress Rate)
            EditorialHeroHeader(completionRate: todayProgressPercent, isDark: isDark),
            
            const SizedBox(height: Y0DesignSystem.spacing4),
            
            // Quick Stats Cards
            QuickStatsCards(tasks: tasks, isDark: isDark),
            
            const SizedBox(height: Y0DesignSystem.spacing4),

            // Archive Summary Card
            ArchiveSummaryCard(tasks: tasks, isDark: isDark),
            
            const SizedBox(height: Y0DesignSystem.spacing4),
            
            // Weekly Chart Card
            WeeklyProductivityChart(tasks: tasks, isDark: isDark),
            
            const SizedBox(height: Y0DesignSystem.spacing4),
            
            // Achievement Badges Section
            AchievementBadges(completedTasks: counts.completed, isDark: isDark),
            
            const SizedBox(height: Y0DesignSystem.spacing4),
            
            // Bottom padding for navigation
            const SizedBox(height: 160),
          ],
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1,
        onTap: (index) => _handleNavigationTap(context, index),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Y0DesignSystem.spacing3,
        vertical: Y0DesignSystem.spacing2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.appTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              color: isDark 
                  ? const Color(0xFF66bb6a)
                  : context.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigationTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/');
        break;
      case 1:
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/settings');
        break;
    }
  }
}
