// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../l10n/app_localizations.dart';

part 'task_category.g.dart';

@HiveType(typeId: 2)
enum TaskCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  personal,
  @HiveField(2)
  study,
  @HiveField(3)
  health,
  @HiveField(4)
  general,
  @HiveField(5)
  shopping,
  @HiveField(6)
  entertainment,
}

TaskCategory taskCategoryFromString(String value) {
  try {
    return TaskCategory.values.firstWhere(
      (category) => category.name.toLowerCase() == value.toLowerCase(),
    );
  } catch (e) {
    return TaskCategory.general;
  }
}

extension TaskCategoryExtension on TaskCategory {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case TaskCategory.work:
        return l10n.categoryWork;
      case TaskCategory.personal:
        return l10n.categoryPersonal;
      case TaskCategory.study:
        return l10n.categoryStudy;
      case TaskCategory.health:
        return l10n.categoryHealth;
      case TaskCategory.general:
        return l10n.categoryGeneral;
      case TaskCategory.shopping:
        return l10n.categoryShopping;
      case TaskCategory.entertainment:
        return l10n.categoryEntertainment;
    }
  }

  String get displayName {
    switch (this) {
      case TaskCategory.work:
        return 'عمل';
      case TaskCategory.personal:
        return 'شخصي';
      case TaskCategory.study:
        return 'دراسة';
      case TaskCategory.health:
        return 'صحة';
      case TaskCategory.general:
        return 'عام';
      case TaskCategory.shopping:
        return 'تسوق';
      case TaskCategory.entertainment:
        return 'ترفيه';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.study:
        return Icons.school;
      case TaskCategory.health:
        return Icons.favorite;
      case TaskCategory.general:
        return Icons.category;
      case TaskCategory.shopping:
        return Icons.shopping_cart;
      case TaskCategory.entertainment:
        return Icons.movie;
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.work:
        return const Color(0xFF3B82F6); // أزرق
      case TaskCategory.personal:
        return const Color(0xFF8B5CF6); // بنفسجي
      case TaskCategory.study:
        return const Color(0xFF10B981); // أخضر
      case TaskCategory.health:
        return const Color(0xFFEF4444); // أحمر
      case TaskCategory.general:
        return const Color(0xFF6B7280); // رمادي
      case TaskCategory.shopping:
        return const Color(0xFFF59E0B); // برتقالي
      case TaskCategory.entertainment:
        return const Color(0xFFEC4899); // وردي
    }
  }

  String toStringValue() {
    return name;
  }
}
