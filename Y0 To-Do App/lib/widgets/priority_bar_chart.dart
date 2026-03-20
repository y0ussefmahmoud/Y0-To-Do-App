import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// رسم بياني للمهام حسب الأولوية
/// 
/// يعرض توزيع المهام حسب الأولويات (عالية، متوسطة، منخفضة)
/// يستخدم BarChart من fl_chart
class PriorityBarChart extends StatelessWidget {
  /// بيانات توزيع المهام حسب الأولوية (0: منخفضة، 1: متوسطة، 2: عالية)
  final Map<int, int> priorityData;

  const PriorityBarChart({
    super.key,
    required this.priorityData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // استخراج البيانات
    final highPriority = priorityData[2] ?? 0;
    final mediumPriority = priorityData[1] ?? 0;
    final lowPriority = priorityData[0] ?? 0;
    final total = highPriority + mediumPriority + lowPriority;

    // إذا لم توجد بيانات، عرض رسالة مناسبة
    if (total == 0) {
      return _buildEmptyState(context, isDark);
    }

    // حساب القيمة القصوى للـ Y axis
    final maxValue = [highPriority, mediumPriority, lowPriority].reduce((a, b) => a > b ? a : b);

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
              'المهام حسب الأولوية',
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
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue.toDouble() + 1,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          isDark ? Colors.grey.shade800 : Colors.grey.shade700,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final priority = group.x.toInt();
                        final value = rod.toY.round();
                        String priorityName;
                        
                        switch (priority) {
                          case 2:
                            priorityName = 'عالية';
                            break;
                          case 1:
                            priorityName = 'متوسطة';
                            break;
                          case 0:
                          default:
                            priorityName = 'منخفضة';
                            break;
                        }
                        
                        return BarTooltipItem(
                          '$priorityName: $value',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          String text;
                          switch (value.toInt()) {
                            case 2:
                              text = 'عالية';
                              break;
                            case 1:
                              text = 'متوسطة';
                              break;
                            case 0:
                            default:
                              text = 'منخفضة';
                              break;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              text,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    // عالية
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: highPriority.toDouble(),
                          color: const Color(0xFFEF4444), // أحمر
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    // متوسطة
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: mediumPriority.toDouble(),
                          color: const Color(0xFFF59E0B), // برتقالي
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    // منخفضة
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: lowPriority.toDouble(),
                          color: const Color(0xFF10B981), // أخضر
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context, 'عالية', const Color(0xFFEF4444), highPriority),
                const SizedBox(width: 16),
                _buildLegendItem(context, 'متوسطة', const Color(0xFFF59E0B), mediumPriority),
                const SizedBox(width: 16),
                _buildLegendItem(context, 'منخفضة', const Color(0xFF10B981), lowPriority),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
          delay: 300.ms,
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
              'المهام حسب الأولوية',
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
                    Icons.bar_chart,
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
