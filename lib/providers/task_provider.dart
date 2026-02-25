import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../models/task_filter.dart';
import '../repositories/task_repository.dart';
import '../providers/settings_provider.dart';
import '../providers/ai_provider.dart';
import '../utils/error_handler.dart';

/// Provider لصندوق Hive الخاص بالمهام
/// 
/// يوفر الوصول إلى قاعدة البيانات المحلية للمهام
/// يستخدم في جميع أنحاء التطبيق للوصول إلى البيانات
final tasksBoxProvider = Provider<Box<Task>>((ref) {
  final box = Hive.box<Task>('tasksBox');
  return box;
});

/// Provider لمستودع المهام (TaskRepository)
/// 
/// يوفر instance من TaskRepository مع ربطه بـ Hive box
/// يستخدم لإجراء عمليات CRUD على المهام
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final box = ref.watch(tasksBoxProvider);
  return TaskRepository(box);
});

/// StateNotifier لإدارة حالة قائمة المهام
/// 
/// يدير جميع العمليات المتعلقة بالمهام مثل:
/// - إضافة مهمة جديدة
/// - تحديث مهمة موجودة
/// - حذف مهمة
/// - تبديل حالة إنجاز المهمة
/// 
/// يستخدم Repository Pattern للتفاعل مع قاعدة البيانات
/// يدمج مع نظام الإشعارات لجدولة تذكيرات المهام
class TasksNotifier extends StateNotifier<List<Task>> {
  /// Constructor يستقبل TaskRepository و Ref
  /// 
  /// يقوم بتهيئة الحالة الأولية بجميع المهام من قاعدة البيانات
  TasksNotifier(this._repo, this._ref) : super(_repo.getAll());

  /// مستودع المهام للتفاعل مع قاعدة البيانات
  final TaskRepository _repo;
  
  /// Reference للوصول إلى providers
  final Ref _ref;

  /// تحديث قائمة المهام من قاعدة البيانات
  /// 
  /// يتم استدعاؤها بعد كل عملية تعديل لضمان تزامن الحالة
  /// يقوم أيضاً بإعادة تعيين الـ Pagination
  Future<void> refresh() async {
    try {
      state = _repo.getAll();
      resetPagination();
      ErrorHandler.logSuccess('Tasks refreshed successfully');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TasksNotifier.refresh');
      // لا نقوم برمي الخطأ للحفاظ على استمرار التطبيق
    }
  }

  /// إضافة مهمة جديدة
  /// 
  /// [task] المهمة المراد إضافتها
  /// 
  /// يقوم بإضافة المهمة إلى قاعدة البيانات ثم تحديث الحالة
  /// إذا كانت الإشعارات مفعلة، يتم جدولة إشعار للمهمة
  Future<void> add(Task task) async {
    try {
      await _repo.add(task);
      
      // جدولة إشعار إذا كانت الإشعارات مفعلة
      final settings = _ref.read(settingsProvider);
      if (settings.notificationsEnabled) {
        final notificationService = _ref.read(notificationServiceProvider);
        await notificationService.scheduleTaskNotification(task, settings.notificationMinutesBefore);
      }
      
      await refresh();
      ErrorHandler.logSuccess('Task added successfully: ${task.title}');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TasksNotifier.add');
      // إعادة المحاولة مع تحديث الحالة
      try {
        await refresh();
      } catch (refreshError) {
        ErrorHandler.handleError(refreshError, null, context: 'TasksNotifier.add.refresh');
      }
    }
  }

  /// تحديث مهمة موجودة
  /// 
  /// [task] المهمة المحدثة
  /// 
  /// يقوم بإلغاء الإشعار القديم وتحديث المهمة في قاعدة البيانات
  /// إذا كانت الإشعارات مفعلة والمهمة غير مكتملة، يتم جدولة إشعار جديد
  Future<void> update(Task task) async {
    try {
      // إلغاء الإشعار القديم
      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.cancelTaskNotification(task.id);
      
      // تحديث المهمة
      await _repo.update(task);
      
      // جدولة إشعار جديد إذا كانت الإشعارات مفعلة والمهمة غير مكتملة
      final settings = _ref.read(settingsProvider);
      if (settings.notificationsEnabled && !task.isDone) {
        await notificationService.scheduleTaskNotification(task, settings.notificationMinutesBefore);
      }
      
      await refresh();
      ErrorHandler.logSuccess('Task updated successfully: ${task.title}');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TasksNotifier.update');
      // إعادة المحاولة مع تحديث الحالة
      try {
        await refresh();
      } catch (refreshError) {
        ErrorHandler.handleError(refreshError, null, context: 'TasksNotifier.update.refresh');
      }
    }
  }

