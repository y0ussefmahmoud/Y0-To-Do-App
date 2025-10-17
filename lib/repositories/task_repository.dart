import 'package:hive/hive.dart';

import '../models/task.dart';

/// مستودع المهام (Task Repository)
/// 
/// يدير جميع عمليات قاعدة البيانات المتعلقة بالمهام
/// يستخدم Hive كقاعدة بيانات محلية
/// 
/// هذا الكلاس يطبق نمط Repository Pattern لفصل منطق البيانات
/// عن منطق العرض (UI)
/// 
/// مثال على الاستخدام:
/// ```dart
/// final box = Hive.box<Task>('tasksBox');
/// final repository = TaskRepository(box);
/// 
/// // إضافة مهمة جديدة
/// await repository.add(newTask);
/// 
/// // الحصول على جميع المهام
/// final tasks = repository.getAll();
/// ```
class TaskRepository {
  /// Constructor يستقبل Hive box للمهام
  /// 
  /// [_box] صندوق Hive الذي يحتوي على المهام
  TaskRepository(this._box);

  /// صندوق Hive الخاص بالمهام
  final Box<Task> _box;

  /// الحصول على جميع المهام من قاعدة البيانات
  /// 
  /// Returns: قائمة بجميع المهام المخزنة
  /// 
  /// مثال:
  /// ```dart
  /// final allTasks = repository.getAll();
  /// print('عدد المهام: ${allTasks.length}');
  /// ```
  List<Task> getAll() {
    return _box.values.toList();
  }

  /// إضافة مهمة جديدة إلى قاعدة البيانات
  /// 
  /// [task] المهمة المراد إضافتها
  /// 
  /// يستخدم معرف المهمة (task.id) كمفتاح في Hive
  /// 
  /// مثال:
  /// ```dart
  /// final newTask = Task(
  ///   id: uuid.v4(),
  ///   title: 'مهمة جديدة',
  /// );
  /// await repository.add(newTask);
  /// ```
  Future<void> add(Task task) async {
    await _box.put(task.id, task);
  }

  /// تحديث مهمة موجودة في قاعدة البيانات
  /// 
  /// [task] المهمة المراد تحديثها (يجب أن تحتوي على نفس الـ id)
  /// 
  /// إذا كانت المهمة غير موجودة، سيتم إضافتها
  /// 
  /// مثال:
  /// ```dart
  /// final updatedTask = existingTask.copyWith(
  ///   title: 'عنوان محدث',
  /// );
  /// await repository.update(updatedTask);
  /// ```
  Future<void> update(Task task) async {
    await _box.put(task.id, task);
  }

  /// حذف مهمة من قاعدة البيانات
  /// 
  /// [id] معرف المهمة المراد حذفها
  /// 
  /// إذا كانت المهمة غير موجودة، لن يحدث شيء
  /// 
  /// مثال:
  /// ```dart
  /// await repository.delete('task-id-123');
  /// ```
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// تبديل حالة إنجاز المهمة (مكتملة/غير مكتملة)
  /// 
  /// [id] معرف المهمة المراد تبديل حالتها
  /// 
  /// إذا كانت المهمة مكتملة، ستصبح غير مكتملة والعكس صحيح
  /// إذا كانت المهمة غير موجودة، لن يحدث شيء
  /// 
  /// مثال:
  /// ```dart
  /// // تحويل المهمة من غير مكتملة إلى مكتملة أو العكس
  /// await repository.toggleDone('task-id-123');
  /// ```
  Future<void> toggleDone(String id) async {
    final task = _box.get(id);
    if (task != null) {
      await _box.put(id, task.copyWith(isDone: !task.isDone));
    }
  }
}
