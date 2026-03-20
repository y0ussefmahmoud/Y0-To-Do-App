import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/haptic_service.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDangerous;
  final IconData icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'حذف',
    this.cancelText = 'إلغاء',
    this.isDangerous = false,
    this.icon = Icons.warning_amber_rounded,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'حذف',
    String cancelText = 'إلغاء',
    bool isDangerous = false,
    IconData icon = Icons.warning_amber_rounded,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDangerous
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDangerous ? Colors.red : Colors.orange,
              ),
            )
                .animate()
                .scale(duration: 300.ms, begin: const Offset(0.8, 0.8))
                .shake(hz: 4, duration: 500.ms)
                .then(delay: 200.ms),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDangerous ? Colors.red : null,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 100.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      HapticService.light();
                      Navigator.of(context).pop(false);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 200.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(width: 12),

                // Confirm button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticService.medium();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDangerous
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(confirmText),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 250.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 200.ms)
          .scale(duration: 300.ms, begin: const Offset(0.8, 0.8), curve: Curves.easeOutCubic),
    );
  }
}
