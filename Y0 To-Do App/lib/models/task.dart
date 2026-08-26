// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:hive/hive.dart';
import 'task_category.dart';

part 'task.g.dart';

/// نموذج المهمة (Task Model)
/// 
/// يمثل مهمة واحدة في التطبيق مع جميع خصائصها
/// يستخدم Hive للتخزين المحلي
/// 
/// مثال على الاستخدام:
/// ```dart
/// final task = Task(
///   id: '123',
///   title: 'إنهاء المشروع',
///   priority: 2,
///   dueDate: DateTime.now().add(Duration(days: 1)),
/// );
/// ```
/// Sentinel class: يميّز بين "لا قيمة محددة" و null الصريحة في copyWith
class _Unset {
  const _Unset();
}

const _unset = _Unset();

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

  /// أولوية المهمة
  /// - 0: منخفضة (Low)
  /// - 1: متوسطة (Medium)
  /// - 2: عالية (High)
  @HiveField(4)
  int priority;

  /// حالة إنجاز المهمة
  /// - true: مكتملة
  /// - false: قيد التنفيذ
  @HiveField(5)
  bool isDone;

  /// تصنيف المهمة
  /// يساعد في تنظيم المهام حسب النوع (عمل، شخصي، دراسة، صحة، عام)
  @HiveField(6)
  TaskCategory? category;

  /// ترتيب المهمة في القائمة (للسحب والإفلات)
  /// 
  /// قيمة افتراضية: 0 (للبيانات القديمة التي لا تحتوي على هذا الحقل)
  /// يتم تحديثه تلقائياً عند إعادة ترتيب المهام
  @HiveField(7)
  int sortOrder;

  /// Constructor للمهمة
  /// 
  /// [id] معرف فريد للمهمة (مطلوب)
  /// [title] عنوان المهمة (مطلوب)
  /// [note] ملاحظات إضافية (اختياري)
  /// [dueDate] تاريخ الاستحقاق (اختياري)
  /// [priority] الأولوية (افتراضي: 0 - منخفضة)
  /// [isDone] حالة الإنجاز (افتراضي: false)
  /// [category] التصنيف (افتراضي: عام)
  /// [sortOrder] ترتيب العرض (افتراضي: 0)
  Task({
    required this.id,
    required this.title,
    this.note,
    this.dueDate,
    this.priority = 0,
    this.isDone = false,
    this.category = TaskCategory.general,
    this.sortOrder = 0,
  });

  /// Getter للحصول على التصنيف مع قيمة افتراضية آمنة
  TaskCategory get safeCategory => category ?? TaskCategory.general;

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
  /// 
  /// يستخدم لتحديث المهمة دون تعديل النسخة الأصلية
  /// جميع المعاملات اختيارية، إذا لم يتم تمريرها يتم استخدام القيم الحالية
  /// لمسح حقل nullable مثل dueDate أو note، مرّر null صراحةً
  /// 
  /// مثال:
  /// ```dart
  /// final updatedTask = task.copyWith(
  ///   title: 'عنوان جديد',
  ///   dueDate: null,  // يحذف التاريخ
  ///   isDone: true,
  /// );
  /// ```
  Task copyWith({
    String? id,
    String? title,
    Object? note = _unset,
    Object? dueDate = _unset,
    int? priority,
    bool? isDone,
    TaskCategory? category,
    int? sortOrder,
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
      // Backward-compatible: old JSON without sortOrder defaults to 0
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
