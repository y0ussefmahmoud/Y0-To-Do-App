import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task_category.dart';

/// رسم بياني للمهام حسب التصنيف
/// 
/// يعرض توزيع المهام على مختلف التصنيفات
/// يستخدم PieChart من fl_chart مع ألوان كل تصنيف
class CategoryPieChart extends StatelessWidget {
  /// بيانات توزيع المهام حسب التصنيف
  final Map<TaskCategory, int> categoryData;

  const CategoryPieChart({
    super.key,
    required this.categoryData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // حساب المجموع الكلي
    final total = categoryData.values.fold(0, (sum, count) => sum + count);
    
    // إذا لم توجد بيانات، عرض رسالة مناسبة
    if (total == 0) {
      return _buildEmptyState(context, isDark);
    }

    // إنشاء أقسام الرسم البياني
    final sections = categoryData.entries.map((entry) {
      final category = entry.key;
      final count = entry.value;
      final percentage = (count / total) * 100;

      return PieChartSectionData(
        value: percentage,
        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        color: category.color,
        radius: 60,
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Text(
              'المهام حسب التصنيف',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            
            // الرسم البياني
            SizedBox(
              height: 200,
              width: double.infinity,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  centerSpaceColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  sectionsSpace: 2,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: categoryData.entries.map((entry) {
                final category = entry.key;
                final count = entry.value;
                
                return _buildLegendItem(
                  context,
                  category.displayName,
                  category.color,
                  count,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
          delay: 200.ms,
          curve: Curves.easeOut,
        );
  }

  /// بناء حالة فارغة
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المهام حسب التصنيف',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.pie_chart,
                    size: 48,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد مهام بعد',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء عنصر الـ Legend
  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    int count,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
