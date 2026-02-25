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
    // Initialize notification service
    NotificationService.setNavigatorKey(appNavigatorKey);
    
    final notificationService = NotificationService();
    await notificationService.initialize();
    ErrorHandler.logSuccess('Notification service initialized');

    // Initialize Hive
    await Hive.initFlutter();
    ErrorHandler.logSuccess('Hive initialized');
    
    // Register adapters
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SearchHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    ErrorHandler.logSuccess('Hive adapters registered');
    
    // Open boxes
    await Hive.openBox<Task>('tasksBox');
    await Hive.openBox<SearchHistory>('searchHistoryBox');
    await Hive.openBox<AppSettings>('settingsBox');
    ErrorHandler.logSuccess('Hive boxes opened');

    // Check for pending navigation from background notifications
    await NotificationService.checkPendingNavigation();

    ErrorHandler.logSuccess('App initialization completed successfully');

    runApp(ProviderScope(
      overrides: [
        settingsBoxProvider.overrideWithValue(
          Hive.box<AppSettings>('settingsBox'),
        ),
      ],
      child: const ErrorBoundary(
        child: MyApp(),
      ),
    ));
  } catch (e, stackTrace) {
    ErrorHandler.handleError(e, stackTrace, context: 'App initialization');
    
    // في حالة فشل التهيئة، نعرض تطبيق بسيط مع رسالة خطأ
    runApp(
      MaterialApp(
        home: ErrorView(
          error: e,
          stackTrace: stackTrace,
          customMessage: 'فشل في تهيئة التطبيق. يرجى إعادة تشغيل التطبيق.',
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
  ThemeData _buildLightTheme() {
    const primaryColor = Color(0xFF6366F1); // Indigo
    const backgroundColor = Color(0xFFF8FAFC);
    
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
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
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
  /// يحتوي على تخصيص للوضع الليلي
  /// يستخدم Material 3 design
  /// يحسن contrast ratio للـ accessibility
  ThemeData _buildDarkTheme() {
    const primaryColor = Color(0xFF6366F1);
    const backgroundColor = Color(0xFF0F172A);
    
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
        bodyColor: Colors.white,
        displayColor: Colors.white,
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
        color: const Color(0xFF1E293B),
      ),
    );
  }
}
