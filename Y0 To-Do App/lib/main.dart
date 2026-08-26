// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

// ignore_for_file: unused_local_variable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'l10n/app_localizations.dart';
import 'models/task.dart';
import 'models/task_category.dart';
import 'models/search_history.dart';
import 'models/app_settings.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';
import 'providers/settings_provider.dart';
import 'services/encryption_service.dart';
import 'services/notification_service.dart';
import 'utils/error_handler.dart';
import 'widgets/error_boundary.dart';
import 'theme/y0_design_system.dart';

/// Global navigator key for navigation throughout the app
/// Used by both MaterialApp and NotificationService
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// نقطة الدخول الرئيسية للتطبيق
/// 
/// تقوم بـ:
/// 1. تهيئة Flutter bindings
/// 2. تهيئة معالج الأخطاء
/// 3. تهيئة خدمة الإشعارات
/// 4. تهيئة Hive لقاعدة البيانات المحلية مع التشفير AES-256
/// 5. تسجيل محولات Hive
/// 6. فتح صناديق Hive المشفرة + ترحيل البيانات القديمة بأمان تام
/// 7. تشغيل التطبيق مع ErrorBoundary
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');

  // تهيئة معالج الأخطاء أولاً
  ErrorHandler.initialize();
  ErrorHandler.logInfo('Starting Y0 To-Do App v3.3.0 initialization');

  try {
    // ── 1. تهيئة Hive ──────────────────────────────────────────────────────
    try {
      ErrorHandler.logInfo('Initializing Hive...');
      await Hive.initFlutter();
      ErrorHandler.logSuccess('Hive initialized');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to initialize Hive');
      await Future.delayed(const Duration(milliseconds: 100));
      await Hive.initFlutter();
      ErrorHandler.logSuccess('Alternative Hive initialization successful');
    }
    
    // ── 2. تسجيل المحوّلات ─────────────────────────────────────────────────
    try {
      ErrorHandler.logInfo('Checking TaskCategoryAdapter registration...');
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(TaskCategoryAdapter());
        ErrorHandler.logInfo('TaskCategoryAdapter registered successfully.');
      }

      ErrorHandler.logInfo('Checking TaskAdapter registration...');
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(TaskAdapter());
        ErrorHandler.logInfo('TaskAdapter registered successfully.');
      }

      ErrorHandler.logInfo('Checking SearchHistoryAdapter registration...');
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(SearchHistoryAdapter());
        ErrorHandler.logInfo('SearchHistoryAdapter registered successfully.');
      }

      ErrorHandler.logInfo('Checking AppSettingsAdapter registration...');
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(AppSettingsAdapter());
        ErrorHandler.logInfo('AppSettingsAdapter registered successfully.');
      }

      ErrorHandler.logSuccess('All Hive adapters processed.');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to register Hive adapters');
      rethrow;
    }

    // ── 3. الحصول على مفتاح التشفير AES-256 ────────────────────────────────
    ErrorHandler.logInfo('Retrieving AES-256 cipher from EncryptionService...');
    final cipher = await EncryptionService.getCipher();
    ErrorHandler.logSuccess('AES-256 cipher ready');

    // ── 4. فتح الصناديق مع التشفير والترحيل الآمن ──────────────────────────
    Box<Task>? tasksBox;
    Box<SearchHistory>? searchHistoryBox;
    Box<AppSettings>? settingsBox;
    
    // ── 4a. tasksBox ────────────────────────────────────────────────────────
    try {
      ErrorHandler.logInfo('Opening tasksBox...');
      tasksBox = await _openBoxSafely<Task>('tasksBox', cipher);
      ErrorHandler.logSuccess('tasksBox opened successfully (${tasksBox.length} records)');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to open tasksBox');
      rethrow;
    }

    // ── 4b. searchHistoryBox ────────────────────────────────────────────────
    try {
      ErrorHandler.logInfo('Opening searchHistoryBox...');
      searchHistoryBox = await _openBoxSafely<SearchHistory>('searchHistoryBox', cipher);
      ErrorHandler.logSuccess('searchHistoryBox opened successfully');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to open searchHistoryBox');
      // Continue without search history — not critical
    }

    // ── 4c. settingsBox ─────────────────────────────────────────────────────
    try {
      ErrorHandler.logInfo('Opening settingsBox...');
      settingsBox = await _openBoxSafely<AppSettings>('settingsBox', cipher);

      // Migration: Check and validate settings fields
      if (settingsBox.isNotEmpty) {
        try {
          final oldSettings = settingsBox.getAt(0);
          if (oldSettings != null) {
            // Re-hydrate via fromMap to apply null-safe defaults for any new fields
            final migrated = AppSettings.fromMap(oldSettings.toMap());
            await settingsBox.putAt(0, migrated);
            ErrorHandler.logSuccess('settingsBox validated and up to date');
          }
        } catch (settingsError) {
          ErrorHandler.logWarning('settingsBox read warning: $settingsError');
        }
      }
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to open settingsBox');
      rethrow;
    }

    // ── 5. إشعارات ─────────────────────────────────────────────────────────
    try {
      final notificationService = NotificationService();
      await notificationService.checkPendingNavigation();
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to check pending navigation');
    }

    ErrorHandler.logSuccess('App initialization completed successfully');

    runApp(ProviderScope(
      overrides: [
        settingsBoxProvider.overrideWithValue(
          Hive.box<AppSettings>('settingsBox'),
        ),
      ],
      child: AppInitializer(),
    ));
  } catch (e, stackTrace) {
    ErrorHandler.handleError(e, stackTrace, context: 'App initialization');
    
    runApp(
      MaterialApp(
        home: ErrorView(
          error: e,
          stackTrace: stackTrace,
          customMessage:
              'فشل في تهيئة التطبيق: ${e.toString()}. يرجى إعادة تشغيل التطبيق.',
        ),
      ),
    );
  }
}

