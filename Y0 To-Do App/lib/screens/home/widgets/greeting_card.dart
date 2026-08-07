// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/y0_design_system.dart';
import '../../../widgets/neo_morphic_card.dart';
import '../../../providers/settings_provider.dart';

class GreetingCard extends ConsumerWidget {
  const GreetingCard({super.key});

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'صباح الخير، حان وقت بداية يوم إيجابي ومثمر.';
    } else if (hour >= 12 && hour < 17) {
      return 'مساء الخير، حان وقت إنجاز باقي مهامك.';
    } else {
      return 'مساء الخير، حان وقت مراجعة إنجازات يومك.';
    }
  }

  String _getCurrentDateArabic() {
    final now = DateTime.now();
    
    const arabicWeekdays = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    
    const arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    
    String toArabicNumeral(int number) {
      const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      return number.toString().split('').map((d) => arabicNumerals[int.parse(d)]).join('');
    }
    
    final weekday = arabicWeekdays[now.weekday % 7];
    final month = arabicMonths[now.month - 1];
    final day = toArabicNumeral(now.day);
    
    return '$weekday، $day $month';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // التحسين باستخدام select لمراقبة اسم المستخدم فقط وتجنب الـ rebuilds
    final userName = ref.watch(settingsProvider.select((s) => s.userName));

    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'أهلاً بك، $userName!',
                  style: context.textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: Y0DesignSystem.spacing2),
                Text(
                  _getGreetingMessage(),
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Y0DesignSystem.spacing3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Y0DesignSystem.spacing3,
                    vertical: Y0DesignSystem.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        Icons.schedule,
                        color: context.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: Y0DesignSystem.spacing2),
                      Text(
                        _getCurrentDateArabic(),
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
