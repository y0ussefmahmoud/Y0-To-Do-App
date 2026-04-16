import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/add_edit_task_screen.dart';
import '../utils/error_handler.dart';

/// معالج إجراءات الإشعارات
/// 
/// مسؤول عن معالجة إجراءات الإشعارات (إكمال، تأجيل، التنقل)
/// يفصل منطق المعالجة عن منطق الجدولة
class NotificationHandler {
  /// Reference للوصول إلى providers
  static dynamic ref;

  /// مفتاح للوصول إلى Navigator
  static GlobalKey<NavigatorState>? navigatorKey;

  /// تعيين Reference للوصول إلى providers
  void setRef(dynamic providerRef) {
    ref = providerRef;
  }

  /// تعيين مفتاح Navigator للوصول إلى context
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  /// معالج النقر على الإشعار
  /// 
  /// يتم استدعاؤه عندما ينقر المستخدم على الإشعار أو الأزرار التفاعلية
  Future<void> handleNotificationTap(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload == null) return;

    ErrorHandler.logInfo('Notification tapped: $payload');
    ErrorHandler.logDebug('Action type: ${response.actionId}');

    switch (response.actionId) {
      case 'complete':
        await handleCompleteAction(payload);
        break;
      case 'snooze':
        await handleSnoozeAction(payload);
        break;
      default:
        // النقر على الإشعار نفسه - فتح شاشة تفاصيل المهمة
        await navigateToTaskDetail(payload);
        break;
    }
  }

  /// معالجة إجراء إكمال المهمة
  /// 
  /// تدعم العملية في الخلفية والforeground
  /// تستخدم Hive مباشرة لضمان العمل حتى عندما يكون ref null
  /// 
  /// [taskId] معرف المهمة المراد إكمالها
  Future<void> handleCompleteAction(String taskId) async {
    try {
      // التحقق من صحة معرف المهمة
      if (taskId.isEmpty) {
        ErrorHandler.logWarning('Task ID is empty for completion');
        return;
      }
      
      // محاولة استخدام Riverpod إذا كان متاحاً (foreground)
      if (ref != null) {
        try {
          await ref!.read(tasksProvider.notifier).toggleDone(taskId);
          ErrorHandler.logSuccess('Task completed via Riverpod: $taskId');
          return;
        } catch (riverpodError) {
          ErrorHandler.handleError(riverpodError, null, context: 'NotificationHandler.handleCompleteAction.riverpod');
          // الاستمرار مع Hive كخطة بديلة
        }
      }
      
      // استخدام Hive مباشرة (background support)
      if (!Hive.isBoxOpen('tasksBox')) {
        ErrorHandler.logInfo('Tasks box not open, attempting to open...');
        await Hive.openBox<Task>('tasksBox');
      }
      
      final box = Hive.box<Task>('tasksBox');
      final task = box.get(taskId);
      
      if (task != null) {
        // التحقق من أن المهمة غير مكتملة بالفعل
        if (task.isDone) {
          ErrorHandler.logInfo('Task already completed: $taskId');
          return;
        }
        
        // تحديث حالة المهمة
        final updatedTask = task.copyWith(isDone: true);
        await box.put(taskId, updatedTask);
        ErrorHandler.logSuccess('Task completed via Hive: $taskId');
        
        // محاولة تحديث providers إذا كان التطبيق في foreground
        if (ref != null) {
          try {
            await ref!.read(tasksProvider.notifier).refresh();
            ErrorHandler.logSuccess('Providers updated successfully');
          } catch (e) {
            ErrorHandler.handleError(e, null, context: 'NotificationHandler.handleCompleteAction.refresh');
          }
        }
      } else {
        ErrorHandler.logWarning('Task not found: $taskId');
      }
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationHandler.handleCompleteAction');
    }
  }

  /// معالجة إجراء تأجيل المهمة
  /// 
  /// يقوم بتأجيل الإشعار لمدة 15 دقيقة
  /// لا يغير حالة المهمة نفسها، فقط يؤجل التذكير
  /// 
  /// [taskId] معرف المهمة المراد تأجيل إشعارها
  Future<void> handleSnoozeAction(String taskId) async {
    try {
      // التحقق من صحة معرف المهمة
      if (taskId.isEmpty) {
        ErrorHandler.logWarning('Task ID is empty for snooze');
        return;
      }
      
      // سيتم التعامل مع التأجيل في NotificationScheduler
      ErrorHandler.logInfo('Task snoozed: $taskId');
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationHandler.handleSnoozeAction');
    }
  }

  /// التنقل إلى شاشة تفاصيل المهمة
  /// 
  /// تدعم التنقل في foreground وحفظ المعرف للتنقل عند فتح التطبيق
  /// 
  /// [taskId] معرف المهمة المراد عرض تفاصيلها
  Future<void> navigateToTaskDetail(String taskId) async {
    try {
      // التحقق من صحة معرف المهمة
      if (taskId.isEmpty) {
        ErrorHandler.logWarning('Task ID is empty for navigation');
        return;
      }
      
      // التحقق من وجود context للتنقل الفوري (foreground)
      if (navigatorKey?.currentContext != null) {
        final context = navigatorKey!.currentContext!;
        
        Task? task;
        
        // البحث عن المهمة في قائمة المهام عبر Riverpod
        if (ref != null) {
          try {
            final tasks = ref!.read(tasksProvider);
            task = tasks.where((t) => t.id == taskId).firstOrNull;
          } catch (e) {
            ErrorHandler.handleError(e, null, context: 'NotificationHandler.navigateToTaskDetail.riverpod');
          }
        }
        
        // إذا لم يتم العثور على المهمة، استخدام Hive مباشرة
        if (task == null) {
          try {
            if (!Hive.isBoxOpen('tasksBox')) {
              await Hive.openBox<Task>('tasksBox');
            }
            final box = Hive.box<Task>('tasksBox');
            task = box.get(taskId);
          } catch (e) {
            ErrorHandler.handleError(e, null, context: 'NotificationHandler.navigateToTaskDetail.hive');
          }
        }
        
        // تنقل إلى شاشة التفاصيل إذا تم العثور على المهمة
        if (task != null) {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditTaskScreen(task: task),
              ),
            );
            ErrorHandler.logSuccess('Navigated to task detail: $taskId');
            return;
          }
        } else {
          ErrorHandler.logWarning('Task not found: $taskId');
        }
      } else {
        ErrorHandler.logInfo('No context available, app might be in background');
      }
      
      // إذا لم يكن هناك context أو التطبيق مغلق، حفظ المعرف في shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_task_navigation', taskId);
      ErrorHandler.logSuccess('Task ID saved for navigation on app open: $taskId');
      
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationHandler.navigateToTaskDetail');
      
      // محاولة حفظ المعرف كخطة احتياطية
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_task_navigation', taskId);
        ErrorHandler.logSuccess('Task ID saved as fallback: $taskId');
      } catch (prefsError) {
        ErrorHandler.handleError(prefsError, null, context: 'NotificationHandler.navigateToTaskDetail.fallback');
      }
    }
  }

  /// التحقق من وجود تنقل معلق ومعالجته
  /// 
  /// يتم استدعاؤه عند بدء التطبيق للتحقق من وجود مهمة محفوظة للتنقل
  Future<void> checkPendingNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingTaskId = prefs.getString('pending_task_navigation');
      
      if (pendingTaskId != null && pendingTaskId.isNotEmpty) {
        ErrorHandler.logInfo('Found pending navigation for task: $pendingTaskId');
        
        // حذف المعرف المحفوظ فوراً لتجنب التكرار
        await prefs.remove('pending_task_navigation');
        
        // الانتظار قليلاً لضمان تهيئة التطبيق بالكامل
        await Future.delayed(const Duration(milliseconds: 500));
        
        // التحقق من توفر navigatorKey و context
        if (navigatorKey?.currentContext != null) {
          final context = navigatorKey!.currentContext!;
          
          // التأكد من أن صندوق المهام مفتوح
          if (!Hive.isBoxOpen('tasksBox')) {
            ErrorHandler.logInfo('Tasks box not open, attempting to open...');
            await Hive.openBox<Task>('tasksBox');
          }
          
          // البحث عن المهمة
          final box = Hive.box<Task>('tasksBox');
          final task = box.get(pendingTaskId);
          
          if (task != null) {
            // التحقق من أن context لا يزال صالحاً
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditTaskScreen(task: task),
                ),
              );
              ErrorHandler.logSuccess('Navigated to pending task: $pendingTaskId');
            } else {
              ErrorHandler.logWarning('Context no longer valid, resaving task ID');
              await prefs.setString('pending_task_navigation', pendingTaskId);
            }
          } else {
            ErrorHandler.logWarning('Pending task not found: $pendingTaskId');
          }
        } else {
          ErrorHandler.logWarning('NavigatorKey or context not available, resaving task ID');
          await prefs.setString('pending_task_navigation', pendingTaskId);
        }
      }
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationHandler.checkPendingNavigation');
    }
  }
}
