// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import '../../theme/y0_design_system.dart';
import '../../widgets/neo_morphic_card.dart';

class AchievementBadges extends StatelessWidget {
  final int completedTasks;
  final bool isDark;

  const AchievementBadges({
    super.key,
    required this.completedTasks,
    required this.isDark,
  });

  Widget _buildAchievementBadge(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool isUnlocked,
  ) {
    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing3),
      width: 112,
      color: isDark ? const Color(0xFF1E1E1E) : null,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked 
                  ? color.withValues(alpha: 0.2)
                  : (isDark 
                      ? const Color(0xFF313030)
                      : Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? color : (isDark ? const Color(0xFFB3B3B3) : Colors.grey),
              size: 32,
              fill: isUnlocked ? 1 : 0,
            ),
          ),
          const SizedBox(height: Y0DesignSystem.spacing2),
          Text(
            title,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isUnlocked 
                  ? (isDark ? Colors.white : context.colorScheme.onSurface)
                  : (isDark 
                      ? const Color(0xFFB3B3B3).withValues(alpha: 0.4)
                      : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              child: Row(
                textDirection: TextDirection.rtl,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF66bb6a) : context.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_left,
                    color: isDark ? const Color(0xFF66bb6a) : context.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
            Flexible(
              child: Text(
                'أوسمة الإنجاز',
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : context.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Y0DesignSystem.spacing3),
        Wrap(
          spacing: Y0DesignSystem.spacing3,
          runSpacing: Y0DesignSystem.spacing3,
          alignment: WrapAlignment.end,
          children: [
            _buildAchievementBadge(
              context,
              'البداية القوية',
              Icons.star,
              isDark ? Colors.yellow : Colors.amber,
              completedTasks >= 1,
            ),
            _buildAchievementBadge(
              context,
              'قناص المهام',
              Icons.workspace_premium,
              isDark ? Colors.blue.shade400 : Colors.blue,
              completedTasks >= 10,
            ),
            _buildAchievementBadge(
              context,
              'بطل الإنجاز',
              Icons.emoji_events,
              isDark ? Colors.green.shade400 : Colors.green,
              completedTasks >= 50,
            ),
            _buildAchievementBadge(
              context,
              'الأسطورة',
              Icons.workspace_premium,
              isDark ? Colors.purple.shade400 : Colors.purple,
              completedTasks >= 100,
            ),
          ],
        ),
      ],
    );
  }
}
