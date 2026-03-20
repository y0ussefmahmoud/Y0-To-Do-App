import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/statistics_provider.dart';

/// رسم بياني للاتجاه الأسبوعي
/// 
/// يعرض اتجاه المهام المضافة والمكتملة خلال آخر 7 أيام
/// يستخدم LineChart من fl_chart
class WeeklyTrendChart extends StatelessWidget {
  /// الإحصائيات اليومية (آخر 7 أيام)
  final List<DailyStats> dailyStats;

  const WeeklyTrendChart({
    super.key,
    required this.dailyStats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // إذا لم توجد بيانات، عرض رسالة مناسبة
    if (dailyStats.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    // حساب القيم القصوى للـ Y axis
    final maxAdded = dailyStats.map((stat) => stat.added).reduce((a, b) => a > b ? a : b);
    final maxCompleted = dailyStats.map((stat) => stat.completed).reduce((a, b) => a > b ? a : b);
    final maxY = (maxAdded > maxCompleted ? maxAdded : maxCompleted).toDouble() + 1;

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
              'الاتجاه الأسبوعي',
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
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) =>
                          isDark ? Colors.grey.shade800 : Colors.grey.shade700,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index < 0 || index >= dailyStats.length) return null;
                          
                          final dailyStat = dailyStats[index];
                          final isCompleted = spot.barIndex == 1;
                          final value = isCompleted ? dailyStat.completed : dailyStat.added;
                          final label = isCompleted ? 'مكتملة' : 'مضافة';
                          
                          return LineTooltipItem(
                            '$label: $value',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= dailyStats.length) {
                            return const Text('');
                          }
                          
                          final date = dailyStats[index].date;
                          final dayName = DateFormat('EEE', 'ar').format(date);
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              dayName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 10,
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
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value < 0) return const Text('');
                          
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
                  minX: 0,
                  maxX: (dailyStats.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    // خط المهام المضافة
                    LineChartBarData(
                      spots: dailyStats.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.added.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: const Color(0xFF3B82F6), // أزرق
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: const Color(0xFF3B82F6),
                            strokeWidth: 0,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      ),
                    ),
                    // خط المهام المكتملة
                    LineChartBarData(
                      spots: dailyStats.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.completed.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: const Color(0xFF10B981), // أخضر
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: const Color(0xFF10B981),
                            strokeWidth: 0,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      ),
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
                _buildLegendItem(context, 'المهام المضافة', const Color(0xFF3B82F6)),
                const SizedBox(width: 24),
                _buildLegendItem(context, 'المهام المكتملة', const Color(0xFF10B981)),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 400.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
          delay: 400.ms,
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
              'الاتجاه الأسبوعي',
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
                    Icons.show_chart,
                    size: 48,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد بيانات كافية',
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
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
