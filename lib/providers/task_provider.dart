import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';

/// Provider لصندوق Hive الخاص بالمهام
/// 
/// يوفر الوصول إلى قاعدة البيانات المحلية للمهام
/// يستخدم في جميع أنحاء التطبيق للوصول إلى البيانات
final tasksBoxProvider = Provider<Box<Task>>((ref) {
  final box = Hive.box<Task>('tasksBox');
  return box;
});

/// Provider لمستودع المهام (TaskRepository)
/// 
/// يوفر instance من TaskRepository مع ربطه بـ Hive box
/// يستخدم لإجراء عمليات CRUD على المهام
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final box = ref.watch(tasksBoxProvider);
  return TaskRepository(box);
});

/// StateNotifier لإدارة حالة قائمة المهام
/// 
/// يدير جميع العمليات المتعلقة بالمهام مثل:
/// - إضافة مهمة جديدة
/// - تحديث مهمة موجودة
/// - حذف مهمة
/// - تبديل حالة إنجاز المهمة
/// 
/// يستخدم Repository Pattern للتفاعل مع قاعدة البيانات
class TasksNotifier extends StateNotifier<List<Task>> {
  /// Constructor يستقبل TaskRepository
  /// 
  /// يقوم بتهيئة الحالة الأولية بجميع المهام من قاعدة البيانات
  TasksNotifier(this._repo) : super(_repo.getAll());

  /// مستودع المهام للتفاعل مع قاعدة البيانات
  final TaskRepository _repo;

  /// تحديث قائمة المهام من قاعدة البيانات
  /// 
  /// يتم استدعاؤها بعد كل عملية تعديل لضمان تزامن الحالة
  Future<void> refresh() async {
    state = _repo.getAll();
  }

  /// إضافة مهمة جديدة
  /// 
  /// [task] المهمة المراد إضافتها
  /// 
  /// يقوم بإضافة المهمة إلى قاعدة البيانات ثم تحديث الحالة
  Future<void> add(Task task) async {
    await _repo.add(task);
    await refresh();
  }

  /// تحديث مهمة موجودة
  /// 
  /// [task] المهمة المحدثة
  /// 
  /// يقوم بتحديث المهمة في قاعدة البيانات ثم تحديث الحالة
  Future<void> update(Task task) async {
    await _repo.update(task);
    await refresh();
  }

  /// حذف مهمة
  /// 
  /// [id] معرف المهمة المراد حذفها
  /// 
  /// يقوم بحذف المهمة من قاعدة البيانات ثم تحديث الحالة
  Future<void> delete(String id) async {
    await _repo.delete(id);
    await refresh();
  }

  /// تبديل حالة إنجاز المهمة
  /// 
  /// [id] معرف المهمة المراد تبديل حالتها
  /// 
  /// يحول المهمة من مكتملة إلى غير مكتملة أو العكس
  Future<void> toggleDone(String id) async {
    await _repo.toggleDone(id);
    await refresh();
  }
}

/// Provider الرئيسي لقائمة المهام
/// 
/// يوفر الوصول إلى TasksNotifier وحالة المهام في جميع أنحاء التطبيق
/// 
/// مثال على الاستخدام:
/// ```dart
/// // في Widget
/// final tasks = ref.watch(tasksProvider);
/// final tasksNotifier = ref.read(tasksProvider.notifier);
/// 
/// // إضافة مهمة
/// await tasksNotifier.add(newTask);
/// ```
final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TasksNotifier(repo);
});
