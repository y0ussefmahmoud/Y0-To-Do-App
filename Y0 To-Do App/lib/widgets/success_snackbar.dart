import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/haptic_service.dart';

class SuccessSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticService.success();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  static Widget buildAnimatedContent({
    required Widget child,
  }) {
    return child
        .animate()
        .slideY(begin: 1.0, end: 0.0, duration: 300.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 200.ms)
        .then()
        .scale(duration: 100.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05))
        .then()
        .scale(duration: 100.ms, begin: const Offset(1.05, 1.05), end: const Offset(1.0, 1.0));
  }
}

class SuccessSnackBarWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const SuccessSnackBarWidget({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          )
              .animate()
              .scale(duration: 200.ms, begin: const Offset(0.8, 0.8))
              .then()
              .scale(duration: 100.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.2, 1.2))
              .then()
              .scale(duration: 100.ms, begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0)),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 100.ms),
          ),
          
          const SizedBox(width: 8),
          
          GestureDetector(
            onTap: () {
              HapticService.light();
              onDismiss?.call();
            },
            child: Icon(
              Icons.close_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 18,
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms),
          ),
        ],
      ),
    );
  }
}

// Predefined success messages
class SuccessMessages {
  static const String taskAdded = 'تمت إضافة المهمة بنجاح ✓';
  static const String taskUpdated = 'تم تحديث المهمة ✓';
  static const String taskDeleted = 'تم حذف المهمة ✓';
  static const String taskCompleted = 'تم إكمال المهمة ✓';
  static const String taskUncompleted = 'تم إلغاء إكمال المهمة ✓';
  static const String taskRestored = 'تم استعادة المهمة ✓';
  static const String voiceCommandAdded = 'تمت إضافة المهمة بالأمر الصوتي ✓';
  static const String aiAnalysisComplete = 'اكتمل تحليل الذكاء الاصطناعي ✓';
  static const String settingsSaved = 'تم حفظ الإعدادات ✓';
  static const String dataExported = 'تم تصدير البيانات ✓';
  static const String dataImported = 'تم استيراد البيانات ✓';
}
