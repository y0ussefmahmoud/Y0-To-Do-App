// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../services/ai_service.dart';
import '../utils/date_utils.dart';
import 'task_provider.dart';
import 'ai_provider.dart';

/// الإحصائيات اليومية
class DailyStats {
  /// التاريخ
  final DateTime date;
  
  /// عدد المهام المكتملة في هذا اليوم
  final int completed;
  
  /// عدد المهام المضافة في هذا اليوم
  final int added;

  const DailyStats({
    required this.date,
    required this.completed,
    required this.added,
  });
}

/// حالة الإحصائيات
class StatisticsState {
  /// تحليل الإنتاجية من AI
  final ProductivityAnalysis? productivityAnalysis;
  
  /// توزيع المهام حسب التصنيف
  final Map<TaskCategory, int> categoryDistribution;
  
  /// توزيع المهام حسب الأولوية (0: منخفضة، 1: متوسطة، 2: عالية)
  final Map<int, int> priorityDistribution;
  
  /// إجمالي عدد المهام العام
  final int totalTasks;
  
  /// عدد المهام المكتملة العام
  final int completedTasks;
  
  /// عدد المهام المعلقة العام
  final int pendingTasks;
  
  /// نسبة الإنجاز العامة (0-100)
  final double completionRate;

  /// إجمالي مهام اليوم (تاريخ استحقاقها اليوم)
  final int todayTotalTasks;

  /// مهام اليوم المكتملة (تاريخ استحقاقها اليوم ومكتملة)
  final int todayCompletedTasks;

  /// مهام اليوم المعلقة (تاريخ استحقاقها اليوم وغير مكتملة)
  final int todayPendingTasks;

  /// نسبة إنجاز اليوم (0-100)
  final double todayProgressRate;
  
  /// الإحصائيات اليومية (آخر 7 أيام)
  final List<DailyStats> dailyStats;
  
  /// هل يتم تحميل البيانات حالياً؟
  final bool isLoading;
  
  /// آخر تحديث للبيانات
  final DateTime? lastUpdated;

  const StatisticsState({
    this.productivityAnalysis,
    this.categoryDistribution = const {},
    this.priorityDistribution = const {},
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.pendingTasks = 0,
    this.completionRate = 0.0,
    this.todayTotalTasks = 0,
    this.todayCompletedTasks = 0,
    this.todayPendingTasks = 0,
    this.todayProgressRate = 0.0,
    this.dailyStats = const [],
    this.isLoading = false,
    this.lastUpdated,
  });

