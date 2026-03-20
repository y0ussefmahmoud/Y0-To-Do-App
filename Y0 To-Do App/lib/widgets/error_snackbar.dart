import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/haptic_service.dart';

class ErrorSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    HapticService.error();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
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
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticService.light();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
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
        .slideY(begin: 1.0, end: 0.0, duration: 300.ms, curve: Curves.bounceOut)
        .fadeIn(duration: 200.ms);
  }
}

class ErrorSnackBarWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorSnackBarWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
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
            Icons.error_outline_rounded,
            color: Colors.white,
            size: 20,
          )
              .animate()
              .scale(duration: 200.ms, begin: const Offset(0.8, 0.8))
              .then()
              .shake(hz: 4, duration: 300.ms),
          
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
          
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                HapticService.light();
                onDismiss?.call();
                onRetry?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms),
          ],
          
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
                .fadeIn(duration: 300.ms, delay: 250.ms),
          ),
        ],
      ),
    );
  }
}
