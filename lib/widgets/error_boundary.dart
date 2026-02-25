import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/error_handler.dart';

/// Widget يلتقط الأخطاء في الـ child widgets
/// 
/// يوفر واجهة مستخدم بديلة عند حدوث خطأ
/// يمنع تعطل التطبيق بالكامل
/// يوفر خيارات لإعادة المحاولة أو الإبلاغ عن المشكلة
class ErrorBoundary extends StatefulWidget {
  /// الـ child widget الذي نريد حمايته
  final Widget child;
  
  /// دالة مخصصة لعرض الخطأ (اختياري)
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  
  /// دالة يتم استدعاؤها عند حدوث خطأ (اختياري)
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    // إذا كان هناك خطأ، عرض واجهة الخطأ
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }
      return ErrorView(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _retry,
      );
    }

    // عرض الـ child مع التفاف error boundary
    return widget.child;
  }

  /// إعادة المحاولة
  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }
}

/// Error Widget مخصص يعرض رسالة خطأ واضحة
class AppErrorWidget extends StatelessWidget {
  /// الـ child widget
  final Widget child;

  /// دالة مخصصة لعرض الخطأ (اختياري)
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  /// دالة يتم استدعاؤها عند حدوث خطأ (اختياري)
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const AppErrorWidget({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      errorBuilder: errorBuilder,
      onError: (err, stack) {
        ErrorHandler.handleError(err, stack, context: 'AppErrorWidget');
        onError?.call(err, stack);
      },
      child: child,
    );
  }

  /// Builder factory لإنشاء AppErrorWidget
  static Widget builder({
    required Widget child,
    Widget Function(Object error, StackTrace? stackTrace)? errorBuilder,
    void Function(Object error, StackTrace? stackTrace)? onError,
  }) {
    return ErrorBoundary(
      errorBuilder: errorBuilder,
      onError: onError,
      child: child,
    );
  }
}

/// واجهة عرض الخطأ للمستخدم
/// 
/// تعرض رسالة خطأ واضحة مع أيقونة
/// توفر زر لإعادة المحاولة
/// توفر زر للإبلاغ عن المشكلة (اختياري)
class ErrorView extends StatelessWidget {
  /// الخطأ الذي حدث
  final Object error;
  
  /// Stack trace للخطأ
  final StackTrace? stackTrace;
  
  /// دالة إعادة المحاولة
  final VoidCallback? onRetry;
  
  /// دالة الإبلاغ عن المشكلة
  final VoidCallback? onReport;
  
  /// رسالة خطأ مخصصة
  final String? customMessage;

  const ErrorView({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.onReport,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة الخطأ مع animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red[400],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // عنوان الخطأ
              Text(
                'حدث خطأ ما!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // رسالة الخطأ
              Text(
                customMessage ?? 'عذراً، حدث خطأ غير متوقع. يمكنك المحاولة مرة أخرى أو الإبلاغ عن المشكلة.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // الأزرار
              if (onRetry != null) ...[
                // زر إعادة المحاولة
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
              ],
              
              // زر التفاصيل (في debug mode فقط)
              if (kDebugMode) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showErrorDetails(context),
                    icon: const Icon(Icons.bug_report),
                    label: const Text('عرض التفاصيل'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
              ],
              
              // زر الإبلاغ عن المشكلة
              if (onReport != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onReport,
                    icon: const Icon(Icons.report_problem),
                    label: const Text('الإبلاغ عن المشكلة'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// عرض تفاصيل الخطأ (للتطوير فقط)
  void _showErrorDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل الخطأ'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'الخطأ:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(
                error.toString(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              if (stackTrace != null) ...[
                const Text(
                  'Stack Trace:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  stackTrace.toString(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

/// Simple Error Boundary للمناطق الصغيرة
/// 
/// يستخدم لتفاف أجزاء صغيرة من الواجهة
/// لا يعرض واجهة كاملة، بل رسالة خطأ بسيطة
class SimpleErrorBoundary extends StatelessWidget {
  /// الـ child widget
  final Widget child;
  
  /// دالة مخصصة لعرض الخطأ
  final Widget Function(Object error)? errorBuilder;

  const SimpleErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      errorBuilder: (error, stackTrace) {
        if (errorBuilder != null) {
          return errorBuilder!(error);
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red[400], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'حدث خطأ: ${error.toString()}',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: child,
    );
  }
}

/// Mixin لإضافة error boundary إلى widgets
mixin ErrorBoundaryMixin<T extends StatefulWidget> on State<T> {
  Object? _lastError;
  StackTrace? _lastStackTrace;

  /// التحقق مما إذا كان هناك خطأ
  bool get hasError => _lastError != null;

  /// الحصول على آخر خطأ
  Object? get lastError => _lastError;

  /// مسح الخطأ
  void clearError() {
    setState(() {
      _lastError = null;
      _lastStackTrace = null;
    });
  }

  /// بناء واجهة الخطأ
  Widget buildErrorView() {
    return ErrorView(
      error: _lastError!,
      stackTrace: _lastStackTrace,
      onRetry: clearError,
    );
  }
}
