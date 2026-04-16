import 'package:flutter/material.dart';
import '../theme/y0_design_system.dart';

/// 🎨 Neo-Morphic Card Widget
/// 
/// ويدجت مخصص لإنشاء بطاقات Neo-morphic بتأثير الظل الطبيعي
/// يتبع نظام التصميم Y0DesignSystem مع الظل المحيطي الطبيعي
/// 
/// @author Y0 Development Team
/// @version 3.1.0
class NeoMorphicCard extends StatelessWidget {
  /// المحتوى الداخلي للبطاقة
  final Widget child;
  
  /// هل البطاقة مضغوقة (أقل ظل)
  final bool isInset;
  
  /// هامش البطاقة
  final EdgeInsetsGeometry? margin;
  
  /// حشوة البطاقة
  final EdgeInsetsGeometry? padding;
  
  /// عرض البطاقة
  final double? width;
  
  /// ارتفاع البطاقة
  final double? height;
  
  /// لون الخلفية
  final Color? color;
  
  /// زوايا الاستدارة
  final BorderRadius? borderRadius;
  
  /// عند النقر
  final VoidCallback? onTap;

  const NeoMorphicCard({
    super.key,
    required this.child,
    this.isInset = false,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? context.colorScheme.surfaceContainerLowest;
    final radius = borderRadius ?? BorderRadius.circular(Y0DesignSystem.radiusMedium);
    
    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        boxShadow: isInset ? _getInsetShadow(context) : _getElevatedShadow(context),
      ),
      child: child,
    );
    
    // إضافة تأثير النقر إذا كان مطلوباً
    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    
    return card;
  }

  /// 🌫️ ظل مرتفع للبطاقات العادية (يتكيف مع الوضع الليلي)
  List<BoxShadow> _getElevatedShadow(BuildContext context) {
    final isDark = context.isDarkMode;
    
    if (isDark) {
      // Dark mode shadows - darker and more subtle
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.3),
          blurRadius: 8,
          offset: const Offset(4, 4),
        ),
        BoxShadow(
          color: context.colorScheme.surfaceContainerHigh.withValues(alpha:0.2),
          blurRadius: 8,
          offset: const Offset(-4, -4),
        ),
      ];
    } else {
      // Light mode shadows - original implementation
      return [
        BoxShadow(
          color: context.colorScheme.onSurface.withValues(alpha:0.04),
          blurRadius: 8,
          offset: const Offset(4, 4),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha:0.8),
          blurRadius: 8,
          offset: const Offset(-4, -4),
        ),
      ];
    }
  }

  /// 🌑 ظل داخلي للبطاقات المضغوطة (يتكيف مع الوضع الليلي)
  List<BoxShadow> _getInsetShadow(BuildContext context) {
    final isDark = context.isDarkMode;
    
    if (isDark) {
      // Dark mode inset shadows
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.2),
          blurRadius: 6,
          offset: const Offset(2, 2),
        ),
        BoxShadow(
          color: context.colorScheme.surfaceContainerHigh.withValues(alpha:0.1),
          blurRadius: 6,
          offset: const Offset(-2, -2),
        ),
      ];
    } else {
      // Light mode inset shadows - original implementation
      return [
        BoxShadow(
          color: context.colorScheme.onSurface.withValues(alpha:0.06),
          blurRadius: 6,
          offset: const Offset(2, 2),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha:0.6),
          blurRadius: 6,
          offset: const Offset(-2, -2),
        ),
      ];
    }
  }
}

/// 🎯 Neo-Morphic Button
/// 
/// زر Neo-morphic مع تأثيرات الضغط والحركات الطبيعية
/// متوافق مع نظام التصميم Y0DesignSystem
class NeoMorphicButton extends StatefulWidget {
  /// نص الزر
  final String text;
  
  /// أيقونة الزر (اختياري)
  final IconData? icon;
  
  /// عند الضغط
  final VoidCallback onPressed;
  
  /// هل الزر نشط
  final bool isActive;
  
  /// حجم الزر
  final NeoMorphicButtonSize size;
  
  /// لون الزر (عند التفعيل)
  final Color? activeColor;

  const NeoMorphicButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isActive = false,
    this.size = NeoMorphicButtonSize.medium,
    this.activeColor,
  });

  @override
  State<NeoMorphicButton> createState() => _NeoMorphicButtonState();
}

