import 'package:flutter/material.dart';

/// 🎨 Y0 To-Do App Design System - Editorial Neo-Minimalism
/// 
/// This file contains the complete design system based on the "Digital Sanctuary" concept.
/// The design system focuses on Neo-morphic soft-focus depth with Editorial Asymmetry.
/// 
/// Key Principles:
/// - No 1px solid borders (The "No-Line" Rule)
/// - Surface hierarchy through tonal shifts
/// - Glassmorphism for floating elements
/// - RTL-optimized typography scale
/// - Ambient shadows instead of harsh shadows
/// 
/// @author Y0 Development Team
/// @version 2.4.0
class Y0DesignSystem {
  Y0DesignSystem._(); // Private constructor for singleton pattern

  // ==================== COLOR SYSTEM ====================
  
  /// 🌱 Primary Color Palette - Botanical Greens for Growth & Calm
  static const Color primary = Color(0xFF126D27); // Deep forest green
  static const Color primaryContainer = Color(0xFF66BB6A); // Fresh green
  static const Color onPrimary = Color(0xFFFFFFFF); // White text on primary
  static const Color onPrimaryContainer = Color(0xFF004814); // Dark green text
  
  /// 🌿 Surface Hierarchy - The "No-Line" Rule Implementation
  /// Surfaces are stacked to create depth without borders
  static const Color surface = Color(0xFFFCF9F8); // Base layer - warm off-white
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Floating elements
  static const Color surfaceContainerLow = Color(0xFFF6F3F2); // Secondary sectioning
  static const Color surfaceContainer = Color(0xFFF1EDEA); // Default container
  static const Color surfaceContainerHigh = Color(0xFFEAE6E3); // Elevated content
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1); // Primary cards
  
  /// 🌙 Dark Mode Surfaces - Based on HTML Dark Mode
  static const Color surfaceDark = Color(0xFF1E1E1E); // Main dark background
  static const Color surfaceContainerLowestDark = Color(0xFF1E1E1E); // Dark floating elements
  static const Color surfaceContainerLowDark = Color(0xFF2D2D2D); // Dark secondary sections
  static const Color surfaceContainerDark = Color(0xFF1E1E1E); // Dark default containers
  static const Color surfaceContainerHighDark = Color(0xFF252525); // Dark elevated content
  static const Color surfaceContainerHighestDark = Color(0xFF333333); // Dark primary cards
  
  /// 📝 Text Colors - High Contrast for Readability
  static const Color onSurface = Color(0xFF1C1C1C); // Main text - warm charcoal
  static const Color onSurfaceVariant = Color(0xFF4A4543); // Secondary text
  static const Color onSurfaceDark = Color(0xFFFFFFFF); // Dark mode main text (pure white)
  static const Color onSurfaceVariantDark = Color(0xFFB3B3B3); // Dark mode secondary (gray)
  
  /// 🎯 Priority Colors - Semantic Color System
  static const Color priorityHigh = Color(0xFFffb4ab); // Light red for dark mode visibility
  static const Color priorityMedium = Color(0xFFFF9800); // Warm orange for normal
  static const Color priorityLow = Color(0xFF4CAF50); // Calm green for low priority
  
  /// 🔵 Accent Colors - Interactive Elements
  static const Color accentBlue = Color(0xFF2196F3); // Interactive blue
  static const Color outlineVariant = Color(0xFFBFCABA); // Ghost border color
  
  // ==================== TYPOGRAPHY SYSTEM ====================
  
  /// 📖 RTL Editorial Typography Scale
  /// Optimized for Arabic script with proper line-height and spacing
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57.0, // 3.5rem - Magazine header feel
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.2, // Tighter for headlines
    color: onSurface,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28.0, // 1.75rem - Clear direction for titles
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.3,
    color: onSurface,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0, // 1rem - Standard for task descriptions
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.6, // Accommodate Arabic ascenders/descenders
    color: onSurface,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0, // 0.75rem - Functional context for metadata
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
    color: onSurfaceVariant,
  );
  
  // ==================== SPACING SYSTEM ====================
  
  /// 📏 Spacing Scale - Based on 8pt grid system
  /// Consistent spacing for visual rhythm
  static const double spacing2 = 8.0;   // Small elements
  static const double spacing3 = 16.0;  // Standard spacing
  static const double spacing4 = 24.0;  // Section separation
  static const double spacing5 = 32.0;  // Major sections
  static const double spacing6 = 48.0;  // Page sections
  static const double spacing7 = 64.0;  // Hero sections
  
  // ==================== CORNER RADIUS SYSTEM ====================
  
  /// 🔄 Corner Radius - Soft Minimalist Aesthetic
  /// No sharp corners - everything feels soft and approachable
  static const double radiusSmall = 8.0;   // 0.5rem - Minimum allowed
  static const double radiusMedium = 16.0; // 1rem - Standard cards
  static const double radiusLarge = 24.0;  // 1.5rem - Important elements
  static const double radiusXLarge = 32.0; // 2rem - Hero elements
  
  // ==================== ELEVATION & SHADOWS ====================
  
  /// 🌫️ Ambient Shadows - Soft, Natural Light
  /// Replaces harsh shadows with ambient, tinted shadows
  static List<BoxShadow> get ambientShadow => [
    BoxShadow(
      color: onSurface.withValues(alpha: 0.04), // 4% opacity
      blurRadius: 40.0,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: onSurface.withValues(alpha: 0.06), // 6% opacity
      blurRadius: 60.0,
      offset: const Offset(0, 16),
    ),
  ];
  
  /// 🌟 Floating Element Shadow - For elevated cards
  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: onSurface.withValues(alpha: 0.08),
      blurRadius: 50.0,
      offset: const Offset(0, 12),
    ),
  ];
  
  // ==================== GRADIENTS ====================
  
  /// 🎨 Signature Gradient - Primary CTAs and Hero Elements
  /// Subtle linear gradient at 135-degree angle
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );
  
  /// 🌊 Glassmorphism Effect - For floating navigation and overlays
  /// Surface at 70% opacity with 24px backdrop blur
  static Color get glassSurface => surface.withValues(alpha: 0.7);
  
  // ==================== ANIMATION DURATIONS ====================
  
  /// ⏱️ Animation Timing - Natural, Spring-like Motion
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // ==================== THEME DATA ====================
  
  /// 🌞 Light Theme - Editorial Neo-Minimalism
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        onPrimary: onPrimary,
        onPrimaryContainer: onPrimaryContainer,
        surface: surface,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outlineVariant: outlineVariant,
      ),
      
      // Typography
      textTheme: const TextTheme(
        displayLarge: displayLarge,
        headlineMedium: headlineMedium,
        bodyLarge: bodyLarge,
        labelMedium: labelMedium,
      ),
      
      // Component Themes
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        color: surfaceContainerHighest,
        shadowColor: Colors.transparent,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing4,
            vertical: spacing3,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return onPrimary.withValues(alpha: 0.1);
              }
              return null;
            },
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(
            color: outlineVariant.withValues(alpha: 0.15), // Ghost border
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(spacing3),
      ),
    );
  }
  
  /// 🌙 Dark Theme - Warm Professional Darkness
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryContainer,
        primaryContainer: primary,
        onPrimary: onPrimary,
        onPrimaryContainer: onPrimaryContainer,
        surface: surfaceDark,
        surfaceContainerLowest: surfaceContainerLowestDark,
        surfaceContainerLow: surfaceContainerLowDark,
        surfaceContainer: surfaceContainerDark,
        surfaceContainerHigh: surfaceContainerHighDark,
        surfaceContainerHighest: surfaceContainerHighestDark,
        onSurface: onSurfaceDark,
        onSurfaceVariant: onSurfaceVariantDark,
        outlineVariant: outlineVariant,
      ),
      
      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57.0,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          height: 1.2,
          color: onSurfaceDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.0,
          height: 1.3,
          color: onSurfaceDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.6,
          color: onSurfaceDark,
        ),
        labelMedium: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.4,
          color: onSurfaceVariantDark,
        ),
      ),
      
      // Component Themes
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        color: surfaceContainerHighestDark,
        shadowColor: Colors.transparent,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing4,
            vertical: spacing3,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return onPrimary.withValues(alpha: 0.1);
              }
              return null;
            },
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(
            color: outlineVariant.withValues(alpha: 0.15), // Ghost border
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: primaryContainer,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(spacing3),
      ),
    );
  }
}

// ==================== EXTENSIONS ====================

/// 🎨 Extension for easy access to design tokens
extension Y0ThemeExtension on BuildContext {
  /// 🎨 Get the current theme
  ThemeData get theme => Theme.of(this);
  
  /// 🎨 Get the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// 🎨 Get the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// 🎨 Check if dark mode is enabled
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// 🎨 Get responsive spacing based on screen size
  double getResponsiveSpacing(double baseSpacing) {
    final screenWidth = MediaQuery.of(this).size.width;
    if (screenWidth < 360) return baseSpacing * 0.8; // Small screens
    if (screenWidth > 600) return baseSpacing * 1.2; // Tablets
    return baseSpacing; // Default
  }
  
  /// 🎨 Get responsive font size
  double getResponsiveFontSize(double baseFontSize) {
    final screenWidth = MediaQuery.of(this).size.width;
    if (screenWidth < 360) return baseFontSize * 0.9; // Small screens
    if (screenWidth > 600) return baseFontSize * 1.1; // Tablets
    return baseFontSize; // Default
  }
}
