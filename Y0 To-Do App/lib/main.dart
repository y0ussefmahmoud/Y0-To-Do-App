// ignore_for_file: unused_local_variable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/task.dart';
import 'models/task_category.dart';
import 'models/search_history.dart';
import 'models/app_settings.dart';
import 'screens/home_screen_neomorphic.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';
import 'providers/settings_provider.dart';
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
/// 4. تهيئة Hive لقاعدة البيانات المحلية
/// 5. تسجيل محولات Hive
/// 6. فتح صندوق المهام
/// 7. تشغيل التطبيق مع ErrorBoundary
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');

  // تهيئة معالج الأخطاء أولاً
  ErrorHandler.initialize();
  ErrorHandler.logInfo('Starting Y0 To-Do App initialization');

  try {
    // Initialize Hive with comprehensive error handling
    try {
      ErrorHandler.logInfo('Initializing Hive...');
      await Hive.initFlutter();
      ErrorHandler.logSuccess('Hive initialized');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to initialize Hive');
      
      // Try to recover from Hive initialization error
      try {
        // Try to delete corrupted Hive files and reinitialize
        ErrorHandler.logInfo('Attempting to recover from Hive initialization error');
        await Hive.deleteFromDisk();
        await Hive.initFlutter();
        ErrorHandler.logSuccess('Hive recovered and initialized successfully');
      } catch (recoveryError, recoveryStackTrace) {
        ErrorHandler.handleError(recoveryError, recoveryStackTrace, context: 'Failed to recover Hive initialization');
        
        // Last resort: try to initialize with a different path
        try {
          ErrorHandler.logInfo('Attempting alternative Hive initialization...');
          // Try to force clean initialization
          await Future.delayed(const Duration(milliseconds: 100));
          await Hive.initFlutter();
          ErrorHandler.logSuccess('Alternative Hive initialization successful');
        } catch (finalError, finalStackTrace) {
          ErrorHandler.handleError(finalError, finalStackTrace, context: 'All Hive initialization attempts failed');
          rethrow; // If all attempts fail, we can't continue
        }
      }
    }
    
    // Register adapters with error handling
    try {
      ErrorHandler.logInfo('Checking TaskCategoryAdapter registration...');
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(TaskCategoryAdapter());
        ErrorHandler.logInfo('TaskCategoryAdapter registered successfully.');
      } else {
        ErrorHandler.logInfo('TaskCategoryAdapter already registered.');
      }

      ErrorHandler.logInfo('Checking TaskAdapter registration...');
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(TaskAdapter());
        ErrorHandler.logInfo('TaskAdapter registered successfully.');
      } else {
        ErrorHandler.logInfo('TaskAdapter already registered.');
      }

      ErrorHandler.logInfo('Checking SearchHistoryAdapter registration...');
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(SearchHistoryAdapter());
        ErrorHandler.logInfo('SearchHistoryAdapter registered successfully.');
      } else {
        ErrorHandler.logInfo('SearchHistoryAdapter already registered.');
      }

      ErrorHandler.logInfo('Checking AppSettingsAdapter registration...');
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(AppSettingsAdapter());
        ErrorHandler.logInfo('AppSettingsAdapter registered successfully.');
      } else {
        ErrorHandler.logInfo('AppSettingsAdapter already registered.');
      }

      ErrorHandler.logSuccess('All Hive adapters processed.');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to register Hive adapters');
      rethrow; // Adapters are critical, so rethrow
    }
    
    // Open boxes with comprehensive error handling
    Box<Task>? tasksBox;
    Box<SearchHistory>? searchHistoryBox;
    Box<AppSettings>? settingsBox;
    
    try {
      ErrorHandler.logInfo('Opening tasksBox...');
      tasksBox = await Hive.openBox<Task>('tasksBox');
      ErrorHandler.logSuccess('tasksBox opened');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to open tasksBox');
      rethrow; // Tasks box is critical
    }
    
    try {
      ErrorHandler.logInfo('Opening searchHistoryBox...');
      searchHistoryBox = await Hive.openBox<SearchHistory>('searchHistoryBox');
      ErrorHandler.logSuccess('searchHistoryBox opened');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to open searchHistoryBox');
      // Continue without search history - not critical
    }
    
    try {
      ErrorHandler.logInfo('Opening settingsBox...');
      
      // Try to open the box with migration handling
      try {
        settingsBox = await Hive.openBox<AppSettings>('settingsBox');
        
        // Migration: Check and fix null values if needed
        if (settingsBox.isNotEmpty) {
          try {
            final oldSettings = settingsBox.getAt(0);
            if (oldSettings != null) {
              // Try to access all fields to trigger null cast if any
              final test = AppSettings(
                themeMode: oldSettings.themeMode,
                language: oldSettings.language,
                notificationsEnabled: oldSettings.notificationsEnabled,
                soundEnabled: oldSettings.soundEnabled,
                speechRate: oldSettings.speechRate,
                speechVolume: oldSettings.speechVolume,
                speechPitch: oldSettings.speechPitch,
                notificationMinutesBefore: oldSettings.notificationMinutesBefore,
                exactTimeNotificationsEnabled: oldSettings.exactTimeNotificationsEnabled,
                userName: oldSettings.userName,
              );
              // If we get here, data is valid
              ErrorHandler.logSuccess('settingsBox opened and validated');
            }
          } catch (castError) {
            // Null cast error detected, need to migrate
            ErrorHandler.logWarning('Null cast error in settingsBox. Attempting migration...');
            await Hive.deleteBoxFromDisk('settingsBox');
            settingsBox = await Hive.openBox<AppSettings>('settingsBox');
            ErrorHandler.logSuccess('settingsBox migrated and recreated');
          }
        } else {
          ErrorHandler.logSuccess('settingsBox opened (empty)');
        }
      } catch (e) {
        // If opening fails completely, delete and recreate
        ErrorHandler.logWarning('Failed to open settingsBox. Attempting to recreate...');
        await Hive.deleteBoxFromDisk('settingsBox');
        settingsBox = await Hive.openBox<AppSettings>('settingsBox');
        ErrorHandler.logSuccess('settingsBox recreated successfully');
      }
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to open settingsBox');
      rethrow; // Settings box is critical
    }

    // Check for pending navigation from background notifications
    try {
      final notificationService = NotificationService();
      await notificationService.checkPendingNavigation();
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'Failed to check pending navigation');
      // Continue - not critical
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
    
    // في حالة فشل التهيئة، نعرض تطبيق بسيط مع رسالة خطأ مفصلة
    runApp(
      MaterialApp(
        home: ErrorView(
          error: e,
          stackTrace: stackTrace,
          customMessage: 'فشل في تهيئة التطبيق: ${e.toString()}. يرجى إعادة تشغيل التطبيق أو مسح بيانات التطبيق وإعادة التثبيت.',
        ),
      ),
    );
  }
}

/// الويدجت الرئيسية للتطبيق
/// 
/// تحتوي على:
/// - إعدادات MaterialApp
/// - ثيم فاتح وداكن
/// - دعم الوضع التلقائي حسب نظام التشغيل
/// - مفتاح Navigator للإشعارات
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Y0 To-Do App',
      debugShowCheckedModeBanner: false, // إزالة شريط DEBUG
      theme: Y0DesignSystem.lightTheme,
      darkTheme: Y0DesignSystem.darkTheme,
      themeMode: themeMode,
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
    // Removed notification initialization from here
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
      // Continue with app even if notifications fail
      setState(() {
        _notificationInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // انتظر حتى تتم تهيئة الإشعارات قبل عرض التطبيق
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
