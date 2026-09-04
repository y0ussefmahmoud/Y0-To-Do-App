// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:hive/hive.dart';

part 'sub_task.g.dart';

/// نموذج المهمة الفرعية (SubTask Model)
///
/// يمثل بنداً في قائمة التحقق (Checklist) داخل المهمة الرئيسية
@HiveType(typeId: 6)
class SubTask {
  /// معرف فريد للمهمة الفرعية
  @HiveField(0)
  final String id;

  /// عنوان أو نص المهمة الفرعية
  @HiveField(1)
  final String title;

  /// حالة إنجاز المهمة الفرعية
  @HiveField(2)
  final bool isDone;

  const SubTask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isDone,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
    };
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String,
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubTask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          isDone == other.isDone;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ isDone.hashCode;
}
