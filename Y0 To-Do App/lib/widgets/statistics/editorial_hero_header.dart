// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import '../../theme/y0_design_system.dart';

class EditorialHeroHeader extends StatelessWidget {
  final int completionRate;
  final bool isDark;

  const EditorialHeroHeader({
    super.key,
    required this.completionRate,
    required this.isDark,
  });

  String _getMotivationalMessage() {
    if (completionRate == 100) {
      return 'إنجاز أسطوري! لقد أكملت 100% من مهامك المخطط لها بنجاح 🎉';
    } else if (completionRate >= 75) {
      return 'أداء ممتاز! لقد أكملت $completionRate% من مهامك وقريب جداً من إنهائها بالكامل 💪';
    } else if (completionRate >= 50) {
      return 'تقدم رائع! أكملت $completionRate% من المهام، واصل العمل لإنجاز البقية 🚀';
    } else if (completionRate > 0) {
      return 'بداية جيدة! أنجزت $completionRate% من خطتك، استمر بنفس العزيمة 🎯';
    } else {
      return 'جاهز للبدء؟ أنجز أولى مهامك اليوم لترتفع نسبة إنجازك 🌟';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'V3.2.8 • نظرة عامة',
          style: context.textTheme.labelMedium?.copyWith(
            color: isDark 
                ? const Color(0xFF66bb6a)
                : context.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Y0DesignSystem.spacing2),
        Text(
          'إحصائيات الإنجاز الأرشيفية',
          style: context.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark 
                ? Colors.white
                : context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: Y0DesignSystem.spacing3),
        Text(
          _getMotivationalMessage(),
          style: context.textTheme.bodyLarge?.copyWith(
            color: isDark 
                ? const Color(0xFFB3B3B3)
                : context.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
