import 'package:hive/hive.dart';

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

  /// Constructor للمهمة
  /// 
  /// [id] معرف فريد للمهمة (مطلوب)
  /// [title] عنوان المهمة (مطلوب)
  /// [note] ملاحظات إضافية (اختياري)
  /// [dueDate] تاريخ الاستحقاق (اختياري)
  /// [priority] الأولوية (افتراضي: 0 - منخفضة)
  /// [isDone] حالة الإنجاز (افتراضي: false)
  Task({
    required this.id,
    required this.title,
    this.note,
    this.dueDate,
    this.priority = 0,
    this.isDone = false,
  });

  /// إنشاء نسخة جديدة من المهمة مع تعديل بعض الخصائص
  /// 
  /// يستخدم لتحديث المهمة دون تعديل النسخة الأصلية
  /// جميع المعاملات اختيارية، إذا لم يتم تمريرها يتم استخدام القيم الحالية
  /// 
  /// مثال:
  /// ```dart
  /// final updatedTask = task.copyWith(
  ///   title: 'عنوان جديد',
  ///   isDone: true,
  /// );
  /// ```
  Task copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? dueDate,
    int? priority,
    bool? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
    );
  }
}
