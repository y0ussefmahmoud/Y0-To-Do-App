// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';

class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String label;
  final String? tooltip;
  final double iconSize;
  final Color? color;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.tooltip,
    this.iconSize = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: IconButton(
            onPressed: onPressed,
            tooltip: tooltip ?? label,
            icon: Icon(icon, size: iconSize, color: color),
          ),
        ),
      ),
    );
  }
}
