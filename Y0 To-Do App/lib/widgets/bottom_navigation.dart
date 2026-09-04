// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'dart:ui';
import 'package:flutter/material.dart';
import '../l10n/l10n_extension.dart';
import '../theme/y0_design_system.dart';

/// 🧭 Bottom Navigation Bar Widget
class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItem>? items;
  final bool showLabels;
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
    _animationControllers = List.generate(
      3,
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
    final items = widget.items ?? _getDefaultItems(context);
    final backgroundColor = widget.backgroundColor ?? 
        context.colorScheme.surfaceContainerLowest.withValues(alpha: 0.7);
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha: 0.04),
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

  Widget _buildNavigationItem(NavigationItem item, int index) {
    final isActive = index == widget.currentIndex;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleItemTap(index),
        child: AnimatedBuilder(
          animation: _scaleAnimations[index.clamp(0, _scaleAnimations.length - 1)],
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index.clamp(0, _scaleAnimations.length - 1)].value,
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
                            color: context.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
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

  void _handleItemTap(int index) {
    if (index != widget.currentIndex) {
      widget.onTap(index);
    }
  }

  void _updateAnimations() {
    for (int i = 0; i < _animationControllers.length; i++) {
      if (i == widget.currentIndex) {
        _animationControllers[i].forward();
      } else {
        _animationControllers[i].reverse();
      }
    }
  }

  List<NavigationItem> _getDefaultItems(BuildContext context) {
    return [
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: context.l10n.navHome,
      ),
      NavigationItem(
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights,
        label: context.l10n.navStatistics,
      ),
      NavigationItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: context.l10n.navSettings,
      ),
    ];
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? badge;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}
