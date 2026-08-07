// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import '../../theme/y0_design_system.dart';
import '../../widgets/neo_morphic_card.dart';
import '../../models/task.dart';

class ArchiveSummaryCard extends StatelessWidget {
  final List<Task> tasks;
  final bool isDark;

  const ArchiveSummaryCard({
    super.key,
    required this.tasks,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((t) => t.isDone).length;
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final olderThanMonthCount = tasks.where((t) => !t.isDone && t.dueDate != null && t.dueDate!.isBefore(monthAgo)).length;
    final activeCount = tasks.where((t) => !t.isArchived).length;

    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeoMorphicCard(
                padding: const EdgeInsets.all(Y0DesignSystem.spacing2),
                borderRadius: BorderRadius.circular(Y0DesignSystem.radiusSmall),
                color: isDark 
                    ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                    : context.colorScheme.primaryContainer.withValues(alpha: 0.2),
                child: Icon(
                  Icons.archive,
                  color: isDark ? const Color(0xFF60A5FA) : context.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: Y0DesignSystem.spacing2),
              Expanded(
                child: Text(
                  'أرشيف المهام والتنظيف التلقائي',
                  textAlign: TextAlign.end,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : context.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Y0DesignSystem.spacing3),
          Text(
            'تنتقل المهام المكتملة أو التي يمر على موعدها أكثر من 30 يوماً تلقائياً إلى الأرشيف الحفظي.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFFB3B3B3) : context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: Y0DesignSystem.spacing4),
          Row(
            children: [
              Expanded(
                child: _buildBadgeItem(
                  context,
                  'مهام نشطة',
                  '$activeCount',
                  Icons.play_circle_outline,
                  isDark ? Colors.green.shade400 : Colors.green,
                ),
              ),
              const SizedBox(width: Y0DesignSystem.spacing2),
              Expanded(
                child: _buildBadgeItem(
                  context,
                  'قديمة (>30 يوم)',
                  '$olderThanMonthCount',
                  Icons.history,
                  isDark ? Colors.orange.shade400 : Colors.orange,
                ),
              ),
              const SizedBox(width: Y0DesignSystem.spacing2),
              Expanded(
                child: _buildBadgeItem(
                  context,
                  'مكتملة',
                  '$completedCount',
                  Icons.check_circle_outline,
                  isDark ? Colors.blue.shade400 : Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: Y0DesignSystem.spacing2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Y0DesignSystem.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              color: isDark ? const Color(0xFFB3B3B3) : context.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
