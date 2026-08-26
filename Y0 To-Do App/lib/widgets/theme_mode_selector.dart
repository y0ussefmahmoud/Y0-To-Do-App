// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import '../l10n/l10n_extension.dart';

class ThemeModeSelector extends StatelessWidget {
  final String currentThemeMode;
  final Function(String) onThemeModeChanged;

  const ThemeModeSelector({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.themeSelectTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Light Theme Option
          _buildThemeOption(
            context,
            title: context.l10n.themeLight,
            subtitle: context.l10n.themeLight,
            icon: Icons.light_mode,
            value: 'light',
            isSelected: currentThemeMode == 'light',
            previewColor: Colors.white,
            previewBorderColor: Colors.grey[300]!,
          ),
          
          const SizedBox(height: 12),
          
          // Dark Theme Option
          _buildThemeOption(
            context,
            title: context.l10n.themeDark,
            subtitle: context.l10n.themeDark,
            icon: Icons.dark_mode,
            value: 'dark',
            isSelected: currentThemeMode == 'dark',
            previewColor: const Color(0xFF1E293B),
            previewBorderColor: Colors.grey[600]!,
          ),
          
          const SizedBox(height: 12),
          
          // System Theme Option
          _buildThemeOption(
            context,
            title: context.l10n.themeSystem,
            subtitle: context.l10n.themeSystem,
            icon: Icons.brightness_auto,
            value: 'system',
            isSelected: currentThemeMode == 'system',
            previewColor: theme.brightness == Brightness.dark 
                ? const Color(0xFF1E293B) 
                : Colors.white,
            previewBorderColor: theme.brightness == Brightness.dark 
                ? Colors.grey[600]! 
                : Colors.grey[300]!,
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required bool isSelected,
    required Color previewColor,
    required Color previewBorderColor,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => onThemeModeChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer 
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Theme Preview
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: previewColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: previewBorderColor),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Theme Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? theme.colorScheme.onPrimaryContainer 
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection Indicator
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
