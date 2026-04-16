import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';
import 'notification_scheduler.dart';
import 'notification_handler.dart';
import 'notification_initializer.dart';

/// خدمة الإشعارات المحلية (المُعاد هيكلتها)
/// 
/// الآن تستخدم بنية معيارية (Facade Pattern):
/// - NotificationInitializer: للتهيئة
/// - NotificationScheduler: للجدولة والإلغاء
/// - NotificationHandler: لمعالجة الإجراءات والتنقل
/// 
/// هذا يقلل حجم الملف من 818 سطر إلى ~150 سطر
/// ويحسن قابلية الصيانة والاختبار
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() => _instance;
  
  NotificationService._internal() {
    _initializeComponents();
  }

  /// محرك الإشعارات المحلية
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  
  /// مُهيئ الإشعارات
  late final NotificationInitializer _initializer;
  
  /// مجدول الإشعارات
  late final NotificationScheduler _scheduler;
  
  /// معالج إجراءات الإشعارات
  late final NotificationHandler _handler;

  /// تهيئة الخدمة وكل مكوناتها
  void _initializeComponents() {
    _initializer = NotificationInitializer(_plugin, onNotificationTap: onNotificationTapped);
    _scheduler = NotificationScheduler(_plugin);
    _handler = NotificationHandler();
  }

  /// تهيئة خدمة الإشعارات
  /// 
  /// Returns: true إذا نجحت التهيئة، false إذا فشلت
  Future<bool> initialize() async {
    final success = await _initializer.initialize();
    if (success) {
      _scheduler.initialize();
    }
    
    return success;
  }

  /// جدولة إشعار للمهمة
  Future<void> scheduleTaskNotification(Task task, int notificationMinutesBefore) async {
    await _scheduler.scheduleTaskNotification(task, notificationMinutesBefore);
  }

  /// جدولة إشعار دقيق الوقت للمهمة
  Future<void> scheduleExactTimeNotification(Task task) async {
    await _scheduler.scheduleExactTimeNotification(task);
  }

  /// إلغاء إشعار مهمة
  Future<void> cancelTaskNotification(String taskId) async {
    await _scheduler.cancelTaskNotification(taskId);
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    await _scheduler.cancelAllNotifications();
  }

  /// إشعار فوري
  Future<void> showInstantNotification(String title, String body) async {
    await _scheduler.showInstantNotification(title, body);
  }

  /// الحصول على الإشعارات المجدولة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _scheduler.getPendingNotifications();
  }

  /// تأجيل الإشعار لـ 15 دقيقة
  Future<void> snoozeNotification(String taskId) async {
    await _scheduler.snoozeNotification(taskId);
  }

  /// تعيين مفتاح Navigator للوصول إلى context
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _handler.setNavigatorKey(key);
  }

  /// تعيين Reference للوصول إلى providers
  void setRef(dynamic providerRef) {
    _handler.setRef(providerRef);
  }

  /// التحقق من وجود تنقل معلق ومعالجته
  Future<void> checkPendingNavigation() async {
    await _handler.checkPendingNavigation();
  }

  /// معالج النقر على الإشعار
  /// 
  /// يتم استدعاؤه عند تهيئة الـ plugin
  void onNotificationTapped(NotificationResponse response) {
    _handler.handleNotificationTap(response);
  }
}
