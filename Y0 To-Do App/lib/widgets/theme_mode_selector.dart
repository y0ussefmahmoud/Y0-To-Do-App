import 'package:flutter/material.dart';

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
    
    return RadioGroup<String>(
      groupValue: currentThemeMode,
      onChanged: (value) {
        if (value == null) return;
        onThemeModeChanged(value);
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختيار وضع الثيم',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Light Theme Option
            _buildThemeOption(
              context,
              title: 'الوضع الفاتح',
              subtitle: 'خلفية بيضاء مع ألوان داكنة',
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
              title: 'الوضع الداكن',
              subtitle: 'خلفية داكنة مع ألوان فاتحة',
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
              title: 'تلقائي',
              subtitle: 'يتبع إعدادات النظام',
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected 
                          ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8) 
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection Indicator
            Radio<String>(
              value: value,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
