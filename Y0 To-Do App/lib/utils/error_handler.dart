import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// معالج الأخطاء الشامل للتطبيق
/// 
/// يوفر نظاماً متكاملاً للتعامل مع الأخطاء وتسجيلها
/// يدعم:
/// - تسجيل الأخطاء مع timestamp
/// - تصنيف الأخطاء (Error, Warning, Info)
/// - ألوان مختلفة لأنواع الأخطاء في console
/// - معالجة الأخطاء العامة في Flutter
/// - تسجيل stack traces كاملة
class ErrorHandler {
  static bool _isInitialized = false;

  /// تهيئة معالج الأخطاء
  /// 
  /// يجب استدعاؤها في main() قبل runApp()
  /// يقوم بإعداد handlers للأخطاء العامة
  static void initialize() {
    if (_isInitialized) return;

    // معالجة أخطاء Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      logError(
        'Flutter Error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    // معالجة أخطاء النظام الأساسي
    PlatformDispatcher.instance.onError = (error, stack) {
      logError(
        'Platform Error: ${error.toString()}',
        error: error,
        stackTrace: stack,
      );
      return true; // منع انتشار الخطأ
    };

    _isInitialized = true;
    logInfo('ErrorHandler initialized successfully');
  }

  /// معالجة الخطأ الرئيسي
  /// 
  /// [error] الخطأ الذي حدث
  /// [stackTrace] stack trace للخطأ (اختياري)
  /// [context] سياق إضافي للخطأ (اختياري)
  static void handleError(Object error, StackTrace? stackTrace, {String? context}) {
    final message = context != null ? '$context: $error' : error.toString();
    logError(message, error: error, stackTrace: stackTrace);
  }

  /// تسجيل خطأ
  /// 
  /// [message] رسالة الخطأ
  /// [error] الخطأ (اختياري)
  /// [stackTrace] stack trace (اختياري)
  static void logError(String message, {Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, '\x1B[31m', error: error, stackTrace: stackTrace);
  }

  /// تسجيل تحذير
  /// 
  /// [message] رسالة التحذير
  /// [error] الخطأ (اختياري)
  static void logWarning(String message, {Object? error}) {
    _log('WARNING', message, '\x1B[33m', error: error);
  }

  /// تسجيل معلومة
  /// 
  /// [message] رسالة المعلومة
  static void logInfo(String message) {
    _log('INFO', message, '\x1B[36m');
  }

  /// تسجيل رسالة تصحيح
  /// 
  /// [message] رسالة التصحيح
  static void logDebug(String message) {
    if (kDebugMode) {
      _log('DEBUG', message, '\x1B[35m');
    }
  }

  /// تسجيل بنجاح
  /// 
  /// [message] رسالة النجاح
  static void logSuccess(String message) {
    _log('SUCCESS', message, '\x1B[32m');
  }

  /// الدالة الداخلية لتسجيل الرسائل
  /// 
  /// [level] مستوى الرسالة
  /// [message] الرسالة
  /// [color] اللون في console
  /// [error] الخطأ (اختياري)
  /// [stackTrace] stack trace (اختياري)
  static void _log(
    String level,
    String message,
    String color, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '$color[$level] [$timestamp] $message\x1B[0m';

    // التسجيل في console مع الألوان
    developer.log(logMessage, name: 'Y0ToDo');

    // إذا كان هناك خطأ، نسجل التفاصيل الإضافية
    if (error != null) {
      developer.log('Error details: $error', name: 'Y0ToDo');
    }

    // إذا كان هناك stack trace، نسجله بالكامل
    if (stackTrace != null) {
      developer.log('Stack trace:\n$stackTrace', name: 'Y0ToDo');
    }
  }

  /// التحقق مما إذا كان المعالج مهيأً
  static bool get isInitialized => _isInitialized;
}

/// استثناءات مخصصة للمستودع
class TaskRepositoryException implements Exception {
  /// رسالة الخطأ
  final String message;
  
  /// السبب الأصلي للخطأ
  final Exception? cause;

  TaskRepositoryException(this.message, {this.cause});

  @override
  String toString() => 'TaskRepositoryException: $message${cause != null ? ' (Caused by: $cause)' : ''}';
}

/// استثناء مهمة غير موجودة
class TaskNotFoundException implements Exception {
  /// معرف المهمة
  final String taskId;
  
  TaskNotFoundException(this.taskId);

  @override
  String toString() => 'TaskNotFoundException: Task with ID "$taskId" not found';
}

/// استثناء تهيئة الخدمة
class ServiceInitializationException implements Exception {
  /// اسم الخدمة
  final String serviceName;
  
  /// السبب
  final String reason;

  ServiceInitializationException(this.serviceName, this.reason);

  @override
  String toString() => 'ServiceInitializationException: Failed to initialize $serviceName - $reason';
}

/// استثناء الشبكة
class NetworkException implements Exception {
  /// رسالة الخطأ
  final String message;
  
  /// رمز الخطأ (اختياري)
  final int? statusCode;

  NetworkException(this.message, {this.statusCode});

  @override
  String toString() => 'NetworkException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// استثناء الصلاحيات
class PermissionException implements Exception {
  /// الصلاحية المطلوبة
  final String permission;
  
  /// رسالة الخطأ
  final String message;

  PermissionException(this.permission, this.message);

  @override
  String toString() => 'PermissionException: $permission - $message';
}

/// استثناء التخزين
class StorageException implements Exception {
  /// رسالة الخطأ
  final String message;
  
  /// العملية التي فشلت
  final String operation;

  StorageException(this.operation, this.message);

  @override
  String toString() => 'StorageException: Failed to $operation - $message';
}

/// مساعد لتسهيل تسجيل الأخطاء
class Logger {
  /// تسجيل خطأ في عملية محددة
  static void errorInOperation(String operation, Object error, {StackTrace? stackTrace}) {
    ErrorHandler.logError(
      'Error in $operation',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// تسجيل نجاح عملية
  static void operationSuccess(String operation, {String? details}) {
    final message = details != null ? '$operation completed successfully: $details' : '$operation completed successfully';
    ErrorHandler.logSuccess(message);
  }

  /// تسجيل فشل عملية
  static void operationFailed(String operation, String reason, {Object? error}) {
    ErrorHandler.logError(
      '$operation failed: $reason',
      error: error,
    );
  }

  /// تسجيل بدء عملية
  static void operationStarted(String operation, {Map<String, dynamic>? parameters}) {
    final message = parameters != null 
        ? 'Started $operation with parameters: $parameters'
        : 'Started $operation';
    ErrorHandler.logInfo(message);
  }
}
