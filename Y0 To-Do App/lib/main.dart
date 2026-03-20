// ignore_for_file: unused_local_variable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/task.dart';
import 'models/task_category.dart';
import 'models/search_history.dart';
import 'models/app_settings.dart';
import 'screens/home_screen.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'utils/error_handler.dart';
import 'widgets/error_boundary.dart';

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
      settingsBox = await Hive.openBox<AppSettings>('settingsBox');
      ErrorHandler.logSuccess('settingsBox opened');
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
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }

  /// بناء الثيم الفاتح
  /// 
  /// يحتوي على تخصيص شامل للألوان والأشكال
  /// يستخدم Material 3 design
  /// يحسن contrast ratio للـ accessibility
  /// يستخدم ألوان حديثة ومناسبة للـ UI
  ThemeData _buildLightTheme() {
    const primaryColor = Color(0xFF66BB6A); // أزرق أفتح وأحدث
    const backgroundColor = Color(0xFFF8FAFC); // أبيض نقي
    
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'NotoSansArabic',
      fontFamilyFallback: const [
        'NotoSans',
        'NotoSansSymbols2',
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      
      // Typography مع تحسين للـ accessibility
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          height: 1.3,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF1E293B),
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF1E293B),
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF1E293B),
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
          height: 1.4,
        ),
      ).apply(fontFamily: 'NotoSansArabic'),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1E293B),
        titleTextStyle: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        shadowColor: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 8,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF66BB6A)), // نفس لون الـ primary
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF66BB6A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF66BB6A), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF66BB6A), // نفس لون الـ primary
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// بناء الثيم الداكن
  /// 
  /// يحتوي على تخصيص متقدم للوضع الليلي
  /// يستخدم Material 3 design
  /// يحسن contrast ratio للـ accessibility
  /// يستخدم ألوان حديثة ومناسبة
  ThemeData _buildDarkTheme() {
    const primaryColor = Color(0xFF66BB6A); // أزرق أفتح للـ dark mode
    const backgroundColor = Color.fromARGB(255, 48, 46, 46); // أسود داكن ناعم
    
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'NotoSansArabic',
      fontFamilyFallback: const [
        'NotoSans',
        'NotoSansSymbols2',
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundColor,
      
      // Typography مع تحسين للـ accessibility
      textTheme: Typography.material2021().white.apply(
        fontSizeFactor: 1.0,
        fontSizeDelta: 0.0,
        bodyColor: const Color.fromARGB(255, 138, 184, 156),
        displayColor: const Color.fromARGB(255, 66, 88, 61),
        fontFamily: 'NotoSansArabic',
      ),
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF1E293B), // أزرق داكن للـ contrast
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
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
      
      // تهيئة خدمة الإشعارات
      final notificationInitialized = await notificationService.initialize();
      
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
