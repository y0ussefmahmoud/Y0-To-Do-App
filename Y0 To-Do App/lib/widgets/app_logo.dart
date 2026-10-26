// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import '../l10n/l10n_extension.dart';
import '../theme/y0_design_system.dart';

/// 🌿 Official App Logo Widget
///
/// Renders the official Y0 To-Do App branding asset with smooth scaling,
/// optional elevation shadow, and a graceful vector fallback if the asset
/// is unavailable.
class AppLogo extends StatelessWidget {
  /// Size of the square logo (width and height)
  final double size;

  /// Corner radius for the logo container
  final BorderRadius? borderRadius;

  /// Whether to render a soft ambient shadow
  final bool showShadow;

  /// Custom hero tag if used in hero transitions
  final String? heroTag;

  const AppLogo({
    super.key,
    this.size = 36.0,
    this.borderRadius,
    this.showShadow = false,
    this.heroTag,
  });

  /// Official logo asset path
  static const String assetPath = 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png';

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(size * 0.25);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget logoImage = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildFallback(context, effectiveRadius, isDark),
    );

    if (heroTag != null) {
      logoImage = Hero(tag: heroTag!, child: logoImage);
    }

    if (!showShadow) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: logoImage,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Y0DesignSystem.primaryContainer : Y0DesignSystem.primary)
                .withValues(alpha: 0.18),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: logoImage,
      ),
    );
  }

  Widget _buildFallback(BuildContext context, BorderRadius radius, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: Y0DesignSystem.primaryGradient,
      ),
      child: Center(
        child: Text(
          'Y0',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.45,
            letterSpacing: -1.0,
          ),
        ),
      ),
    );
  }
}

/// 🏷️ App Brand Header Widget
///
/// Standardized header displaying the official AppLogo alongside the stylized
/// app title, supporting RTL/LTR, dark/light themes, and responsive layouts.
class AppBrandHeader extends StatelessWidget {
  /// Logo dimension
  final double logoSize;

  /// Custom text style for the app title
  final TextStyle? titleStyle;

  /// Whether to display the text title alongside the logo
  final bool showTitle;

  /// Whether to show a small version badge (e.g., v1.0.12)
  final bool showVersionBadge;

  const AppBrandHeader({
    super.key,
    this.logoSize = 36.0,
    this.titleStyle,
    this.showTitle = true,
    this.showVersionBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppLogo(
          size: logoSize,
          showShadow: true,
        ),
        if (showTitle) ...[
          const SizedBox(width: 10),
          Text(
            context.l10n.appTitle,
            style: titleStyle ??
                context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFF66BB6A) : context.colorScheme.primary,
                  letterSpacing: -0.5,
                ),
          ),
        ],
        if (showVersionBadge) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF66BB6A) : context.colorScheme.primary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'v1.0.12',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF66BB6A) : context.colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
