import 'package:flutter/material.dart';
import '../theme/y0_design_system.dart';

/// 🌟 Daily Progress Orb Widget
/// 
/// ويدجت لعرض مؤشر التقدم الدائري مع تأثيرات Neo-morphic
/// يعرض نسبة الإنجاز اليومية بشكل جذاب وتفاعلي
/// 
/// @author Y0 Development Team
/// @version 3.1.0
class DailyProgressOrb extends StatefulWidget {
  /// نسبة التقدم (0.0 إلى 1.0)
  final double progress;
  
  /// حجم المؤشر
  final double size;
  
  /// لون التقدم
  final Color? progressColor;
  
  /// لون الخلفية
  final Color? backgroundColor;
  
  /// عرض النسبة المئوية
  final bool showPercentage;
  
  /// نص مخصص بدلاً من النسبة المئوية
  final String? customText;

  const DailyProgressOrb({
    super.key,
    required this.progress,
    this.size = 80,
    this.progressColor,
    this.backgroundColor,
    this.showPercentage = true,
    this.customText,
  });

  @override
  State<DailyProgressOrb> createState() => _DailyProgressOrbState();
}

class _DailyProgressOrbState extends State<DailyProgressOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Y0DesignSystem.animationSlow,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    // بدء الرسوم المتحركة
    _animationController.forward();
  }

  @override
  void didUpdateWidget(DailyProgressOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ));
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = widget.progressColor ?? Y0DesignSystem.onPrimary;
    final backgroundColor = widget.backgroundColor ?? 
        Y0DesignSystem.onPrimary.withValues(alpha:0.2);
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ProgressOrbPainter(
              progress: _progressAnimation.value,
              progressColor: progressColor,
              backgroundColor: backgroundColor,
              strokeWidth: widget.size * 0.08,
            ),
            child: Center(
              child: _buildCenterText(progressColor),
            ),
          );
        },
      ),
    );
  }

  /// 📝 نص وسط المؤشر
  Widget _buildCenterText(Color progressColor) {
    if (widget.customText != null) {
      return Text(
        widget.customText!,
        style: TextStyle(
          color: progressColor,
          fontSize: widget.size * 0.15,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (widget.showPercentage) {
      final percentage = (widget.progress * 100).round();
      return Text(
        '$percentage%',
        style: TextStyle(
          color: progressColor,
          fontSize: widget.size * 0.15,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// 🎨 Custom Painter لرسم المؤشر الدائري
class _ProgressOrbPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressOrbPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // رسم خلفية المؤشر
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // رسم شريط التقدم
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = progress * 2 * 3.14159265359;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159265359 / 2, // البدء من الأعلى
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // إضافة تأثير Neo-morphic (ظل خفيف)
    if (progress > 0) {
      final shadowPaint = Paint()
        ..color = progressColor.withValues(alpha:0.1)
        ..strokeWidth = strokeWidth * 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final sweepAngle = progress * 2 * 3.14159265359;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159265359 / 2,
        sweepAngle,
        false,
        shadowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressOrbPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}

/// 📊 Daily Progress Card Widget
/// 
/// بطاقة متكاملة لعرض تقدم اليوم مع مؤشر دائري ومعلومات إضافية
/// تتبع نظام التصميم Neo-morphic
class DailyProgressCard extends StatelessWidget {
  /// نسبة الإنجاز
  final double progress;
  
  /// عدد المهام المكتملة
  final int completedTasks;
  
  /// عدد المهام الإجمالي
  final int totalTasks;
  
  /// رسالة تشجيعية
  final String? message;

  const DailyProgressCard({
    super.key,
    required this.progress,
    required this.completedTasks,
    required this.totalTasks,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final defaultMessage = progress >= 0.75
        ? 'أنت قريب جداً من إنهاء خطتك اليومية!'
        : progress >= 0.5
            ? 'أنت تسير بخطى جيدة، استمر!'
            : 'لنبدأ اليوم بإنجاز مهامك!';

    return Container(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      decoration: BoxDecoration(
        gradient: Y0DesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
        boxShadow: Y0DesignSystem.floatingShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // معلومات التقدم
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'إنجازك لليوم: ${(progress * 100).round()}%',
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: Y0DesignSystem.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: Y0DesignSystem.spacing2),
                
                Text(
                  message ?? defaultMessage,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: Y0DesignSystem.onPrimary.withValues(alpha:0.8),
                  ),
                ),
                
                const SizedBox(height: Y0DesignSystem.spacing2),
                
                // إحصائيات المهام
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Y0DesignSystem.spacing2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Y0DesignSystem.onPrimary.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$completedTasks من $totalTasks مهمة',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: Y0DesignSystem.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: Y0DesignSystem.spacing3),
                
                // شريط التقدم الخطي
                _buildLinearProgress(context),
              ],
            ),
          ),
          
          // المؤشر الدائري
          Expanded(
            flex: 1,
            child: DailyProgressOrb(
              progress: progress,
              size: 80,
              progressColor: Y0DesignSystem.onPrimary,
              backgroundColor: Y0DesignSystem.onPrimary.withValues(alpha:0.2),
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 شريط التقدم الخطي
  Widget _buildLinearProgress(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Y0DesignSystem.onPrimary.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerRight,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Y0DesignSystem.onPrimary,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Y0DesignSystem.onPrimary.withValues(alpha:0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