  /// إنشاء نسخة جديدة من الحالة مع تعديل بعض الخصائص
  StatisticsState copyWith({
    ProductivityAnalysis? productivityAnalysis,
    Map<TaskCategory, int>? categoryDistribution,
    Map<int, int>? priorityDistribution,
    int? totalTasks,
    int? completedTasks,
    int? pendingTasks,
    double? completionRate,
    int? todayTotalTasks,
    int? todayCompletedTasks,
    int? todayPendingTasks,
    double? todayProgressRate,
    List<DailyStats>? dailyStats,
    bool? isLoading,
    DateTime? lastUpdated,
  }) {
    return StatisticsState(
      productivityAnalysis: productivityAnalysis ?? this.productivityAnalysis,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      priorityDistribution: priorityDistribution ?? this.priorityDistribution,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      completionRate: completionRate ?? this.completionRate,
      todayTotalTasks: todayTotalTasks ?? this.todayTotalTasks,
      todayCompletedTasks: todayCompletedTasks ?? this.todayCompletedTasks,
      todayPendingTasks: todayPendingTasks ?? this.todayPendingTasks,
      todayProgressRate: todayProgressRate ?? this.todayProgressRate,
      dailyStats: dailyStats ?? this.dailyStats,
      isLoading: isLoading ?? this.isLoading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// التحقق من الحاجة لإعادة تحميل البيانات
  bool shouldRefresh() {
    if (lastUpdated == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);
    
    // إعادة التحميل إذا مرت 5 دقائق أو أكثر
    return difference.inMinutes >= 5;
  }
}

/// StateNotifier لإدارة الإحصائيات
class StatisticsNotifier extends StateNotifier<StatisticsState> {
  /// خدمة الذكاء الاصطناعي
  final AIService _aiService;
  
  /// Reference للوصول إلى providers
  final Ref ref;

  /// Constructor يستقبل Ref و AIService
  StatisticsNotifier(this.ref, this._aiService) : super(const StatisticsState());

  /// تحميل الإحصائيات
  Future<void> loadStatistics({bool force = false}) async {
    // التحقق من الحاجة لإعادة التحميل
    if (!force && !state.shouldRefresh()) return;
    
    state = state.copyWith(isLoading: true);

    try {
      // جلب جميع المهام
      final allTasks = ref.read(tasksProvider);

      // ── تصنيف المهام العام بدقة بدون تكرار (double-counting) ─────────────
      final completedTasks = allTasks.where((t) => t.isDone).length;
      final activeTasks = allTasks.where((t) => !t.isArchived).toList();
      final pendingTasks = activeTasks.where((t) => !t.isDone).length;
      final totalTasks = activeTasks.length + completedTasks;
      final completionRate = totalTasks > 0
          ? (completedTasks / totalTasks) * 100
          : 0.0;

      // ── حساب إحصائيات إنجاز اليوم حصراً (Today's Tasks) ────────────────
      final todayTasks = allTasks.where((t) => AppDateUtils.isToday(t.dueDate)).toList();
      final todayCompletedTasks = todayTasks.where((t) => t.isDone).length;
      final todayPendingTasks = todayTasks.where((t) => !t.isDone).length;
      final todayTotalTasks = todayTasks.length;
      final todayProgressRate = todayTotalTasks > 0
          ? (todayCompletedTasks / todayTotalTasks) * 100
          : 0.0;

      // حساب توزيع المهام حسب التصنيف (المهام النشطة فقط)
      final categoryDistribution = <TaskCategory, int>{};
      for (final task in activeTasks) {
        categoryDistribution[task.safeCategory] =
            (categoryDistribution[task.safeCategory] ?? 0) + 1;
      }

      // حساب توزيع المهام حسب الأولوية (المهام النشطة فقط)
      final priorityDistribution = <int, int>{0: 0, 1: 0, 2: 0};
      for (final task in activeTasks) {
        priorityDistribution[task.priority] =
            (priorityDistribution[task.priority] ?? 0) + 1;
      }

      // حساب الإحصائيات اليومية (آخر 7 أيام)
      final dailyStats = _calculateDailyStats(allTasks);

      // تحليل الإنتاجية للمهام المكتملة
      ProductivityAnalysis? productivityAnalysis;
      if (completedTasks > 0) {
        final completedTasksData = allTasks
            .where((task) => task.isDone)
            .map((task) => {
                  'title': task.title,
                  'category': task.safeCategory.name,
                  'priority': task.priority,
                  'completedAt':
                      task.dueDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
                })
            .toList();
        
        productivityAnalysis = _aiService.analyzeProductivity(completedTasksData);
      }

      state = state.copyWith(
        productivityAnalysis: productivityAnalysis,
        categoryDistribution: categoryDistribution,
        priorityDistribution: priorityDistribution,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        completionRate: completionRate,
        todayTotalTasks: todayTotalTasks,
        todayCompletedTasks: todayCompletedTasks,
        todayPendingTasks: todayPendingTasks,
        todayProgressRate: todayProgressRate,
        dailyStats: dailyStats,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// حساب الإحصائيات اليومية
  List<DailyStats> _calculateDailyStats(List<Task> tasks) {
    final now = DateTime.now();
    final dailyStats = <DailyStats>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final nextDate = date.add(const Duration(days: 1));

      // حساب المهام المضافة في هذا اليوم
      final added = tasks.where((task) {
        final taskDate = DateTime(
          task.dueDate?.year ?? date.year,
          task.dueDate?.month ?? date.month,
          task.dueDate?.day ?? date.day,
        );
        return taskDate.isAtSameMomentAs(date) || 
               (taskDate.isAfter(date) && taskDate.isBefore(nextDate));
      }).length;

      // حساب المهام المكتملة في هذا اليوم
      final completed = tasks.where((task) {
        if (!task.isDone) return false;
        final taskDate = DateTime(
          task.dueDate?.year ?? date.year,
          task.dueDate?.month ?? date.month,
          task.dueDate?.day ?? date.day,
        );
        return taskDate.isAtSameMomentAs(date);
      }).length;

      dailyStats.add(DailyStats(
        date: date,
        completed: completed,
        added: added,
      ));
    }

    return dailyStats;
  }

  /// إعادة تحميل الإحصائيات
  Future<void> refresh() async {
    await loadStatistics(force: true);
  }
}

/// Provider للإحصائيات
final statisticsProvider = StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  final aiService = ref.read(aiServiceProvider);
  return StatisticsNotifier(ref, aiService);
});
