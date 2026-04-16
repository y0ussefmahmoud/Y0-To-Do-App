import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../utils/error_handler.dart';

/// مُهيئ الإشعارات
/// 
/// مسؤول عن تهيئة خدمة الإشعارات وإنشاء القنوات
/// يفصل منطق التهيئة عن منطق الجدولة والمعالجة
class NotificationInitializer {
  /// محرك الإشعارات المحلية
  final FlutterLocalNotificationsPlugin _plugin;

  /// هل تم تهيئة المُهيئ؟
  bool _isInitialized = false;

  /// معالج النقر على الإشعارات
  final Function(NotificationResponse)? onNotificationTap;

  NotificationInitializer(this._plugin, {this.onNotificationTap});

  /// تهيئة خدمة الإشعارات
  /// 
  /// تطلب الأذونات اللازمة وتهيئ الإعدادات
  /// 
  /// Returns: true إذا نجحت التهيئة، false إذا فشلت
  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    ErrorHandler.logInfo('Starting notification service initialization...');

    try {
      // طلب أذونات الإشعارات
      ErrorHandler.logInfo('Requesting notification permissions...');
      final notificationPermission = await Permission.notification.request();
      if (notificationPermission.isDenied) {
        ErrorHandler.logWarning('Notification permission denied - notifications will not work');
        return false;
      } else if (notificationPermission.isPermanentlyDenied) {
        ErrorHandler.logWarning('Notification permission permanently denied - go to settings to enable');
        return false;
      } else if (notificationPermission.isGranted) {
        ErrorHandler.logSuccess('Notification permission granted successfully');
      }

      // تهيئة timezone
      ErrorHandler.logInfo('Initializing timezone...');
      try {
        tz.initializeTimeZones();
        ErrorHandler.logSuccess('Timezone initialized successfully');
      } catch (e) {
        ErrorHandler.handleError(e, null, context: 'NotificationInitializer.timezone');
        return false;
      }

      // إعدادات Android
      ErrorHandler.logInfo('Initializing Android settings...');
      AndroidInitializationSettings? androidInitializationSettings;
      try {
        androidInitializationSettings = const AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );
        ErrorHandler.logSuccess('Android settings configured successfully');
      } catch (e) {
        ErrorHandler.handleError(e, null, context: 'NotificationInitializer.androidSettings');
        return false;
      }

      // إعدادات iOS
      ErrorHandler.logInfo('Initializing iOS settings...');
      DarwinInitializationSettings? darwinInitializationSettings;
      try {
        darwinInitializationSettings = const DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        ErrorHandler.logSuccess('iOS settings configured successfully');
      } catch (e) {
        ErrorHandler.handleError(e, null, context: 'NotificationInitializer.iosSettings');
      }

      // إعدادات التهيئة
      ErrorHandler.logInfo('Applying initialization settings...');
      final initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings,
      );

      // تهيئة الـ plugin
      ErrorHandler.logInfo('Initializing Flutter Local Notifications Plugin...');
      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap ?? (response) {
          ErrorHandler.logInfo('Notification received: ${response.payload}');
        },
      );
      ErrorHandler.logSuccess('Plugin initialized successfully');

      // إنشاء notification channel لـ Android
      await _createNotificationChannel();
      
      // إنشاء notification channel للإشعارات الدقيقة
      await _createExactNotificationChannel();

      _isInitialized = true;
      ErrorHandler.logSuccess('Notification service initialized completely');
      
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationInitializer.initialize');
      return false;
    }
  }

  /// إنشاء notification channel العادي
  Future<void> _createNotificationChannel() async {
    try {
      const androidChannel = AndroidNotificationChannel(
        'tasks_channel',
        'إشعارات المهام',
        description: 'إشعارات للمهام القريبة من موعدها',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
      ErrorHandler.logSuccess('Regular notification channel created successfully');
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationInitializer._createNotificationChannel');
      // نستمر بدون channel لكن قد لا تعمل الإشعارات
    }
  }

  /// إنشاء notification channel للإشعارات الدقيقة
  Future<void> _createExactNotificationChannel() async {
    try {
      const exactChannel = AndroidNotificationChannel(
        'exact_tasks_channel',
        'إشعارات المهام الدقيقة',
        description: 'إشعارات تظهر في الوقت المحدد تماماً للمهام',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(exactChannel);
      ErrorHandler.logSuccess('Exact notification channel created successfully');
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'NotificationInitializer._createExactNotificationChannel');
      // نستمر بدون channel لكن قد لا تعمل الإشعارات الدقيقة
    }
  }

  /// التحقق مما إذا تم تهيئة المُهيئ
  bool get isInitialized => _isInitialized;
}