/// فتح صندوق Hive مع حماية وترحيل آمن بنسبة 100% للبيانات القديمة
///
/// الخطوات:
/// 1. محاولة فتح الصندوق المشفر (الوضع الطبيعي بعد التحديث).
/// 2. إذا فشل، محاولة فتح الصندوق غير المشفر (بيانات قديمة من الإصدار السابق).
/// 3. قراءة البيانات بالكامل في الذاكرة (In-Memory Backup).
/// 4. فقط بعد التأكد من حفظ البيانات في الذاكرة، يتم ترحيلها إلى الصندوق المشفر الجديد.
/// 5. في حال حدوث أي خطأ، لا يتم مسح الملفات بل يتم الرجوع لفتح الصندوق غير المشفر كخيار أمان.
Future<Box<T>> _openBoxSafely<T>(
    String boxName, HiveAesCipher cipher) async {
  // إذا كان الصندوق مفتوحاً بالفعل
  if (Hive.isBoxOpen(boxName)) {
    return Hive.box<T>(boxName);
  }

  // 1. المحاولة الأولى: فتح الصندوق المشفر
  try {
    return await Hive.openBox<T>(boxName, encryptionCipher: cipher);
  } catch (encryptedError) {
    ErrorHandler.logWarning(
        '$boxName: Encrypted open failed ($encryptedError). Attempting unencrypted read/migration...');
  }

  // إغلاق أي جلسة معلقة
  try {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  } catch (_) {}

  // 2. المحاولة الثانية: قراءة البيانات القديمة غير المشفرة بأمان
  Map<dynamic, dynamic>? inMemoryBackup;
  try {
    final legacyBox = await Hive.openBox<T>(boxName);
    inMemoryBackup = Map<dynamic, dynamic>.from(legacyBox.toMap());
    await legacyBox.close();
    ErrorHandler.logInfo(
        '$boxName: Successfully read ${inMemoryBackup.length} legacy records into memory.');
  } catch (legacyError) {
    ErrorHandler.logWarning(
        '$boxName: Unencrypted open also failed ($legacyError).');
  }

  // 3. الترحيل إلى الصندوق المشفر (فقط إذا تم استخراج البيانات بنجاح في الذاكرة)
  if (inMemoryBackup != null) {
    try {
      // حذف الصندوق القديم فقط بعد حفظ البيانات في الذاكرة
      await Hive.deleteBoxFromDisk(boxName);
      final newEncryptedBox = await Hive.openBox<T>(
        boxName,
        encryptionCipher: cipher,
      );
      if (inMemoryBackup.isNotEmpty) {
        await newEncryptedBox.putAll(Map<dynamic, T>.from(inMemoryBackup));
        await newEncryptedBox.flush();
      }
      ErrorHandler.logSuccess(
          '$boxName: Successfully migrated ${inMemoryBackup.length} records to AES-256 encrypted storage.');
      return newEncryptedBox;
    } catch (migrationError) {
      ErrorHandler.logWarning(
          '$boxName: Encrypted write failed ($migrationError). Restoring unencrypted backup...');
      // استعادة البيانات في صندوق غير مشفر لضمان عدم فقدان أي بيانات
      try {
        final fallbackBox = await Hive.openBox<T>(boxName);
        if (inMemoryBackup.isNotEmpty) {
          await fallbackBox.putAll(Map<dynamic, T>.from(inMemoryBackup));
          await fallbackBox.flush();
        }
        return fallbackBox;
      } catch (_) {}
    }
  }

  // 4. خيار الأمان الأخير: محاولة فتح الصندوق كصندوق غير مشفر عادي بدون حذف
  try {
    return await Hive.openBox<T>(boxName);
  } catch (_) {
    // محاولة أخيرة مع التشفير
    return await Hive.openBox<T>(boxName, encryptionCipher: cipher);
  }
}

