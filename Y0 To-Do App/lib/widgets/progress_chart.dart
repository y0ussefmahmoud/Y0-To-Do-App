import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// رسم بياني لنسبة الإنجاز
/// 
/// يعرض نسبة المهام المكتملة مقابل المهام المعلقة
/// يستخدم PieChart من fl_chart
class ProgressChart extends StatelessWidget {
  /// نسبة الإنجاز (0-100)
  final double completionRate;
  
  /// عدد المهام المكتملة
  final int completed;
  
  /// العدد الإجمالي للمهام
  final int total;

  const ProgressChart({
    super.key,
    required this.completionRate,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              'نسبة الإنجاز',
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
                  sections: [
                    // المهام المكتملة
                    PieChartSectionData(
                      value: completionRate,
                      title: '${completionRate.toStringAsFixed(1)}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      color: Colors.green,
                      radius: 60,
                      titlePositionPercentageOffset: 0.6,
                    ),
                    // المهام المعلقة
                    PieChartSectionData(
                      value: 100 - completionRate,
                      title: '${(100 - completionRate).toStringAsFixed(1)}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      color: Colors.grey[400],
                      radius: 60,
                      titlePositionPercentageOffset: 0.6,
                    ),
                  ],
                  centerSpaceRadius: 40,
                  centerSpaceColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  sectionsSpace: 2,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  context,
                  'المهام المكتملة',
                  Colors.green,
                  completed,
                ),
                const SizedBox(width: 24),
                _buildLegendItem(
                  context,
                  'المهام المعلقة',
                  Colors.grey[400]!,
                  total - completed,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
          delay: 100.ms,
          curve: Curves.easeOut,
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
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
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
