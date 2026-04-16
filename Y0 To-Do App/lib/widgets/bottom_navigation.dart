import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/y0_design_system.dart';

/// 🧭 Bottom Navigation Bar Widget
/// 
/// شريط التنقل السفلي مع تأثيرات Neo-morphic وتصميم عصري
/// يدعم الوضعين النهاري والليلي وتأثيرات Glassmorphism
/// يتبع نظام التصميم Y0DesignSystem
/// 
/// @author Y0 Development Team
/// @version 3.1.0
class BottomNavigation extends StatefulWidget {
  /// مؤشر التبويب النشط حالياً
  final int currentIndex;
  
  /// عند تغيير التبويب
  final ValueChanged<int> onTap;
  
  /// قائمة عناصر التنقل
  final List<NavigationItem>? items;
  
  /// هل إظهار تسميات العناصر
  final bool showLabels;
  
  /// لون الخلفية (اختياري)
  final Color? backgroundColor;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
    this.showLabels = true,
    this.backgroundColor,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    
    final items = widget.items ?? _getDefaultItems();
    _animationControllers = List.generate(
      items.length,
      (index) => AnimationController(
        duration: Y0DesignSystem.animationMedium,
        vsync: this,
      ),
    );
    
    _scaleAnimations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 1.0,
              end: 1.1,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            )))
        .toList();

    // تفعيل الرسوم المتحركة للعنصر النشط
    _updateAnimations();
  }

  @override
  void didUpdateWidget(BottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _updateAnimations();
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items ?? _getDefaultItems();
    final backgroundColor = widget.backgroundColor ?? 
        context.colorScheme.surfaceContainerLowest.withValues(alpha:0.7);
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha:0.04),
            blurRadius: 40,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.only(
              left: Y0DesignSystem.spacing3,
              right: Y0DesignSystem.spacing3,
              bottom: Y0DesignSystem.spacing3,
              top: Y0DesignSystem.spacing2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              textDirection: TextDirection.rtl,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildNavigationItem(item, index);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// 🧭 عنصر تنقل واحد
  Widget _buildNavigationItem(NavigationItem item, int index) {
    final isActive = index == widget.currentIndex;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleItemTap(index),
        child: AnimatedBuilder(
          animation: _scaleAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Y0DesignSystem.spacing2,
                  vertical: Y0DesignSystem.spacing2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? context.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: context.colorScheme.primary.withValues(alpha:0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الأيقونة
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive
                          ? context.colorScheme.onPrimary
                          : context.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    
                    // التسمية
                    if (widget.showLabels) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isActive
                              ? context.colorScheme.onPrimary
                              : context.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🎯 معالج النقر على عنصر التنقل
  void _handleItemTap(int index) {
    if (index != widget.currentIndex) {
      widget.onTap(index);
    }
  }

  /// 🔄 تحديث الرسوم المتحركة
  void _updateAnimations() {
    for (int i = 0; i < _animationControllers.length; i++) {
      if (i == widget.currentIndex) {
        _animationControllers[i].forward();
      } else {
        _animationControllers[i].reverse();
      }
    }
  }

  /// 📋 العناصر الافتراضية للتنقل
  List<NavigationItem> _getDefaultItems() {
    return const [
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'الرئيسية',
      ),
      NavigationItem(
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights,
        label: 'الإحصائيات',
      ),
      NavigationItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'الإعدادات',
      ),
    ];
  }
}

/// 🧭 Navigation Item Model
/// 
/// نموذج لتمثيل عنصر في شريط التنقل
class NavigationItem {
  /// الأيقونة العادية
  final IconData icon;
  
  /// الأيقونة النشطة
  final IconData activeIcon;
  
  /// تسمية العنصر
  final String label;
  
  /// بادج (اختياري)
  final String? badge;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}

/// 🎨 Modern Bottom Navigation
/// 
/// نسخة محدثة من شريط التنقل مع تأثيرات Neo-morphic متقدمة
class ModernBottomNavigation extends StatefulWidget {
  /// مؤشر التبويب النشط
  final int currentIndex;
  
  /// عند تغيير التبويب
  final ValueChanged<int> onTap;
  
  /// قائمة العناصر
  final List<NavigationItem> items;

  const ModernBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<ModernBottomNavigation> createState() => _ModernBottomNavigationState();
}

class _ModernBottomNavigationState extends State<ModernBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: Y0DesignSystem.animationSlow,
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));

    _backgroundAnimationController.forward();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          transform: Matrix4.translationValues(
            0,
            (1 - _backgroundAnimation.value) * 100,
            0,
          ),
          child: Opacity(
            opacity: _backgroundAnimation.value,
            child: BottomNavigation(
              currentIndex: widget.currentIndex,
              onTap: widget.onTap,
              items: widget.items,
            ),
          ),
        );
      },
    );
  }
}

/// 🎯 Floating Bottom Navigation
/// 
/// شريط تنقل عائم مع تأثيرات Neo-morphic
class FloatingBottomNavigation extends StatelessWidget {
  /// مؤشر التبويب النشط
  final int currentIndex;
  
  /// عند تغيير التبويب
  final ValueChanged<int> onTap;
  
  /// قائمة العناصر
  final List<NavigationItem> items;

  const FloatingBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Y0DesignSystem.spacing3),
      padding: const EdgeInsets.symmetric(
        horizontal: Y0DesignSystem.spacing3,
        vertical: Y0DesignSystem.spacing2,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(Y0DesignSystem.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha:0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha:0.8),
            blurRadius: 20,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        textDirection: TextDirection.rtl,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isActive = index == currentIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Y0DesignSystem.spacing2,
                  vertical: Y0DesignSystem.spacing2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? context.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive
                          ? context.colorScheme.onPrimary
                          : context.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isActive
                            ? context.colorScheme.onPrimary
                            : context.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
