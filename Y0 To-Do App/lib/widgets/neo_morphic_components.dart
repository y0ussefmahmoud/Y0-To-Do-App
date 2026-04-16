import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../theme/y0_design_system.dart';

/// 🎨 Neo-Morphic Components for Y0 To-Do App
/// 
/// This file contains reusable Neo-morphic components that follow the
/// Editorial Neo-Minimalism design system. All components implement:
/// - No 1px solid borders rule
/// - Surface hierarchy through tonal shifts
/// - Ambient shadows for depth
/// - RTL-optimized layouts
/// - Smooth micro-interactions
/// 
/// @author Y0 Development Team
/// @version 2.4.0
class Y0NeoMorphicComponents {
  Y0NeoMorphicComponents._(); // Private constructor

  // ==================== NEO-MORPHIC CARD ====================
  
  /// 🎴 Neo-Morphic Card - The fundamental building block
  /// 
  /// Creates a soft, elevated card with ambient shadows and surface hierarchy.
  /// Uses the "stacked paper" effect for depth without harsh borders.
  /// 
  /// [child] The content inside the card
  /// [padding] Internal padding (defaults to medium spacing)
  /// [margin] External margin (defaults to no margin)
  /// [onTap] Optional tap callback for interaction
  /// [isFloating] Whether the card should appear to float higher
  /// [backgroundColor] Optional custom background color
  static Widget neoCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    bool isFloating = false,
    Color? backgroundColor,
  }) {
    return Container(
      margin: margin,
      child: Material(
        color: backgroundColor ?? 
               (isFloating ? Y0DesignSystem.surfaceContainerLowest : 
                           Y0DesignSystem.surfaceContainerHighest),
        borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
        elevation: 0, // No elevation - we use ambient shadows
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
          child: Container(
            padding: padding ?? const EdgeInsets.all(Y0DesignSystem.spacing3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
              boxShadow: isFloating ? Y0DesignSystem.floatingShadow : 
                          Y0DesignSystem.ambientShadow,
            ),
            child: child,
          ),
        ),
      ),
    ).animate().fadeIn(duration: Y0DesignSystem.animationMedium);
  }

  // ==================== NEO-MORPHIC BUTTON ====================
  
  /// 🔘 Neo-Morphic Primary Button - Signature gradient button
  /// 
  /// Features the signature gradient (primary to primary-container) at 135°
  /// with subtle glow on hover and smooth press animations.
  /// 
  /// [text] The button text
  /// [onPressed] Required callback for button press
  /// [isLoading] Show loading state
  /// [icon] Optional icon to display with text
  /// [isFullWidth] Whether button should take full width
  /// [height] Custom height (defaults to 48dp)
  static Widget neoPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isFullWidth = false,
    double? height,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 48,
      decoration: BoxDecoration(
        gradient: Y0DesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
        boxShadow: Y0DesignSystem.ambientShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Y0DesignSystem.spacing3),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Y0DesignSystem.onPrimary),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: Y0DesignSystem.onPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: Y0DesignSystem.spacing2),
                        ],
                        Text(
                          text,
                          style: Y0DesignSystem.labelMedium.copyWith(
                            color: Y0DesignSystem.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    ).animate()
     .scale(duration: Y0DesignSystem.animationFast)
     .then()
     .shimmer(duration: Y0DesignSystem.animationSlow, delay: const Duration(seconds: 2));
  }

  // ==================== NEO-MORPHIC GHOST BUTTON ====================
  
  /// 👻 Neo-Morphic Ghost Button - Tertiary button style
  /// 
  /// Text-only button with primary color for high-end editorial feel.
  /// Perfect for secondary actions that need less visual weight.
  /// 
  /// [text] The button text
  /// [onPressed] Required callback for button press
  /// [icon] Optional icon to display with text
  /// [textColor] Custom text color (defaults to primary)
  static Widget neoGhostButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Y0DesignSystem.spacing3,
          vertical: Y0DesignSystem.spacing2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: textColor ?? Y0DesignSystem.primary,
                size: 18,
              ),
              const SizedBox(width: Y0DesignSystem.spacing2),
            ],
            Text(
              text,
              style: Y0DesignSystem.labelMedium.copyWith(
                color: textColor ?? Y0DesignSystem.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate()
     .fadeIn(duration: Y0DesignSystem.animationFast)
     .then()
     .shimmer(duration: Y0DesignSystem.animationSlow, delay: const Duration(seconds: 3));
  }

  // ==================== NEO-MORPHIC INPUT FIELD ====================
  
  /// 📝 Neo-Morphic Input Field - In-set Neo-morphism
  /// 
  /// Features subtle inner shadow with ghost border that transitions
  /// to full opacity primary border on focus. Implements the "No-Line" rule.
  /// 
  /// [controller] Text controller for the input
  /// [hintText] Placeholder text
  /// [labelText] Optional label above the input
  /// [icon] Optional leading icon
  /// [onChanged] Callback for text changes
  /// [obscureText] Whether to hide text (for passwords)
  /// [maxLines] Maximum lines (defaults to 1)
  /// [enabled] Whether the input is enabled
  static Widget neoInputField({
    required TextEditingController controller,
    required String hintText,
    String? labelText,
    IconData? icon,
    Function(String)? onChanged,
    bool obscureText = false,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (labelText != null) ...[
          Text(
            labelText,
            style: Y0DesignSystem.labelMedium.copyWith(
              color: Y0DesignSystem.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: Y0DesignSystem.spacing2),
        ],
        Container(
          decoration: BoxDecoration(
            color: enabled ? Y0DesignSystem.surfaceContainerLow : 
                          Y0DesignSystem.surfaceContainer,
            borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
            boxShadow: Y0DesignSystem.ambientShadow,
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            obscureText: obscureText,
            maxLines: maxLines,
            enabled: enabled,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: Y0DesignSystem.bodyLarge.copyWith(
              color: enabled ? Y0DesignSystem.onSurface : 
                             Y0DesignSystem.onSurfaceVariant,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Y0DesignSystem.bodyLarge.copyWith(
                color: Y0DesignSystem.onSurfaceVariant.withValues(alpha:0.6),
              ),
              prefixIcon: icon != null ? Icon(
                icon,
                color: Y0DesignSystem.onSurfaceVariant,
                size: 20,
              ) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
                borderSide: BorderSide(
                  color: Y0DesignSystem.outlineVariant.withValues(alpha:0.15), // Ghost border
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
                borderSide: BorderSide(
                  color: Y0DesignSystem.outlineVariant.withValues(alpha:0.15), // Ghost border
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
                borderSide: const BorderSide(
                  color: Y0DesignSystem.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(Y0DesignSystem.spacing3),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: Y0DesignSystem.animationFast);
  }

  // ==================== PROGRESS ORB ====================
  
  /// 🔵 Progress Orb - Circular progress indicator
  /// 
  /// Thick, circular "Orb" with soft gradient for project completion.
  /// Adds bespoke, artisanal feel to the dashboard.
  /// 
  /// [progress] Progress value (0.0 to 1.0)
  /// [size] Orb size (defaults to 80)
  /// [strokeWidth] Ring thickness (defaults to 8)
  /// [backgroundColor] Background ring color
  /// [foregroundColor] Progress ring color
  /// [child] Optional child widget in the center
  static Widget progressOrb({
    required double progress,
    double size = 80,
    double strokeWidth = 8,
    Color? backgroundColor,
    Color? foregroundColor,
    Widget? child,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor ?? 
                             Y0DesignSystem.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(
                backgroundColor ?? Y0DesignSystem.surfaceContainerLow,
              ),
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                foregroundColor ?? Y0DesignSystem.primary,
              ),
            ),
          ),
          // Center content
          if (child != null)
            Center(child: child),
        ],
      ),
    ).animate()
     .scale(duration: Y0DesignSystem.animationMedium)
     .then()
     .shimmer(duration: Y0DesignSystem.animationSlow);
  }

  // ==================== GLASSMORPHIC CONTAINER ====================
  
  /// 🌊 Glassmorphic Container - For floating elements
  /// 
  /// Creates a glass-like effect with 70% opacity surface and 24px blur.
  /// Perfect for floating navigation, modals, and overlays.
  /// 
  /// [child] The content inside the container
  /// [padding] Internal padding
  /// [borderRadius] Corner radius (defaults to medium)
  /// [blurAmount] Backdrop blur amount (defaults to 24)
  static Widget glassContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    double blurAmount = 24,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(Y0DesignSystem.radiusMedium),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Y0DesignSystem.glassSurface,
          borderRadius: borderRadius ?? BorderRadius.circular(Y0DesignSystem.radiusMedium),
          border: Border.all(
            color: Y0DesignSystem.outlineVariant.withValues(alpha:0.2),
            width: 1,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: child,
        ),
      ),
    ).animate().fadeIn(duration: Y0DesignSystem.animationMedium);
  }

  // ==================== SURFACE SECTION ====================
  
  /// 📄 Surface Section - Hierarchical content separation
  /// 
  /// Creates a section with proper surface hierarchy without borders.
  /// Uses tonal shifts to define content areas (The "No-Line" Rule).
  /// 
  /// [child] The content inside the section
  /// [surfaceLevel] Surface hierarchy level (0-4)
  /// [padding] Internal padding
  /// [margin] External margin
  static Widget surfaceSection({
    required Widget child,
    int surfaceLevel = 1,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    // Map surface level to color
    Color getSurfaceColor(int level) {
      switch (level) {
        case 0: return Y0DesignSystem.surface;
        case 1: return Y0DesignSystem.surfaceContainerLow;
        case 2: return Y0DesignSystem.surfaceContainer;
        case 3: return Y0DesignSystem.surfaceContainerHigh;
        case 4: return Y0DesignSystem.surfaceContainerHighest;
        default: return Y0DesignSystem.surfaceContainer;
      }
    }

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(Y0DesignSystem.spacing3),
      decoration: BoxDecoration(
        color: getSurfaceColor(surfaceLevel),
        borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
      ),
      child: child,
    ).animate().fadeIn(duration: Y0DesignSystem.animationFast);
  }
}

// ==================== EXTENSIONS ====================

/// 🎨 Extension for easy access to Neo-morphic components
extension Y0NeoMorphicExtension on Widget {
  /// 🎴 Wrap widget in Neo-morphic card
  Widget neoCard({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    bool isFloating = false,
    Color? backgroundColor,
  }) {
    return Y0NeoMorphicComponents.neoCard(
      child: this,
      padding: padding,
      margin: margin,
      onTap: onTap,
      isFloating: isFloating,
      backgroundColor: backgroundColor,
    );
  }

  /// 🌊 Wrap widget in Glassmorphic container
  Widget glassContainer({
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    double blurAmount = 24,
  }) {
    return Y0NeoMorphicComponents.glassContainer(
      child: this,
      padding: padding,
      borderRadius: borderRadius,
      blurAmount: blurAmount,
    );
  }

  /// 📄 Wrap widget in Surface section
  Widget surfaceSection({
    int surfaceLevel = 1,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Y0NeoMorphicComponents.surfaceSection(
      child: this,
      surfaceLevel: surfaceLevel,
      padding: padding,
      margin: margin,
    );
  }
}