  /// حذف مهمة
  /// 
  /// [id] معرف المهمة المراد حذفها
  /// 
  /// يقوم بإلغاء الإشعار وحذف المهمة من قاعدة البيانات ثم تحديث الحالة
  Future<void> delete(String id) async {
    try {
      // إلغاء الإشعار
      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.cancelTaskNotification(id);
      
      // حذف المهمة
      await _repo.delete(id);
      await refresh();
      ErrorHandler.logSuccess('Task deleted successfully: $id');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TasksNotifier.delete');
      // إعادة المحاولة مع تحديث الحالة
      try {
        await refresh();
      } catch (refreshError) {
        ErrorHandler.handleError(refreshError, null, context: 'TasksNotifier.delete.refresh');
      }
    }
  }

  /// تبديل حالة إنجاز المهمة
  /// 
  /// [id] معرف المهمة المراد تبديل حالتها
  /// 
  /// يحول المهمة من مكتملة إلى غير مكتملة أو العكس
  /// يقوم بإلغاء أو جدولة الإشعارات حسب الحالة الجديدة
  Future<void> toggleDone(String id) async {
    try {
      // الحصول على المهمة الحالية
      final tasks = _repo.getAll();
      final task = tasks.firstWhere((t) => t.id == id);
      
      final notificationService = _ref.read(notificationServiceProvider);
      
      if (task.isDone) {
        // إذا كانت المهمة مكتملة وستصبح غير مكتملة، جدولة إشعار جديد
        final settings = _ref.read(settingsProvider);
        if (settings.notificationsEnabled) {
          await notificationService.scheduleTaskNotification(task, settings.notificationMinutesBefore);
        }
      } else {
        // إذا كانت المهمة غير مكتملة وستصبح مكتملة، إلغاء الإشعار
        await notificationService.cancelTaskNotification(id);
      }
      
      await _repo.toggleDone(id);
      await refresh();
      ErrorHandler.logSuccess('Task status toggled successfully: $id');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TasksNotifier.toggleDone');
      // إعادة المحاولة مع تحديث الحالة
      try {
        await refresh();
      } catch (refreshError) {
        ErrorHandler.handleError(refreshError, null, context: 'TasksNotifier.toggleDone.refresh');
      }
    }
  }

  /// فلترة المهام حسب المعايير المحددة
  /// 
  /// [filter] معايير الفلترة
  /// 
  /// يرجع قائمة المهام التي تطابق جميع شروط الفلترة
  List<Task> getFilteredTasks(TaskFilter filter) {
    List<Task> tasks = _repo.getAll();

    // فلترة حسب الحالة
    if (filter.status != null) {
      switch (filter.status!) {
        case TaskStatus.pending:
          tasks = tasks.where((task) => !task.isDone).toList();
          break;
        case TaskStatus.completed:
          tasks = tasks.where((task) => task.isDone).toList();
          break;
        case TaskStatus.all:
          // لا تغيير
          break;
      }
    }

    // فلترة حسب الأولوية
    if (filter.priority != null) {
      tasks = tasks.where((task) => task.priority == filter.priority).toList();
    }

    // فلترة حسب التصنيف
    if (filter.category != null) {
      tasks = tasks.where((task) => task.category == filter.category).toList();
    }

    // فلترة حسب التاريخ
    if (filter.dateFilter != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      switch (filter.dateFilter!) {
        case DateFilter.today:
          tasks = tasks.where((task) {
            if (task.dueDate == null) return false;
            final taskDate = DateTime(
              task.dueDate!.year,
              task.dueDate!.month,
              task.dueDate!.day,
            );
            return taskDate.isAtSameMomentAs(today);
          }).toList();
          break;
        case DateFilter.thisWeek:
          tasks = tasks.where((task) {
            if (task.dueDate == null) return false;
            final taskDate = DateTime(
              task.dueDate!.year,
              task.dueDate!.month,
              task.dueDate!.day,
            );
            return !taskDate.isBefore(weekStart) && !taskDate.isAfter(weekEnd);
          }).toList();
          break;
        case DateFilter.overdue:
          tasks = tasks.where((task) {
            if (task.dueDate == null) return false;
            final taskDate = DateTime(
              task.dueDate!.year,
              task.dueDate!.month,
              task.dueDate!.day,
            );
            return taskDate.isBefore(today) && !task.isDone;
          }).toList();
          break;
        case DateFilter.all:
          // لا تغيير
          break;
      }
    }

    return tasks;
  }

