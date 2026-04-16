import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';
import '../utils/error_handler.dart';

/// مجدول الإشعارات
/// 
/// مسؤول عن جدولة وإلغاء الإشعارات فقط
/// يفصل منطق الجدولة عن معالجة الإجراءات والتنقل
class NotificationScheduler {
  /// محرك الإشعارات المحلية
  final FlutterLocalNotificationsPlugin _plugin;

  /// هل تم تهيئة المجدول؟
  bool _isInitialized = false;

  NotificationScheduler(this._plugin);

  /// تهيئة المجدول
  void initialize() {
    _isInitialized = true;
    ErrorHandler.logInfo('NotificationScheduler initialized');
  }

  /// جدولة إشعار للمهمة
  /// 
  /// [task] المهمة المراد جدولة إشعار لها
  /// [notificationMinutesBefore] عدد الدقائق قبل موعد المهمة
  Future<void> scheduleTaskNotification(Task task, int notificationMinutesBefore) async {
    if (!_isInitialized) {
      ErrorHandler.logWarning('NotificationScheduler not initialized');
      return;
    }

    if (task.dueDate == null || task.isDone) {
      ErrorHandler.logInfo('Task has no due date or is completed: ${task.title}');
      return;
    }

    try {
      final notificationTime = task.dueDate!.subtract(Duration(minutes: notificationMinutesBefore));

      ErrorHandler.logInfo('Scheduling notification for task: ${task.title}');
      ErrorHandler.logDebug('Notification time: $notificationTime');
      ErrorHandler.logDebug('Task time: ${task.dueDate}');
      ErrorHandler.logDebug('Minutes before: $notificationMinutesBefore');

      if (notificationTime.isBefore(DateTime.now())) {
        ErrorHandler.logWarning('Notification time is in the past, skipping');
        return;
      }

      await _plugin.zonedSchedule(
        task.id.hashCode,
        'تذكير بمهمة',
        task.title,
        tz.TZDateTime.from(notificationTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tasks_channel',
            'إشعارات المهام',
            channelDescription: 'إشعارات للمهام القريبة من موعدها',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            icon: null,
            actions: [
              AndroidNotificationAction(
                'complete',
                'إكمال',
                titleColor: Color(0xFF06D6A0),
              ),
              AndroidNotificationAction(
                'snooze',
                'تأجيل',
                titleColor: Color(0xFF6366F1),
              ),
            ],
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            categoryIdentifier: 'tasks_category',
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      ErrorHandler.logSuccess('Notification scheduled for task: ${task.title}');
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationScheduler.scheduleTaskNotification');
    }
  }

  /// جدولة إشعار دقيق الوقت للمهمة
  /// 
  /// [task] المهمة المراد جدولة إشعار لها
  Future<void> scheduleExactTimeNotification(Task task) async {
    if (!_isInitialized) {
      ErrorHandler.logWarning('NotificationScheduler not initialized');
      return;
    }

    if (task.dueDate == null || task.isDone) {
      ErrorHandler.logInfo('Task has no due date or is completed: ${task.title}');
      return;
    }

    try {
      final notificationTime = task.dueDate!;

      ErrorHandler.logInfo('Scheduling exact time notification for task: ${task.title}');
      ErrorHandler.logDebug('Exact notification time: $notificationTime');

      if (notificationTime.isBefore(DateTime.now())) {
        ErrorHandler.logWarning('Task time is in the past, skipping');
        return;
      }

      await _plugin.zonedSchedule(
        task.id.hashCode + 2000,
        'مهمة مستحقة الآن',
        task.title,
        tz.TZDateTime.from(notificationTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'exact_tasks_channel',
            'إشعارات المهام الدقيقة',
            channelDescription: 'إشعارات تظهر في الوقت المحدد تماماً للمهام',
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            playSound: true,
            icon: null,
            actions: [
              AndroidNotificationAction(
                'complete',
                'إكمال',
                titleColor: Color(0xFF06D6A0),
              ),
              AndroidNotificationAction(
                'snooze',
                'تأجيل',
                titleColor: Color(0xFF6366F1),
              ),
            ],
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            categoryIdentifier: 'exact_tasks_category',
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      ErrorHandler.logSuccess('Exact time notification scheduled for task: ${task.title}');
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationScheduler.scheduleExactTimeNotification');
    }
  }

  /// إلغاء إشعار مهمة
  /// 
  /// [taskId] معرف المهمة المراد إلغاء إشعارها
  Future<void> cancelTaskNotification(String taskId) async {
    if (!_isInitialized) return;

    try {
      await _plugin.cancel(taskId.hashCode);
      await _plugin.cancel(taskId.hashCode + 2000); // Cancel exact notification too
      ErrorHandler.logSuccess('Notification cancelled for task: $taskId');
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationScheduler.cancelTaskNotification');
    }
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    try {
      await _plugin.cancelAll();
      ErrorHandler.logSuccess('All notifications cancelled');
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationScheduler.cancelAllNotifications');
    }
  }

  /// إشعار فوري
  /// 
  /// [title] عنوان الإشعار
  /// [body] نص الإشعار
  Future<void> showInstantNotification(String title, String body) async {
    if (!_isInitialized) {
      ErrorHandler.logWarning('NotificationScheduler not initialized');
      return;
    }

    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      
      await _plugin.show(
        notificationId,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tasks_channel',
            'إشعارات المهام',
            channelDescription: 'إشعارات للمهام القريبة من موعدها',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            icon: null,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      ErrorHandler.logSuccess('Instant notification sent: $title');
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationScheduler.showInstantNotification');
    }
  }

  /// تأجيل الإشعار لـ 15 دقيقة
  /// 
  /// [taskId] معرف المهمة
  Future<void> snoozeNotification(String taskId) async {
    if (!_isInitialized) return;

    try {
      final snoozeTime = DateTime.now().add(const Duration(minutes: 15));
      
      await _plugin.zonedSchedule(
        taskId.hashCode + 1000,
        'تذكير مؤجل',
        'تم تأجيل هذا الإشعار لـ 15 دقيقة',
        tz.TZDateTime.from(snoozeTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tasks_channel',
            'إشعارات المهام',
            channelDescription: 'إشعارات للمهام القريبة من موعدها',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            icon: null,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: taskId,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      ErrorHandler.logSuccess('Notification snoozed for task: $taskId');
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationScheduler.snoozeNotification');
    }
  }

  /// الحصول على الإشعارات المجدولة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];

    try {
      return await _plugin.pendingNotificationRequests();
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationScheduler.getPendingNotifications');
      return [];
    }
  }
}
