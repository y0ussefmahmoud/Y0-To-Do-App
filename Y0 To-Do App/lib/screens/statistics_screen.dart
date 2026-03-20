import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/statistics_provider.dart';
import '../services/ai_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/progress_chart.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/priority_bar_chart.dart';
import '../widgets/weekly_trend_chart.dart';

/// شاشة الإحصائيات
/// 
/// تعرض تحليلات شاملة للمهام مع رسوم بيانية تفاعلية
/// تستخدم جميع الـ widgets المخصصة للإحصائيات
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل الإحصائيات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsProvider.notifier).loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statisticsState = ref.watch(statisticsProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(statisticsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(statisticsProvider.notifier).refresh();
        },
        child: statisticsState.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : statisticsState.totalTasks == 0
                ? _buildEmptyState(context, isDark)
                : _buildStatisticsContent(context, statisticsState, isDark),
      ),
    );
  }

  /// بناء المحتوى الرئيسي للإحصائيات
  Widget _buildStatisticsContent(
    BuildContext context,
    StatisticsState state,
    bool isDark,
  ) {
    return CustomScrollView(
      slivers: [
        // Header متدرج مع معلومات الإنتاجية
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF1E293B),
                        const Color(0xFF0F172A),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFF8FAFC),
                      ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // نقاط الإنتاجية
                  if (state.productivityAnalysis != null) ...[
                    _buildProductivityHeader(context, state.productivityAnalysis!, isDark),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ),
        
        // مسافة
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        
        // Stat Cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            delegate: SliverChildListDelegate([
              StatCard(
                title: 'إجمالي المهام',
                value: state.totalTasks.toString(),
                icon: Icons.task_alt,
                color: const Color(0xFF3B82F6),
              ),
              StatCard(
                title: 'المهام المكتملة',
                value: state.completedTasks.toString(),
                icon: Icons.check_circle,
                color: const Color(0xFF10B981),
              ),
              StatCard(
                title: 'المهام المعلقة',
                value: state.pendingTasks.toString(),
                icon: Icons.pending,
                color: const Color(0xFFF59E0B),
              ),
              StatCard(
                title: 'نسبة الإنجاز',
                value: '${state.completionRate.toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: state.completionRate >= 70
                    ? const Color(0xFF10B981)
                    : state.completionRate >= 40
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFEF4444),
              ),
            ]),
          ),
        ),
        
        // مسافة
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
        
        // Progress Chart
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: ProgressChart(
              completionRate: state.completionRate,
              completed: state.completedTasks,
              total: state.totalTasks,
            ),
          ),
        ),
        
        // مسافة
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
        
        // Category and Priority Charts (في صف واحد)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // على الشاشات الصغيرة، عرض عمود واحد
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      CategoryPieChart(categoryData: state.categoryDistribution),
                      const SizedBox(height: 16),
                      PriorityBarChart(priorityData: state.priorityDistribution),
                    ],
                  );
                }
                
                // على الشاشات الكبيرة، عرض عمودين
                return Row(
                  children: [
                    Expanded(
                      child: CategoryPieChart(categoryData: state.categoryDistribution),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PriorityBarChart(priorityData: state.priorityDistribution),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        
        // مسافة
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
        
        // Weekly Trend Chart
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: WeeklyTrendChart(dailyStats: state.dailyStats),
          ),
        ),
        
        // مسافة
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
        
        // اقتراحات التحسين
        if (state.productivityAnalysis?.suggestions.isNotEmpty == true)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildSuggestionsCard(
                context,
                state.productivityAnalysis!.suggestions,
                isDark,
              ),
            ),
          ),
        
        // مسافة نهائية
        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }

  /// بناء header معلومات الإنتاجية
  Widget _buildProductivityHeader(
    BuildContext context,
    ProductivityAnalysis analysis,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'تحليل الإنتاجية',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نقاط الإنتاجية',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${analysis.score}/100',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (analysis.bestTimeToWork.isNotEmpty) ...[
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أفضل وقت للعمل',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis.bestTimeToWork,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(
          begin: -0.2,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }

  /// بناء بطاقة الاقتراحات
  Widget _buildSuggestionsCard(
    BuildContext context,
    List<String> suggestions,
    bool isDark,
  ) {
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
            Row(
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: Color(0xFFF59E0B),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'اقتراحات التحسين',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_left,
                    color: Color(0xFFF59E0B),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 500.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
          delay: 500.ms,
          curve: Curves.easeOut,
        );
  }

  /// بناء حالة فارغة
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد إحصائيات بعد',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ابدأ بإضافة بعض المهام لعرض الإحصائيات',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
