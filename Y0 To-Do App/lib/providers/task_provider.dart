// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_filter.dart';
import '../models/sub_task.dart';
import 'package:uuid/uuid.dart';
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
/// - إعادة ترتيب المهام (drag-and-drop)
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
  /// يقوم بإضافة المهمة إلى قاعدة البيانات ثم تحديث الحالة.
  /// يُعيَّن sortOrder بناءً على عدد المهام النشطة المعلقة الحالية،
  /// مما يضمن أن المهام الأقدم إنشاءً تملك sortOrder أصغر وتظهر أعلى
  /// (Oldest-first default ordering).
  /// إذا كانت الإشعارات مفعلة، يتم جدولة إشعار للمهمة
  Future<void> addTask(Task task) async {
    try {
      // تعيين sortOrder بحيث تظهر المهام الأقدم أولاً (الأقدم = sortOrder أصغر)
      // والمهام الجديدة تضاف في نهاية القائمة (Newest = أعلى sortOrder)
      final currentTasks = _repo.getAll();
      final activePending = currentTasks.where((t) => !t.isDone && !t.isArchived).toList();
      final nextSortOrder = activePending.isEmpty
          ? 0
          : (activePending.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1);
      final taskWithOrder = task.copyWith(
        sortOrder: task.sortOrder > 0 ? task.sortOrder : nextSortOrder,
      );

      await _repo.add(taskWithOrder);
      state = [...state, taskWithOrder];
      
      // جدولة إشعار للمهمة إذا كان لها تاريخ استحقاق
      if (task.dueDate != null) {
        final settings = _ref.read(settingsProvider);
        if (settings.notificationsEnabled) {
          final notificationService = _ref.read(notificationServiceProvider);
          await notificationService.scheduleTaskNotification(taskWithOrder, settings.notificationMinutesBefore);
          
          // جدولة إشعار دقيق الوقت إذا كان مفعلاً
          if (settings.exactTimeNotificationsEnabled) {
            await notificationService.scheduleExactTimeNotification(taskWithOrder);
          }
        }
      }
      
      await refresh();
      ErrorHandler.logSuccess('Task added successfully: ${task.title}');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TasksNotifier.add');
      // إعادة المحاولة مع تحديث الحالة
      try {
        await refresh();
      } catch (refreshError) {
        ErrorHandler.handleError(refreshError, stackTrace, context: 'TasksNotifier.add.refresh');
      }
    }
  }

  /// إضافة مهمة (اسم مستعار لـ addTask للتوافق مع الشاشات القديمة)
  Future<void> add(Task task) => addTask(task);

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
        
        // جدولة إشعار دقيق الوقت إذا كان مفعلاً
        if (settings.exactTimeNotificationsEnabled) {
          await notificationService.scheduleExactTimeNotification(task);
        }
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
      
      final wasDone = task.isDone;
      if (wasDone) {
        // إذا كانت المهمة مكتملة وستصبح غير مكتملة، جدولة إشعار جديد
        final settings = _ref.read(settingsProvider);
        if (settings.notificationsEnabled) {
          await notificationService.scheduleTaskNotification(task, settings.notificationMinutesBefore);
          
          // جدولة إشعار دقيق الوقت إذا كان مفعلاً
          if (settings.exactTimeNotificationsEnabled) {
            await notificationService.scheduleExactTimeNotification(task);
          }
        }
      } else {
        // إذا كانت المهمة غير مكتملة وستصبح مكتملة، إلغاء الإشعار
        await notificationService.cancelTaskNotification(id);
      }
      
      await _repo.toggleDone(id);

      // ── التكرار الذكي: إذا اكتملت مهمة متكررة، يتم إنشاء التكرار التالي تلقائياً ──
      if (!wasDone && task.isRecurring && task.dueDate != null) {
        final nextDueDate = task.recurrenceRule!.calculateNextDueDate(task.dueDate!);
        if (nextDueDate != null) {
          // إعادة تعيين المهام الفرعية للتكرار الجديد
          final freshSubtasks = task.subtasks.map((s) => s.copyWith(isDone: false)).toList();
          final nextOccurrence = Task(
            id: const Uuid().v4(),
            title: task.title,
            note: task.note,
            dueDate: nextDueDate,
            priority: task.priority,
            category: task.category,
            recurrenceRule: task.recurrenceRule,
            subtasks: freshSubtasks,
            tags: List<String>.from(task.tags),
            isDone: false,
          );
          await addTask(nextOccurrence);
          ErrorHandler.logSuccess('Next recurring task spawned for date: $nextDueDate');
        }
      }
      
      await refresh();
      ErrorHandler.logSuccess('Task status toggled successfully: $id');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TasksNotifier.toggleDone');
      try {
        await refresh();
      } catch (refreshError) {
        ErrorHandler.handleError(refreshError, null, context: 'TasksNotifier.toggleDone.refresh');
      }
    }
  }

  /// تبديل حالة إنجاز مهمة فرعية (Sub-task)
  Future<void> toggleSubTask(String taskId, String subTaskId) async {
    try {
      final task = state.firstWhere((t) => t.id == taskId);
      final updatedSubtasks = task.subtasks.map((s) {
        if (s.id == subTaskId) {
          return s.copyWith(isDone: !s.isDone);
        }
        return s;
      }).toList();

      final updatedTask = task.copyWith(subtasks: updatedSubtasks);
      await update(updatedTask);
      ErrorHandler.logSuccess('SubTask $subTaskId toggled in task $taskId');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TasksNotifier.toggleSubTask');
    }
  }

  /// إضافة مهمة فرعية جديدة (Sub-task)
  Future<void> addSubTask(String taskId, String title) async {
    try {
      final trimmed = title.trim();
      if (trimmed.isEmpty) return;

      final task = state.firstWhere((t) => t.id == taskId);
      final newSubTask = SubTask(
        id: const Uuid().v4(),
        title: trimmed,
        isDone: false,
      );

      final updatedTask = task.copyWith(
        subtasks: [...task.subtasks, newSubTask],
      );
      await update(updatedTask);
      ErrorHandler.logSuccess('SubTask added to task $taskId: $trimmed');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TasksNotifier.addSubTask');
    }
  }

  /// حذف مهمة فرعية (Sub-task)
  Future<void> deleteSubTask(String taskId, String subTaskId) async {
    try {
      final task = state.firstWhere((t) => t.id == taskId);
      final updatedSubtasks = task.subtasks.where((s) => s.id != subTaskId).toList();
      final updatedTask = task.copyWith(subtasks: updatedSubtasks);
      await update(updatedTask);
      ErrorHandler.logSuccess('SubTask $subTaskId deleted from task $taskId');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TasksNotifier.deleteSubTask');
    }
  }

  /// إعادة ترتيب المهام (Drag-and-Drop)
  ///
  /// [oldIndex] الفهرس القديم للمهمة في القائمة النشطة المعلقة
  /// [newIndex] الفهرس الجديد للمهمة في القائمة النشطة المعلقة
  ///
  /// يحدّث sortOrder لجميع المهام المتأثرة ويكتب التغييرات إلى Hive.
  /// يفلتر فقط المهام النشطة غير المكتملة وغير المؤرشفة
  /// بنفس معيار activePendingTasksProvider لضمان توافق الفهارس.
  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    try {
      // الحصول على المهام النشطة المعلقة المرتبة — نفس ما تعرضه الواجهة
      final activePending = state
          .where((t) => !t.isDone && !t.isArchived)
          .toList()
        ..sort((a, b) {
          final orderCmp = a.sortOrder.compareTo(b.sortOrder);
          if (orderCmp != 0) return orderCmp;
          return a.id.compareTo(b.id);
        });

      if (oldIndex < 0 ||
          newIndex < 0 ||
          oldIndex >= activePending.length ||
          newIndex > activePending.length) {
        return;
      }

      // SliverReorderableList يمرر newIndex بعد الإزالة — تصحيح المؤشر
      final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;

      // إعادة الترتيب في القائمة
      final reordered = List<Task>.from(activePending);
      final moved = reordered.removeAt(oldIndex);
      reordered.insert(adjustedNewIndex, moved);

      // تعيين sortOrder جديد بناءً على الترتيب الجديد
      // الأعلى في القائمة (فهرس 0) = sortOrder أصغر (oldest first)
      final updatedPending = <Task>[];
      for (int i = 0; i < reordered.length; i++) {
        updatedPending.add(reordered[i].copyWith(sortOrder: i));
      }

      // تحديث الحالة فوراً (optimistic update) مع الحفاظ على المهام الأخرى
      final others = state.where((t) => t.isDone || t.isArchived).toList();
      state = [...updatedPending, ...others];

      // كتابة التغييرات إلى Hive بصورة غير متزامنة (batch write)
      for (final task in updatedPending) {
        await _repo.update(task);
      }

      ErrorHandler.logSuccess('Tasks reordered successfully');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TasksNotifier.reorderTasks');
      // إعادة الحالة من قاعدة البيانات عند حدوث خطأ
      await refresh();
    }
  }

  /// فلترة المهام حسب المعايير المحددة
  /// 
  /// [filter] معايير الفلترة
  /// 
  /// يرجع قائمة المهام التي تطابق جميع شروط الفلترة
  List<Task> getFilteredTasks(TaskFilter filter) {
    List<Task> tasks = _repo.getAll();

    // فلترة حسب الحالة (اختيار فردي)
    if (filter.status != null) {
      switch (filter.status!) {
        case TaskStatus.pending:
          tasks = tasks.where((task) => !task.isDone && !task.isArchived).toList();
          break;
        case TaskStatus.completed:
          tasks = tasks.where((task) => task.isDone).toList();
          break;
        case TaskStatus.archived:
          tasks = tasks.where((task) => task.isArchived).toList();
          break;
        case TaskStatus.all:
          break;
      }
    }

    // فلترة حسب الأولوية (multi-select — OR بين المختارات)
    if (filter.priorities.isNotEmpty) {
      tasks = tasks.where((task) => filter.priorities.contains(task.priority)).toList();
    }

    // فلترة حسب التصنيف (multi-select — OR بين المختارات)
    if (filter.categories.isNotEmpty) {
      tasks = tasks.where((task) => filter.categories.contains(task.safeCategory)).toList();
    }

    // فلترة حسب التاريخ (multi-select — OR بين المختارات)
    if (filter.dateFilters.isNotEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      tasks = tasks.where((task) {
        for (final dateFilter in filter.dateFilters) {
          switch (dateFilter) {
            case DateFilter.today:
              if (task.dueDate != null) {
                final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
                if (taskDate.isAtSameMomentAs(today)) return true;
              }
              break;
            case DateFilter.thisWeek:
              if (task.dueDate != null) {
                final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
                if (!taskDate.isBefore(weekStart) && !taskDate.isAfter(weekEnd)) return true;
              }
              break;
            case DateFilter.overdue:
              if (task.dueDate != null) {
                final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
                if (taskDate.isBefore(today) && !task.isDone) return true;
              }
              break;
            case DateFilter.all:
              return true;
          }
        }
        return false;
      }).toList();
    }

    // ترتيب المهام المفلترة:
    // عند تفعيل فلتر "اليوم" أو "هذا الأسبوع"، يتم ترتيب المهام زمنياً حسب الوقت (الساعة والدقيقة).
    // المهام ذات الوقت المحدد تأتي أولاً مرتبة زمنياً، تليها المهام بدون وقت محدد مرتبة بالأولوية.
    final hasTodayOrWeekFilter = filter.dateFilters.contains(DateFilter.today) ||
        filter.dateFilters.contains(DateFilter.thisWeek);

    // فلترة حسب الوسوم (multi-select — OR بين الوسوم المختارة)
    if (filter.tags.isNotEmpty) {
      tasks = tasks.where((task) {
        return task.tags.any((tag) => filter.tags.contains(tag));
      }).toList();
    }

    tasks.sort((a, b) {
      if (hasTodayOrWeekFilter) {
        // إذا كان كلاهما له تاريخ
        if (a.dueDate != null && b.dueDate != null) {
          final dateA = DateTime(a.dueDate!.year, a.dueDate!.month, a.dueDate!.day);
          final dateB = DateTime(b.dueDate!.year, b.dueDate!.month, b.dueDate!.day);
          final dateCmp = dateA.compareTo(dateB);
          if (dateCmp != 0) return dateCmp;

          // نفس اليوم: التحقق من وجود وقت محدد
          if (a.hasTime && b.hasTime) {
            final timeCmp = a.dueDate!.compareTo(b.dueDate!);
            if (timeCmp != 0) return timeCmp;
          } else if (a.hasTime && !b.hasTime) {
            return -1; // ذات الوقت تأتي أولاً
          } else if (!a.hasTime && b.hasTime) {
            return 1;
          }
        }
      }

      // الترتيب الافتراضي
      final orderCmp = a.sortOrder.compareTo(b.sortOrder);
      if (orderCmp != 0) return orderCmp;
      return b.priority.compareTo(a.priority);
    });

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
          
          // جدولة إشعار دقيق الوقت إذا كان مفعلاً
          if (settings.exactTimeNotificationsEnabled) {
            await notificationService.scheduleExactTimeNotification(task);
          }
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

/// Provider للمهام النشطة المعلقة (غير مكتملة وغير مؤرشفة)
///
/// يُظهر فقط المهام غير المكتملة وغير المؤرشفة (!isDone && !isArchived)
/// مرتبة حسب sortOrder تصاعدياً (الأقدم إنشاءً أولاً) كترتيب افتراضي.
/// المهام ذات نفس sortOrder تُرتَّب ثانياً حسب الوقت المحدد (إن وُجد) ثم الأولوية.
/// يمكن للمستخدم إعادة ترتيب المهام يدوياً عبر السحب والإفلات مما يُحدّث sortOrder.
final activePendingTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks
      .where((t) => !t.isDone && !t.isArchived)
      .toList()
    ..sort((a, b) {
      // الترتيب الأساسي: sortOrder تصاعدي (الأقدم إنشاءً = sortOrder أصغر = يظهر أولاً)
      final orderCmp = a.sortOrder.compareTo(b.sortOrder);
      if (orderCmp != 0) return orderCmp;

      // الترتيب الزمني: إذا كان للمهمتين نفس يوم الاستحقاق وكان لأحدهما أو كلاهما وقت محدد
      if (a.dueDate != null && b.dueDate != null) {
        final sameDay = a.dueDate!.year == b.dueDate!.year &&
            a.dueDate!.month == b.dueDate!.month &&
            a.dueDate!.day == b.dueDate!.day;
        if (sameDay) {
          if (a.hasTime && b.hasTime) {
            final timeCmp = a.dueDate!.compareTo(b.dueDate!);
            if (timeCmp != 0) return timeCmp;
          } else if (a.hasTime && !b.hasTime) {
            return -1;
          } else if (!a.hasTime && b.hasTime) {
            return 1;
          }
        }
      }

      // الترتيب الثانوي: الأولوية تنازلي (الأعلى أولاً)
      final priorityCmp = b.priority.compareTo(a.priority);
      if (priorityCmp != 0) return priorityCmp;

      // الترتيب الاحتياطي الثابت: حسب معرف المهمة (Fallback) لضمان استقرار الترتيب الافتراضي
      return a.id.compareTo(b.id);
    });
});

