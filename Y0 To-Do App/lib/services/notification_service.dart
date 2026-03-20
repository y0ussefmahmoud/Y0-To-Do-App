// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/add_edit_task_screen.dart';

/// خدمة الإشعارات المحلية
/// 
/// توفر وظائف:
/// - جدولة إشعارات للمهام
/// - إشعارات تفاعلية (إكمال/تأجيل)
/// - إدارة الإشعارات المعلقة
/// - إلغاء الإشعارات
/// 
/// يستخدم Singleton Pattern لضمان instance واحد فقط
/// يدعم الإشعارات الموقتة بدقة حسب المنطقة الزمنية
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  /// Factory constructor يرجع نفس الـ instance
  factory NotificationService() => _instance;
  
  /// Private constructor لل Singleton
  NotificationService._internal();

  /// محرك الإشعارات المحلية
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  /// هل تم تهيئة الخدمة؟
  bool _isInitialized = false;
  
  /// مفتاح للوصول إلى Navigator من أي مكان
  static GlobalKey<NavigatorState>? navigatorKey;
  
  /// Reference للوصول إلى providers
  static dynamic ref;

  /// تهيئة خدمة الإشعارات
  /// 
  /// تطلب الأذونات اللازمة وتهيئ الإعدادات
  /// 
  /// Returns: true إذا نجحت التهيئة، false إذا فشلت
  /// 
  /// مثال:
  /// ```dart
  /// final service = NotificationService();
  /// final success = await service.initialize();
  /// if (success) {
  ///   print('تم تهيئة الإشعارات بنجاح');
  /// }
  /// ```
  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    debugPrint(' بدء تهيئة خدمة الإشعارات...');

    try {
      // طلب أذونات الإشعارات مع معالجة أفضل
      debugPrint(' طلب أذونات الإشعارات...');
      final notificationPermission = await Permission.notification.request();
      if (notificationPermission.isDenied) {
        debugPrint(' تم رفض إذن الإشعارات - لن تعمل الإشعارات');
        return false;
      } else if (notificationPermission.isPermanentlyDenied) {
        debugPrint(' تم رفض إذن الإشعارات بشكل دائم - اذهب للإعدادات لتفعيله');
        return false;
      } else if (notificationPermission.isGranted) {
        debugPrint(' تم منح إذن الإشعارات بنجاح');
      }

      // تهيئة timezone مع معالجة خطأ
      debugPrint(' تهيئة timezone...');
      try {
        tz.initializeTimeZones();
        debugPrint('✅ تم تهيئة timezone بنجاح');
      } catch (e) {
        debugPrint('❌ خطأ في تهيئة timezone: $e');
        return false;
      }

      // إعدادات Android مع معالجة خطأ
      debugPrint(' تهيئة إعدادات Android...');
      AndroidInitializationSettings? androidInitializationSettings;
      try {
        androidInitializationSettings = const AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );
        debugPrint('✅ تم إعداد Android settings بنجاح');
      } catch (e) {
        debugPrint('❌ خطأ في إعدادات Android: $e');
        return false;
      }

      // إعدادات iOS مع معالجة خطأ
      debugPrint(' تهيئة إعدادات iOS...');
      DarwinInitializationSettings? darwinInitializationSettings;
      try {
        darwinInitializationSettings = const DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        debugPrint('✅ تم إعداد iOS settings بنجاح');
      } catch (e) {
        debugPrint('❌ خطأ في إعدادات iOS: $e');
        // لا نرجع false لأن iOS قد لا يكون متاحاً
      }

      // التحقق من وجود الإعدادات الأساسية
      if (androidInitializationSettings == null) {
        debugPrint('❌ فشل في تهيئة إعدادات Android الأساسية');
        return false;
      }

      // إعدادات التهيئة
      debugPrint(' تطبيق إعدادات التهيئة...');
      final initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings,
      );

      // تهيئة الـ plugin مع معالج الإشعارات
      debugPrint('📱 تهيئة Flutter Local Notifications Plugin...');
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      debugPrint('✅ تم تهيئة الـ plugin بنجاح');

      // إنشاء notification channel لـ Android مع معالجة خطأ
      debugPrint(' إنشاء notification channel...');
      try {
        const androidChannel = AndroidNotificationChannel(
          'tasks_channel',
          'إشعارات المهام',
          description: 'إشعارات للمهام القريبة من موعدها',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        );

        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);
        debugPrint('✅ تم إنشاء notification channel العادي بنجاح');
      } catch (e) {
        debugPrint('❌ خطأ في إنشاء notification channel العادي: $e');
        // نستمر بدون channel لكن قد لا تعمل الإشعارات
      }

      // إنشاء notification channel للإشعارات الدقيقة
      try {
        const exactChannel = AndroidNotificationChannel(
          'exact_tasks_channel',
          'إشعارات المهام الدقيقة',
          description: 'إشعارات تظهر في الوقت المحدد تماماً للمهام',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        );

        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(exactChannel);
        debugPrint('✅ تم إنشاء notification channel الدقيق بنجاح');
      } catch (e) {
        debugPrint('❌ خطأ في إنشاء notification channel الدقيق: $e');
        // نستمر بدون channel لكن قد لا تعمل الإشعارات الدقيقة
      }

      _isInitialized = true;
      debugPrint(' تم تهيئة خدمة الإشعارات بنجاح بالكامل');
      
      // اختبار سريع للإشعارات
      debugPrint(' إجراء اختبار سريع للإشعارات...');
      final testNotifications = await getPendingNotifications();
      debugPrint(' عدد الإشعارات المعلقة بعد التهيئة: ${testNotifications.length}');
      
      return true;
    } catch (e) {
      debugPrint('❌ خطأ عام في تهيئة الإشعارات: $e');
      debugPrint(' تفاصيل الخطأ: ${e.runtimeType}');
      return false;
    }
  }

  /// جدولة إشعار للمهمة
  /// 
  /// [task] المهمة المراد جدولة إشعار لها
  /// [notificationMinutesBefore] عدد الدقائق قبل موعد المهمة لإرسال الإشعار
  /// 
  /// يتم جدولة الإشعار قبل موعد المهمة بالوقت المحدد
  /// يتم إلغاء الإشعار إذا كانت المهمة مكتملة أو لا يوجد موعد
  /// 
  /// مثال:
  /// ```dart
  /// final task = Task(
  ///   id: '123',
  ///   title: 'اجتماع مهم',
  ///   dueDate: DateTime.now().add(Duration(hours: 2)),
  /// );
  /// await service.scheduleTaskNotification(task, 30);
  /// ```
  Future<void> scheduleTaskNotification(Task task, int notificationMinutesBefore) async {
    if (!_isInitialized) {
      debugPrint('❌ خدمة الإشعارات غير مهيأة');
      return;
    }

    if (task.dueDate == null || task.isDone) {
      debugPrint(' المهمة لا تحتوي على تاريخ استحقاق أو مكتملة: ${task.title}');
      return;
    }

    try {
      // حساب وقت الإشعار (قبل موعد المهمة بالوقت المحدد)
      final notificationTime = task.dueDate!.subtract(Duration(minutes: notificationMinutesBefore));

      debugPrint(' جدولة إشعار للمهمة: ${task.title}');
      debugPrint(' وقت الإشعار: $notificationTime');
      debugPrint(' وقت المهمة: ${task.dueDate}');
      debugPrint(' دقائق قبل: $notificationMinutesBefore');

      // التحقق من أن الوقت في المستقبل
      if (notificationTime.isBefore(DateTime.now())) {
        debugPrint(' وقت الإشعار في الماضي، سيتم تجاهله');
        return;
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint('✅ تم جدولة إشعار للمهمة: ${task.title}');
    } catch (e) {
      debugPrint('❌ خطأ في جدولة الإشعارات: $e');
    }
  }

  /// جدولة إشعار دقيق الوقت للمهمة
  /// 
  /// [task] المهمة المراد جدولة إشعار لها
  /// 
  /// يظهر الإشعار في الوقت المحدد تماماً للمهمة (لا يسبقها)
  /// مناسب للمهام ذات الأهمية العالية
  /// 
  /// مثال:
  /// ```dart
  /// final task = Task(
  ///   id: '123',
  ///   title: 'اجتماع مهم',
  ///   dueDate: DateTime.now().add(Duration(hours: 2)),
  /// );
  /// await service.scheduleExactTimeNotification(task);
  /// ```
  Future<void> scheduleExactTimeNotification(Task task) async {
    if (!_isInitialized) {
      debugPrint('❌ خدمة الإشعارات غير مهيأة');
      return;
    }

    if (task.dueDate == null || task.isDone) {
      debugPrint(' المهمة لا تحتوي على تاريخ استحقاق أو مكتملة: ${task.title}');
      return;
    }

    try {
      // استخدام الوقت المحدد تماماً للمهمة
      final notificationTime = task.dueDate!;

      debugPrint(' جدولة إشعار دقيق الوقت للمهمة: ${task.title}');
      debugPrint(' وقت الإشعار الدقيق: $notificationTime');
      debugPrint(' وقت المهمة: ${task.dueDate}');

      // التحقق من أن الوقت في المستقبل
      if (notificationTime.isBefore(DateTime.now())) {
        debugPrint(' وقت المهمة في الماضي، سيتم تجاهله');
        return;
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        task.id.hashCode + 2000, // معرف مختلف للإشعار الدقيق
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint('✅ تم جدولة إشعار دقيق الوقت للمهمة: ${task.title}');
    } catch (e) {
      debugPrint('❌ خطأ في جدولة الإشعار الدقيق: $e');
    }
  }

  /// إلغاء إشعار مهمة
  /// 
  /// [taskId] معرف المهمة المراد إلغاء إشعارها
  /// 
  /// مثال:
  /// ```dart
  /// await service.cancelTaskNotification('123');
  /// ```
  Future<void> cancelTaskNotification(String taskId) async {
    if (!_isInitialized) return;

    try {
      await _flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
      debugPrint('تم إلغاء إشعار المهمة: $taskId');
    } catch (e) {
      debugPrint('خطأ في إلغاء الإشعارات: $e');
    }
  }

  /// إلغاء جميع الإشعارات
  /// 
  /// مثال:
  /// ```dart
  /// await service.cancelAllNotifications();
  /// ```
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('تم إلغاء جميع الإشعارات');
    } catch (e) {
      debugPrint('خطأ في إلغاء جميع الإشعارات: $e');
    }
  }

  /// إشعار فوري
  /// 
  /// [title] عنوان الإشعار
  /// [body] نص الإشعار
  /// 
  /// يستخدم للاختبار أو الإشعارات العاجلة
  /// 
  /// مثال:
  /// ```dart
  /// await service.showInstantNotification('اختبار', 'هذا إشعار تجريبي');
  /// ```
  Future<void> showInstantNotification(String title, String body) async {
    debugPrint(' محاولة إرسال إشعار فوري: $title - $body');
    debugPrint(' هل الخدمة مهيأة؟ $_isInitialized');
    
    if (!_isInitialized) {
      debugPrint('❌ خدمة الإشعارات غير مهيأة، لا يمكن إرسال الإشعار');
      return;
    }

    try {
      debugPrint(' جاري إرسال الإشعار...');
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      debugPrint(' معرف الإشعار: $notificationId');
      
      await _flutterLocalNotificationsPlugin.show(
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
      
      debugPrint('✅ تم إرسال الإشعار الفوري بنجاح');
      
      // التحقق من الإشعارات المعلقة بعد الإرسال
      await Future.delayed(const Duration(seconds: 1));
      final pendingNotifications = await getPendingNotifications();
      debugPrint(' عدد الإشعارات المعلقة الآن: ${pendingNotifications.length}');
      
    } catch (e) {
      debugPrint('❌ خطأ في عرض الإشعار الفوري: $e');
      debugPrint(' تفاصيل الخطأ: ${e.runtimeType}');
    }
  }

  /// الحصول على الإشعارات المجدولة
  /// 
  /// Returns: قائمة بالإشعارات المعلقة
  /// 
  /// مثال:
  /// ```dart
  /// final notifications = await service.getPendingNotifications();
  /// print('عدد الإشعارات المعلقة: ${notifications.length}');
  /// ```
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];

    try {
      return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('خطأ في الحصول على الإشعارات المعلقة: $e');
      return [];
    }
  }

  /// معالج النقر على الإشعار
  /// 
  /// يتم استدعاؤه عندما ينقر المستخدم على الإشعار أو الأزرار التفاعلية
  Future<void> _onNotificationTapped(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload == null) return;

    debugPrint('تم النقر على إشعار المهمة: $payload');
    debugPrint('نوع الإجراء: ${response.actionId}');

    switch (response.actionId) {
      case 'complete':
        await _handleCompleteAction(payload);
        break;
      case 'snooze':
        await _handleSnoozeAction(payload);
        break;
      default:
        // النقر على الإشعار نفسه - فتح شاشة تفاصيل المهمة
        await _navigateToTaskDetail(payload);
        break;
    }
  }
  
  /// معالجة إجراء إكمال المهمة
  /// 
  /// تدعم العملية في الخلفية والforeground
  /// تستخدم Hive مباشرة لضمان العمل حتى عندما يكون ref null
  /// 
  /// [taskId] معرف المهمة المراد إكمالها
  /// 
  /// الحالات المدعومة:
  /// - Foreground: استخدام Riverpod للتحديث الفوري
  /// - Background: استخدام Hive مباشرة للتحديث المحلي
  /// - Edge Cases: المهام الملغاة/غير الموجودة
  Future<void> _handleCompleteAction(String taskId) async {
    try {
      // التحقق من صحة معرف المهمة
      if (taskId.isEmpty) {
        debugPrint('خطأ: معرف المهمة فارغ');
        return;
      }
      
      // محاولة استخدام Riverpod إذا كان متاحاً (foreground)
      if (ref != null) {
        try {
          await ref!.read(tasksProvider.notifier).toggleDone(taskId);
          debugPrint('تم إكمال المهمة عبر Riverpod: $taskId');
          return;
        } catch (riverpodError) {
          debugPrint('خطأ في Riverpod، استخدام Hive كبديل: $riverpodError');
          // الاستمرار مع Hive كخطة بديلة
        }
      }
      
      // استخدام Hive مباشرة (background support)
      if (!Hive.isBoxOpen('tasksBox')) {
        debugPrint('صندوق المهام غير مفتوح، محاولة فتحه...');
        await Hive.openBox<Task>('tasksBox');
      }
      
      final box = Hive.box<Task>('tasksBox');
      final task = box.get(taskId);
      
      if (task != null) {
        // التحقق من أن المهمة غير مكتملة بالفعل
        if (task.isDone) {
          debugPrint('المهمة مكتملة بالفعل: $taskId');
          return;
        }
        
        // تحديث حالة المهمة
        final updatedTask = task.copyWith(isDone: true);
        await box.put(taskId, updatedTask);
        debugPrint('تم إكمال المهمة عبر Hive: $taskId');
        
        // محاولة تحديث providers إذا كان التطبيق في foreground
        if (ref != null) {
          try {
            await ref!.read(tasksProvider.notifier).refresh();
            debugPrint('تم تحديث providers بنجاح');
          } catch (e) {
            debugPrint('لا يمكن تحديث providers: $e');
          }
        }
      } else {
        debugPrint('المهمة غير موجودة: $taskId');
      }
    } catch (e) {
      debugPrint('خطأ غير متوقع في إكمال المهمة: $e');
    }
  }
  
  /// معالجة إجراء تأجيل المهمة
  /// 
  /// يقوم بتأجيل الإشعار لمدة 15 دقيقة
  /// لا يغير حالة المهمة نفسها، فقط يؤجل التذكير
  /// 
  /// [taskId] معرف المهمة المراد تأجيل إشعارها
  Future<void> _handleSnoozeAction(String taskId) async {
    try {
      // التحقق من صحة معرف المهمة
      if (taskId.isEmpty) {
        debugPrint('خطأ: معرف المهمة فارغ للتأجيل');
        return;
      }
      
      await _snoozeNotification(taskId);
      debugPrint('تم تأجيل إشعار المهمة: $taskId');
    } catch (e) {
      debugPrint('خطأ في تأجيل المهمة: $e');
    }
  }
  
  /// التنقل إلى شاشة تفاصيل المهمة
  /// 
  /// تدعم التنقل في foreground وحفظ المعرف للتنقل عند فتح التطبيق
  /// 
  /// [taskId] معرف المهمة المراد عرض تفاصيلها
  /// 
  /// الحالات المدعومة:
  /// - Foreground مع context متاح: تنقل فوري إلى شاشة التفاصيل
  /// - Background أو app مغلق: حفظ المعرف في shared preferences
  /// - Mix: استخدام Hive مباشرة إذا كان ref غير متاح
  Future<void> _navigateToTaskDetail(String taskId) async {
    try {
      // التحقق من صحة معرف المهمة
      if (taskId.isEmpty) {
        debugPrint('خطأ: معرف المهمة فارغ للتنقل');
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
            debugPrint('خطأ في جلب المهمة عبر Riverpod، استخدام Hive: $e');
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
            debugPrint('خطأ في جلب المهمة عبر Hive: $e');
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
            debugPrint('تم التنقل الفوري إلى تفاصيل المهمة: $taskId');
            return;
          }
        } else {
          debugPrint('لم يتم العثور على المهمة: $taskId');
        }
      } else {
        debugPrint('لا يوجد context متاح، التطبيق可能在后台');
      }
      
      // إذا لم يكن هناك context أو التطبيق مغلق، حفظ المعرف في shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_task_navigation', taskId);
      debugPrint('تم حفظ معرف المهمة للتنقل عند فتح التطبيق: $taskId');
      
    } catch (e) {
      debugPrint('خطأ غير متوقع في التنقل إلى تفاصيل المهمة: $e');
      
      // محاولة حفظ المعرف كخطة احتياطية
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_task_navigation', taskId);
        debugPrint('تم حفظ المعرف كخطة احتياطية: $taskId');
      } catch (prefsError) {
        debugPrint('فشل في حفظ المعرف في shared preferences: $prefsError');
      }
    }
  }
  
  
  /// تأجيل الإشعار لـ 15 دقيقة
  /// 
  /// [taskId] معرف المهمة
  Future<void> _snoozeNotification(String taskId) async {
    try {
      final snoozeTime = DateTime.now().add(const Duration(minutes: 15));
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        taskId.hashCode + 1000, // معرف مختلف للإشعار المؤجل
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: taskId,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint('تم تأجيل الإشعار لـ 15 دقيقة');
    } catch (e) {
      debugPrint('خطأ في تأجيل الإشعار: $e');
    }
  }

  /// تعيين مفتاح Navigator للوصول إلى context
  /// 
  /// يجب استدعاؤها في main.dart قبل تشغيل التطبيق
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }
  
  /// التحقق من وجود تنقل معلق ومعالجته
  /// 
  /// يتم استدعاؤها عند بدء التطبيق للتحقق من وجود مهمة محفوظة للتنقل
  /// من إشعار تم النقر عليه عندما كان التطبيق مغلقاً
  /// 
  /// العملية:
  /// 1. التحقق من وجود معرف مهمة محفوظ في shared preferences
  /// 2. حذف المعرف المحفوظ لتجنب التكرار
  /// 3. الانتظار لضمان تهيئة التطبيق بالكامل
  /// 4. البحث عن المهمة في Hive box
  /// 5. التنقل إلى شاشة التفاصيل إذا وجدت المهمة
  /// 
  /// ملاحظة: يجب استدعاؤها بعد تهيئة Hive و navigatorKey
  Future<void> checkPendingNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingTaskId = prefs.getString('pending_task_navigation');
      
      if (pendingTaskId != null && pendingTaskId.isNotEmpty) {
        debugPrint('تم العثور على تنقل معلق للمهمة: $pendingTaskId');
        
        // حذف المعرف المحفوظ فوراً لتجنب التكرار
        await prefs.remove('pending_task_navigation');
        
        // الانتظار قليلاً لضمان تهيئة التطبيق بالكامل
        await Future.delayed(const Duration(milliseconds: 500));
        
        // التحقق من توفر navigatorKey و context
        if (navigatorKey?.currentContext != null) {
          final context = navigatorKey!.currentContext!;
          
          // التأكد من أن صندوق المهام مفتوح
          if (!Hive.isBoxOpen('tasksBox')) {
            debugPrint('صندوق المهام غير مفتوح، محاولة فتحه...');
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
              debugPrint('تم التنقل بنجاح إلى تفاصيل المهمة المحفوظة: $pendingTaskId');
            } else {
              debugPrint('Context لم يعد صالحاً، إعادة حفظ المعرف');
              await prefs.setString('pending_task_navigation', pendingTaskId);
            }
          } else {
            debugPrint('المهمة المحفوظة غير موجودة: $pendingTaskId');
          }
        } else {
          debugPrint('NavigatorKey أو context غير متاحين، إعادة حفظ المعرف');
          await prefs.setString('pending_task_navigation', pendingTaskId);
        }
      }
    } catch (e) {
      debugPrint('خطأ في التحقق من التنقل المعلق: $e');
    }
  }
  
  /// تعيين Reference للوصول إلى providers
  /// 
  /// يجب استدعاؤها بعد تهيئة ProviderScope
  void setRef(dynamic providerRef) {
    ref = providerRef;
  }
}
