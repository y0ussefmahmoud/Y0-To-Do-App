import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../services/ai_service.dart';
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
  
  /// إجمالي عدد المهام
  final int totalTasks;
  
  /// عدد المهام المكتملة
  final int completedTasks;
  
  /// عدد المهام المعلقة
  final int pendingTasks;
  
  /// نسبة الإنجاز (0-100)
  final double completionRate;
  
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
      final tasks = ref.read(tasksProvider);
      
      // حساب الإحصائيات الأساسية
      final totalTasks = tasks.length;
      final completedTasks = tasks.where((task) => task.isDone).length;
      final pendingTasks = totalTasks - completedTasks;
      final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

      // حساب توزيع المهام حسب التصنيف
      final categoryDistribution = <TaskCategory, int>{};
      for (final task in tasks) {
        categoryDistribution[task.category] = (categoryDistribution[task.category] ?? 0) + 1;
      }

      // حساب توزيع المهام حسب الأولوية
      final priorityDistribution = <int, int>{0: 0, 1: 0, 2: 0};
      for (final task in tasks) {
        priorityDistribution[task.priority] = (priorityDistribution[task.priority] ?? 0) + 1;
      }

      // حساب الإحصائيات اليومية (آخر 7 أيام)
      final dailyStats = _calculateDailyStats(tasks);

      // تحليل الإنتاجية للمهام المكتملة
      ProductivityAnalysis? productivityAnalysis;
      if (completedTasks > 0) {
        final completedTasksData = tasks
            .where((task) => task.isDone)
            .map((task) => {
                  'title': task.title,
                  'category': task.category.name,
                  'priority': task.priority,
                  'completedAt': task.dueDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
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