class _NeoMorphicButtonState extends State<NeoMorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Y0DesignSystem.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isActive 
        ? (widget.activeColor ?? context.colorScheme.primary)
        : context.colorScheme.surfaceContainerLowest;
    
    final textColor = widget.isActive
        ? context.colorScheme.onPrimary
        : context.colorScheme.onSurfaceVariant;

    final buttonSize = _getButtonSize();

    return GestureDetector(
      onTapDown: (_) => _handlePressDown(),
      onTapUp: (_) => _handlePressUp(),
      onTapCancel: _handlePressCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: NeoMorphicCard(
              width: buttonSize.width,
              height: buttonSize.height,
              color: backgroundColor,
              padding: EdgeInsets.symmetric(
                horizontal: buttonSize.horizontalPadding,
                vertical: buttonSize.verticalPadding,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: textColor,
                      size: buttonSize.iconSize,
                    ),
                    SizedBox(width: buttonSize.iconTextSpacing),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: buttonSize.fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 📏 الحصول على أبعاد الزر حسب الحجم
  NeoMorphicButtonDimensions _getButtonSize() {
    switch (widget.size) {
      case NeoMorphicButtonSize.small:
        return const NeoMorphicButtonDimensions(
          width: null,
          height: 32,
          horizontalPadding: 12,
          verticalPadding: 6,
          iconSize: 16,
          iconTextSpacing: 6,
          fontSize: 12,
        );
      case NeoMorphicButtonSize.medium:
        return const NeoMorphicButtonDimensions(
          width: null,
          height: 40,
          horizontalPadding: 16,
          verticalPadding: 8,
          iconSize: 18,
          iconTextSpacing: 8,
          fontSize: 14,
        );
      case NeoMorphicButtonSize.large:
        return const NeoMorphicButtonDimensions(
          width: null,
          height: 48,
          horizontalPadding: 24,
          verticalPadding: 12,
          iconSize: 20,
          iconTextSpacing: 10,
          fontSize: 16,
        );
    }
  }

  /// 👇 معالج الضغط
  void _handlePressDown() {
    _animationController.forward();
  }

  /// ☝️ معالج رفع الضغط
  void _handlePressUp() {
    _animationController.reverse();
  }

  /// ❌ معالج إلغاء الضغط
  void _handlePressCancel() {
    _animationController.reverse();
  }
}

/// 📏 أبعاد زر Neo-morphic
class NeoMorphicButtonDimensions {
  final double? width;
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final double iconTextSpacing;
  final double fontSize;

  const NeoMorphicButtonDimensions({
    required this.width,
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.iconTextSpacing,
    required this.fontSize,
  });
}

/// 📐 أحجام أزرار Neo-morphic
enum NeoMorphicButtonSize {
  small,
  medium,
  large,
}

/// 🔄 Neo-Morphic Switch
/// 
/// مفتاح تبديل Neo-morphic مع تأثيرات حركية سلسة
class NeoMorphicSwitch extends StatefulWidget {
  /// قيمة المفتاح الحالية
  final bool value;
  
  /// عند التغيير
  final ValueChanged<bool> onChanged;
  
  /// لون نشط
  final Color? activeColor;

  const NeoMorphicSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  State<NeoMorphicSwitch> createState() => _NeoMorphicSwitchState();
}

class _NeoMorphicSwitchState extends State<NeoMorphicSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Y0DesignSystem.animationMedium,
      vsync: this,
    );
    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // تحديث الرسوم المتحركة مع تغير القيمة
    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NeoMorphicSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? context.colorScheme.primary;
    
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _positionAnimation,
        builder: (context, child) {
          return NeoMorphicCard(
            width: 52,
            height: 28,
            borderRadius: BorderRadius.circular(14),
            color: widget.value 
                ? activeColor.withValues(alpha:0.2)
                : context.colorScheme.surfaceContainerLow,
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                // خلفية نشطة
                if (widget.value)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha:0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                
                // الدائرة المتحركة
                Positioned(
                  left: 4 + (_positionAnimation.value * 24),
                  top: 4,
                  child: NeoMorphicCard(
                    width: 20,
                    height: 20,
                    borderRadius: BorderRadius.circular(10),
                    color: widget.value 
                        ? activeColor 
                        : context.colorScheme.onSurfaceVariant.withValues(alpha:0.4),
                    child: Container(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