/// الويدجت الرئيسية للتطبيق
/// 
/// تحتوي على:
/// - إعدادات MaterialApp
/// - ثيم فاتح وداكن
/// - دعم الوضع التلقائي حسب نظام التشغيل
/// - دعم التعريب والترجمة (AR/EN)
/// - مفتاح Navigator للإشعارات
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Y0 To-Do',
      debugShowCheckedModeBanner: false,
      theme: Y0DesignSystem.lightTheme,
      darkTheme: Y0DesignSystem.darkTheme,
      themeMode: themeMode,
      // ── i18n ──────────────────────────────────────────────────────────────
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // ──────────────────────────────────────────────────────────────────────
      home: const HomeScreenNeoMorphic(),
      routes: {
        '/statistics': (context) => const StatisticsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const HomeScreenNeoMorphic(),
        );
      },
    );
  }

}

/// Widget لتهيئة التطبيق بعد ProviderScope
/// 
/// يقوم بتهيئة خدمة الإشعارات بعد إعداد ProviderScope
/// لضمان توفر الـ ref للإشعارات
class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _notificationInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_notificationInitialized) {
      _initializeNotificationService();
    }
  }

  Future<void> _initializeNotificationService() async {
    try {
      // تعيين مفتاح التنقل
      final notificationService = NotificationService();
      notificationService.setNavigatorKey(appNavigatorKey);
      
      // تعيين الـ ref للوصول إلى providers
      notificationService.setRef(ref);
      
      // تهيئة خدمة الإشعارات مع timeout
      final notificationInitialized = await notificationService.initialize()
          .timeout(const Duration(seconds: 5), onTimeout: () {
            ErrorHandler.logWarning('Notification initialization timed out - continuing without notifications');
            return false;
          });
      
      if (notificationInitialized) {
        ErrorHandler.logSuccess('Notification service initialized successfully');
      } else {
        ErrorHandler.logWarning('Notification service failed to initialize - app will continue without notifications');
      }
      
      setState(() {
        _notificationInitialized = true;
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Notification service initialization in AppInitializer failed');
      setState(() {
        _notificationInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_notificationInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تهيئة التطبيق...'),
              ],
            ),
          ),
        ),
      );
    }

    return const ErrorBoundary(
      child: MyApp(),
    );
  }
}
