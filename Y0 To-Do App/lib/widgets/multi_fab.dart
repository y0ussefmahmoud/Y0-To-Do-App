import 'package:flutter/material.dart';
import '../theme/y0_design_system.dart';
import 'neo_morphic_card.dart';

/// 🎯 Multi-functional FAB Widget
/// 
/// زر عائم متعدد الوظائف مع تأثيرات Neo-morphic
/// يمكن توسيعه لإظهار أزرار إضافية (إضافة حدث، إشعار، مهمة)
/// يتبع نظام التصميم Y0DesignSystem
/// 
/// @author Y0 Development Team
/// @version 3.1.0
class MultiFab extends StatefulWidget {
  /// هل الزر موسع حالياً
  final bool isExpanded;
  
  /// عند تغيير حالة التوسع
  final VoidCallback onToggle;
  
  /// عند إضافة مهمة جديدة
  final VoidCallback onAddTask;
  
  /// عند إضافة حدث جديد
  final VoidCallback onAddEvent;
  
  /// عند إضافة إشعار جديد
  final VoidCallback onAddNotification;
  
  /// أزرار إضافية مخصصة (اختياري)
  final List<FabAction>? customActions;

  const MultiFab({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onAddTask,
    required this.onAddEvent,
    required this.onAddNotification,
    this.customActions,
  });

  @override
  State<MultiFab> createState() => _MultiFabState();
}

class _MultiFabState extends State<MultiFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Y0DesignSystem.animationMedium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // تحديث الرسوم المتحركة مع تغير حالة التوسع
    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MultiFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // الأزرار الإضافية (تظهر عند التوسع)
        if (widget.isExpanded) ...[
          _buildActionButtons(),
          const SizedBox(height: Y0DesignSystem.spacing2),
        ],
        
        // الزر الرئيسي
        _buildMainFab(),
      ],
    );
  }

  /// 🎯 الأزرار الإضافية
  Widget _buildActionButtons() {
    final actions = _getActionButtons();
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: actions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: Y0DesignSystem.spacing2),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutBack,
                )),
                child: _buildActionButton(action),
              ),
            ),
          )).toList(),
        );
      },
    );
  }

  /// 🔘 زر إضافي واحد
  Widget _buildActionButton(FabAction action) {
    return NeoMorphicCard(
      width: 48,
      height: 48,
      borderRadius: BorderRadius.circular(24),
      onTap: action.onTap,
      child: Icon(
        action.icon,
        color: context.colorScheme.primary,
        size: 24,
      ),
    );
  }

  /// ➕ الزر الرئيسي
  Widget _buildMainFab() {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159265359,
            child: GestureDetector(
              onTap: () {
                widget.onToggle();
                _handleMainFabPress();
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: Y0DesignSystem.primaryGradient,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: Y0DesignSystem.floatingShadow,
                ),
                child: const Icon(
                  Icons.add,
                  color: Y0DesignSystem.onPrimary,
                  size: 32,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 📋 الحصول على قائمة الأزرار الإضافية
  List<FabAction> _getActionButtons() {
    final defaultActions = [
      FabAction(
        icon: Icons.event,
        label: 'إضافة حدث',
        onTap: widget.onAddEvent,
      ),
      FabAction(
        icon: Icons.notifications,
        label: 'إضافة إشعار',
        onTap: widget.onAddNotification,
      ),
    ];

    if (widget.customActions != null) {
      return [...widget.customActions!, ...defaultActions];
    }

    return defaultActions;
  }

  /// 👇 معالج الضغط على الزر الرئيسي
  void _handleMainFabPress() {
    if (widget.isExpanded) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }
}

/// 🎭 Fab Action Model
/// 
/// نموذج لتمثيل إجراء زر FAB
class FabAction {
  /// أيقونة الإجراء
  final IconData icon;
  
  /// نص الإجراء (للـ accessibility)
  final String label;
  
  /// عند الضغط
  final VoidCallback onTap;

  const FabAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// 🎨 Simple FAB Widget
/// 
/// زر عائم بسيط بدون وظائف متعددة
/// للاستخدام في الحالات التي لا تحتاج إلى أزرار إضافية
class SimpleFab extends StatelessWidget {
  /// أيقونة الزر
  final IconData icon;
  
  /// عند الضغط
  final VoidCallback onPressed;
  
  /// لون الزر (اختياري)
  final Color? color;
  
  /// حجم الزر
  final double size;

  const SimpleFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final fabColor = color ?? context.colorScheme.primary;
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [fabColor, fabColor.withValues(alpha:0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: Y0DesignSystem.floatingShadow,
        ),
        child: Icon(
          icon,
          color: Y0DesignSystem.onPrimary,
          size: size * 0.4,
        ),
      ),
    );
  }
}

/// 🎯 FAB with Badge
/// 
/// زر عائم مع شارة للإشعارات أو العدادات
class FabWithBadge extends StatelessWidget {
  /// أيقونة الزر
  final IconData icon;
  
  /// عند الضغط
  final VoidCallback onPressed;
  
  /// نص الشارة
  final String badgeText;
  
  /// لون الشارة
  final Color? badgeColor;

  const FabWithBadge({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final badgeBgColor = badgeColor ?? context.colorScheme.error;
    
    return Stack(
      children: [
        // الزر الرئيسي
        SimpleFab(
          icon: icon,
          onPressed: onPressed,
        ),
        
        // الشارة
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.colorScheme.surfaceContainerLowest,
                width: 2,
              ),
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                color: Y0DesignSystem.onPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
