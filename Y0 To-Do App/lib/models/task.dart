// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:hive/hive.dart';
import 'task_category.dart';
import 'recurrence_rule.dart';
import 'sub_task.dart';

part 'task.g.dart';

/// Sentinel class: يميّز بين "لا قيمة محددة" و null الصريحة في copyWith
class _Unset {
  const _Unset();
}

const _unset = _Unset();

/// نموذج المهمة (Task Model)
/// 
/// يمثل مهمة واحدة في التطبيق مع جميع خصائصها وتفرعاتها
/// يستخدم Hive للتخزين المحلي المشفر
@HiveType(typeId: 1)
class Task {
  /// معرف فريد للمهمة (UUID)
  @HiveField(0)
  final String id;

  /// عنوان المهمة (مطلوب)
  @HiveField(1)
  String title;

  /// ملاحظات إضافية عن المهمة (اختياري)
  @HiveField(2)
  String? note;

  /// تاريخ استحقاق المهمة (اختياري)
  @HiveField(3)
  DateTime? dueDate;

  /// أولوية المهمة (0: منخفضة، 1: متوسطة، 2: عالية)
  @HiveField(4)
  int priority;

  /// حالة إنجاز المهمة (true: مكتملة، false: قيد التنفيذ)
  @HiveField(5)
  bool isDone;

  /// تصنيف المهمة
  @HiveField(6)
  TaskCategory? category;

  /// ترتيب المهمة في القائمة (للسحب والإفلات)
  @HiveField(7)
  int sortOrder;

  /// قاعدة تكرار المهمة (اختياري)
  @HiveField(8)
  RecurrenceRule? recurrenceRule;

  /// المهام الفرعية / قائمة التحقق (Checklist)
  @HiveField(9)
  List<SubTask> subtasks;

  /// الوسوم والكلمات الدلالية المخصصة
  @HiveField(10)
  List<String> tags;

  /// وقت إكمال المهمة الفعلي
  @HiveField(13)
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.note,
    this.dueDate,
    this.priority = 0,
    this.isDone = false,
    this.category = TaskCategory.general,
    this.sortOrder = 0,
    this.recurrenceRule,
    this.subtasks = const [],
    this.tags = const [],
    this.completedAt,
  });

  /// Getter للحصول على التصنيف مع قيمة افتراضية آمنة
  TaskCategory get safeCategory => category ?? TaskCategory.general;

  /// هل المهمة متكررة دورياً؟
  bool get isRecurring => recurrenceRule != null;

  /// عدد المهام الفرعية المكتملة
  int get completedSubtasksCount => subtasks.where((s) => s.isDone).length;

  /// نسبة إنجاز المهام الفرعية (0.0 إلى 1.0)
  double get subtasksProgress =>
      subtasks.isEmpty ? 0.0 : completedSubtasksCount / subtasks.length;

  /// التحقق مما إذا كانت المهمة ينطبق عليها شرط الأرشيف
  /// المهمة تعتبر مؤرشفة إذا كانت:
  /// 1. مكتملة (isDone == true)
  /// 2. أو متأخرة بأكثر من 30 يوماً عن تاريخ استحقاقها (inDays > 30)
  bool get isArchived {
    if (isDone) return true;
    if (dueDate != null) {
      return DateTime.now().difference(dueDate!).inDays > 30;
    }
    return false;
  }

  /// إنشاء نسخة جديدة من المهمة مع تعديل بعض الخصائص
  Task copyWith({
    String? id,
    String? title,
    Object? note = _unset,
    Object? dueDate = _unset,
    int? priority,
    bool? isDone,
    TaskCategory? category,
    int? sortOrder,
    Object? recurrenceRule = _unset,
    List<SubTask>? subtasks,
    List<String>? tags,
    Object? completedAt = _unset,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note is _Unset ? this.note : note as String?,
      dueDate: dueDate is _Unset ? this.dueDate : dueDate as DateTime?,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
      recurrenceRule: recurrenceRule is _Unset
          ? this.recurrenceRule
          : recurrenceRule as RecurrenceRule?,
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
      completedAt: completedAt is _Unset ? this.completedAt : completedAt as DateTime?,
    );
  }

  /// Convert Task to JSON for backup
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'isDone': isDone,
      'category': category?.name,
      'sortOrder': sortOrder,
      'recurrenceRule': recurrenceRule?.toJson(),
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'tags': tags,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Create Task from JSON for restore
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      note: json['note'] as String?,
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      priority: json['priority'] as int? ?? 0,
      isDone: json['isDone'] as bool? ?? false,
      category: json['category'] != null
          ? TaskCategory.values.firstWhere(
              (e) => e.name == json['category'] as String,
              orElse: () => TaskCategory.general,
            )
          : TaskCategory.general,
      sortOrder: json['sortOrder'] as int? ?? 0,
      recurrenceRule: json['recurrenceRule'] != null
          ? RecurrenceRule.fromJson(json['recurrenceRule'] as Map<String, dynamic>)
          : null,
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