/// Provider للمهام المؤرشفة
/// 
/// يُظهر المهام المكتملة والمهام التي تجاوزت 30 يوماً من تاريخ استحقاقها
/// مرتبة حسب تاريخ الاستحقاق (الأحدث أولاً)
final archivedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final archived = tasks.where((t) => t.isArchived).toList();
  archived.sort((a, b) {
    // المهام المكتملة قبل المؤرشفة بالتاريخ
    if (a.isDone && !b.isDone) return -1;
    if (!a.isDone && b.isDone) return 1;
    // ثم حسب تاريخ الاستحقاق (الأحدث أولاً)
    if (a.dueDate != null && b.dueDate != null) {
      return b.dueDate!.compareTo(a.dueDate!);
    }
    return 0;
  });
  return archived;
});

/// Provider لفلترة المهام
/// 
/// يحتفظ بحالة الفلترة الحالية
final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return const TaskFilter();
});

/// Provider للمهام المفلترة
/// 
/// يجمع بين قائمة المهام الأصلية والفلاتر المطبقة.
/// عند عدم وجود فلتر نشط، يُعرض فقط المهام النشطة غير المؤرشفة.
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  
  if (!filter.isActive) {
    // الوضع الافتراضي: عرض المهام النشطة فقط مرتبةً حسب sortOrder
    return ref.watch(activePendingTasksProvider);
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

/// نموذج يحتوي على إحصائيات عدديّة للمهام لتقليل عمليات التصفية المتكررة
class TaskCounts {
  final int completed;
  final int pending;
  final int archived;
  final int archivedOlderThanMonth;
  final int activePending;
  final int today;
  final int todayTotal;
  final int todayCompleted;
  final int todayPending;
  final double todayProgress;
  final int todayProgressPercent;
  final int thisWeek;
  final int overdue;
  final int priorityHigh;
  final int priorityMedium;
  final int priorityLow;
  final Map<TaskCategory, int> categoryCounts;

  const TaskCounts({
    required this.completed,
    required this.pending,
    required this.archived,
    required this.archivedOlderThanMonth,
    required this.activePending,
    required this.today,
    required this.todayTotal,
    required this.todayCompleted,
    required this.todayPending,
    required this.todayProgress,
    required this.todayProgressPercent,
    required this.thisWeek,
    required this.overdue,
    required this.priorityHigh,
    required this.priorityMedium,
    required this.priorityLow,
    required this.categoryCounts,
  });
}

/// Provider لحساب أعداد المهام وتخزينها مؤقتاً (Memoized)
/// 
/// الإحصائيات الدقيقة:
/// - completed: فقط المهام ذات isDone == true
/// - pending: المهام النشطة !isDone && !isArchived
/// - archived: جميع المهام المؤرشفة (مكتملة + تجاوزت 30 يوم)
/// - todayTotal: إجمالي المهام المجدولة لليوم (مكتملة + معلقة)
/// - todayCompleted: المهام المجدولة لليوم وتم إنجازها
/// - todayPending: المهام المجدولة لليوم وقيد التنفيذ
/// - todayProgress: نسبة إنجاز اليوم (0.0 إلى 1.0)
final taskCountsProvider = Provider<TaskCounts>((ref) {
  final tasks = ref.watch(tasksProvider);
  
  int completed = 0;    // isDone == true فقط
  int pending = 0;      // !isDone && !isArchived (نشط)
  int archived = 0;     // isArchived (مكتمل أو تجاوز 30 يوم)
  int archivedOlderThanMonth = 0; // مؤرشف بسبب التاريخ (ليس بالإنجاز)
  int activePending = 0;
  int today = 0;
  int todayTotal = 0;
  int todayCompleted = 0;
  int todayPending = 0;
  int thisWeek = 0;
  int overdue = 0;
  int priorityHigh = 0;
  int priorityMedium = 0;
  int priorityLow = 0;
  final categoryCounts = <TaskCategory, int>{};
  
  for (final c in TaskCategory.values) {
    categoryCounts[c] = 0;
  }
  
  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);
  final weekStart = todayDate.subtract(Duration(days: todayDate.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));
  
  for (final task in tasks) {
    // --- تصنيف المهمة: مكتملة / نشطة / مؤرشفة بالتاريخ ---
    if (task.isDone) {
      // مكتملة — تُحسب كمكتملة وكمؤرشفة
      completed++;
      archived++;
    } else {
      // غير مكتملة — تحقق من التأريخ التلقائي
      if (task.isArchived) {
        // مؤرشفة بسبب التاريخ (ليس بالإنجاز)
        archived++;
        archivedOlderThanMonth++;
      } else {
        // نشطة قيد التنفيذ
        pending++;
        activePending++;
      }
    }

    // --- حساب إحصائيات مهام اليوم (Today's Tasks) بدقة ---
    if (task.dueDate != null) {
      final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      if (taskDate.isAtSameMomentAs(todayDate)) {
        todayTotal++;
        if (task.isDone) {
          todayCompleted++;
        } else if (!task.isArchived) {
          todayPending++;
        }
      }
    }
    
    // --- إحصائيات الفلترة التاريخية (للمهام النشطة) ---
    if (task.dueDate != null && !task.isArchived) {
      final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      if (taskDate.isAtSameMomentAs(todayDate)) {
        today++;
      }
      if (!taskDate.isBefore(weekStart) && !taskDate.isAfter(weekEnd)) {
        thisWeek++;
      }
      if (taskDate.isBefore(todayDate) && !task.isDone) {
        overdue++;
      }
    }
    
    // --- إحصائيات الأولوية ---
    switch (task.priority) {
      case 2:
        priorityHigh++;
        break;
      case 1:
        priorityMedium++;
        break;
      case 0:
      default:
        priorityLow++;
        break;
      }
    
    // --- إحصائيات التصنيف ---
    final cat = task.safeCategory;
    categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
  }

  final todayProgress = todayTotal > 0 ? todayCompleted / todayTotal : 0.0;
  final todayProgressPercent = (todayProgress * 100).round();
  
  return TaskCounts(
    completed: completed,
    pending: pending,
    archived: archived,
    archivedOlderThanMonth: archivedOlderThanMonth,
    activePending: activePending,
    today: today,
    todayTotal: todayTotal,
    todayCompleted: todayCompleted,
    todayPending: todayPending,
    todayProgress: todayProgress,
    todayProgressPercent: todayProgressPercent,
    thisWeek: thisWeek,
    overdue: overdue,
    priorityHigh: priorityHigh,
    priorityMedium: priorityMedium,
    priorityLow: priorityLow,
    categoryCounts: categoryCounts,
  );
});

/// Provider لجميع الوسوم المستخدمة في المهام (مجمّعة وفريدة ومرتبة)
///
/// يستخلص جميع الوسوم الفريدة من كل المهام ويرتبها أبجدياً.
/// يستخدمه QuickFilters لعرض شرائح الوسوم الديناميكية.
final allTagsProvider = Provider<List<String>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final tagSet = <String>{};
  for (final task in tasks) {
    tagSet.addAll(task.tags);
  }
  final sorted = tagSet.toList()..sort();
  return sorted;
});