  /// إعادة جدولة جميع الإشعارات
  /// 
  /// يقوم بإلغاء جميع الإشعارات الحالية وجدولة إشعارات جديدة
  /// لجميع المهام غير المكتملة التي لها موعد استحقاق
  Future<void> rescheduleAllNotifications() async {
    final notificationService = _ref.read(notificationServiceProvider);
    final settings = _ref.read(settingsProvider);
    
    if (!settings.notificationsEnabled) {
      return;
    }
    
    try {
      // إلغاء جميع الإشعارات الحالية
      await notificationService.cancelAllNotifications();
      
      // المرور على جميع المهام غير المكتملة
      final allTasks = _repo.getAll();
      final incompleteTasks = allTasks.where((task) => !task.isDone);
      
      for (final task in incompleteTasks) {
        if (task.dueDate != null) {
          await notificationService.scheduleTaskNotification(task, settings.notificationMinutesBefore);
        }
      }
      
      debugPrint('تمت إعادة جدولة جميع الإشعارات بنجاح');
    } catch (e) {
      debugPrint('خطأ في إعادة جدولة الإشعارات: $e');
    }
  }

  /// تحميل الصفحة التالية من المهام
  /// 
  /// يزيد رقم الصفحة الحالي ويظهر مؤشر التحميل مؤقتاً
  Future<void> loadNextPage() async {
    final currentPage = _ref.read(currentPageProvider);
    final hasMore = _ref.read(hasMorePagesProvider);
    
    if (!hasMore) return;
    
    // إظهار مؤشر التحميل
    _ref.read(isLoadingProvider.notifier).state = true;
    
    // محاكاة تأخير التحميل (يمكن إزالته في الإصدار النهائي)
    await Future.delayed(const Duration(milliseconds: 300));
    
    // زيادة رقم الصفحة
    _ref.read(currentPageProvider.notifier).state = currentPage + 1;
    
    // إخفاء مؤشر التحميل
    _ref.read(isLoadingProvider.notifier).state = false;
  }

  /// إعادة تعيين الـ Pagination إلى الصفحة الأولى
  /// 
  /// يستخدم عند تغيير الفلاتر أو البحث
  void resetPagination() {
    _ref.read(currentPageProvider.notifier).state = 1;
    _ref.read(isLoadingProvider.notifier).state = false;
  }
}

/// Provider الرئيسي لقائمة المهام
/// 
/// يوفر الوصول إلى TasksNotifier وحالة المهام في جميع أنحاء التطبيق
/// 
/// مثال على الاستخدام:
/// ```dart
/// // في Widget
/// final tasks = ref.watch(tasksProvider);
/// final tasksNotifier = ref.read(tasksProvider.notifier);
/// 
/// // إضافة مهمة
/// await tasksNotifier.add(newTask);
/// ```
final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TasksNotifier(repo, ref);
});

/// Provider لفلترة المهام
/// 
/// يحتفظ بحالة الفلترة الحالية
final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return const TaskFilter();
});

/// Provider للمهام المفلترة
/// 
/// يجمع بين قائمة المهام الأصلية والفلاتر المطبقة
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(taskFilterProvider);
  
  if (!filter.isActive) {
    return tasks;
  }
  
  final tasksNotifier = ref.read(tasksProvider.notifier);
  return tasksNotifier.getFilteredTasks(filter);
});

/// Provider لرقم الصفحة الحالية في Pagination
/// 
/// يدير رقم الصفحة الحالية لعرض المهام
final currentPageProvider = StateProvider<int>((ref) {
  return 1;
});

/// Provider لعدد العناصر في كل صفحة
/// 
/// يحدد عدد المهام التي تعرض في كل صفحة (افتراضي: 20)
final itemsPerPageProvider = StateProvider<int>((ref) {
  return 20;
});

/// Provider للمهام المفلترة مع Pagination
/// 
/// يجمع بين الفلترة وال Pagination لتحسين الأداء
final paginatedTasksProvider = Provider<List<Task>>((ref) {
  final filteredTasks = ref.watch(filteredTasksProvider);
  final currentPage = ref.watch(currentPageProvider);
  final itemsPerPage = ref.watch(itemsPerPageProvider);
  
  // حساب startIndex و endIndex للصفحة الحالية
  final startIndex = (currentPage - 1) * itemsPerPage;
  final endIndex = (startIndex + itemsPerPage).clamp(0, filteredTasks.length);
  
  // إرجاع المهام للصفحة الحالية فقط
  if (startIndex >= filteredTasks.length) {
    return [];
  }
  
  return filteredTasks.sublist(startIndex, endIndex);
});

/// Provider لمعرفة ما إذا يوجد المزيد من الصفحات
/// 
/// يستخدم لإظهار/إخفاء زر "تحميل المزيد"
final hasMorePagesProvider = Provider<bool>((ref) {
  final filteredTasks = ref.watch(filteredTasksProvider);
  final currentPage = ref.watch(currentPageProvider);
  final itemsPerPage = ref.watch(itemsPerPageProvider);
  
  final totalItems = filteredTasks.length;
  final totalPages = (totalItems / itemsPerPage).ceil();
  
  return currentPage < totalPages;
});

/// Provider لحالة التحميل
/// 
/// يستخدم لإظهار مؤشر التحميل عند تحميل صفحة جديدة
final isLoadingProvider = StateProvider<bool>((ref) {
  return false;
});
