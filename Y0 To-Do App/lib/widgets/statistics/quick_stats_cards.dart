// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/y0_design_system.dart';
import '../../widgets/neo_morphic_card.dart';
import '../../models/task.dart';

class QuickStatsCards extends StatelessWidget {
  final List<Task> tasks;
  final bool isDark;

  const QuickStatsCards({
    super.key,
    required this.tasks,
    required this.isDark,
  });

  double _parsePercentage(String percentage) {
    try {
      final cleanValue = percentage.replaceAll('%', '').trim();
      return double.parse(cleanValue);
    } catch (e) {
      return 0.0;
    }
  }

  Widget _buildQuickStatCard(
    BuildContext context,
    String label,
    String value,
    String? percentage,
    IconData icon,
    bool showProgress,
  ) {
    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing3),
      color: isDark ? const Color(0xFF1E1E1E) : null,
      child: Row(
        children: [
          if (showProgress && percentage != null)
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF66bb6a) : context.colorScheme.primary,
                        width: 4,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: _parsePercentage(percentage) / 100,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? const Color(0xFF66bb6a) : context.colorScheme.primary,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      percentage,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: isDark ? const Color(0xFF66bb6a) : context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            NeoMorphicCard(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(Y0DesignSystem.radiusSmall),
              color: isDark ? const Color(0xFF2D2D2D) : context.colorScheme.surface,
              child: Icon(
                icon,
                color: isDark ? const Color(0xFF66bb6a) : context.colorScheme.primary,
                size: 24,
              ),
            ),
          const SizedBox(width: Y0DesignSystem.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isDark ? const Color(0xFFB3B3B3) : context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Y0DesignSystem.spacing2 / 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : context.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task.isDone).length;
    final totalTasks = tasks.length;
    final activeCount = tasks.where((task) => !task.isArchived).length;
    final archivedCount = tasks.where((task) => task.isArchived).length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    return Column(
      children: [
        _buildQuickStatCard(
          context,
          context.l10n.quickStatsCompletedTasks,
          context.l10n.completedOutOfTotal(completedTasks, totalTasks),
          '$completionRate%',
          Icons.check_circle_outline,
          true,
        ),
        const SizedBox(height: Y0DesignSystem.spacing3),
        _buildQuickStatCard(
          context,
          context.l10n.quickStatsPendingTasks,
          '$activeCount',
          null,
          Icons.flag,
          false,
        ),
        const SizedBox(height: Y0DesignSystem.spacing3),
        _buildQuickStatCard(
          context,
          context.l10n.quickStatsArchivedTasks,
          '$archivedCount',
          null,
          Icons.archive,
          false,
        ),
      ],
    );
  }
}
