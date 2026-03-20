import 'package:hive/hive.dart';

import '../models/task.dart';
import '../utils/error_handler.dart';

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
  /// Throws: [StorageException] في حالة فشل القراءة
  /// 
  /// مثال:
  /// ```dart
  /// final allTasks = repository.getAll();
  /// print('عدد المهام: ${allTasks.length}');
  /// ```
  List<Task> getAll() {
    try {
      return _box.values.toList();
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace, context: 'TaskRepository.getAll');
      throw StorageException('getAll', 'Failed to read tasks from storage: $e');
    }
  }

  /// إضافة مهمة جديدة إلى قاعدة البيانات
  /// 
  /// [task] المهمة المراد إضافتها
  /// 
  /// يستخدم معرف المهمة (task.id) كمفتاح في Hive
  /// Throws: [StorageException] في حالة فشل الإضافة
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
    try {
      if (task.id.isEmpty) {
        throw TaskRepositoryException('Task ID cannot be empty');
      }
      
      if (task.title.isEmpty) {
        throw TaskRepositoryException('Task title cannot be empty');
      }
      
      await _box.put(task.id, task);
      ErrorHandler.logSuccess('Task added to storage: ${task.title}');
    } catch (e, stackTrace) {
      if (e is TaskRepositoryException) {
        ErrorHandler.handleError(e, stackTrace, context: 'TaskRepository.add.validation');
        rethrow;
      }
      
      ErrorHandler.handleError(e, stackTrace, context: 'TaskRepository.add');
      throw StorageException('add', 'Failed to add task to storage: $e');
    }
  }

  /// تحديث مهمة موجودة في قاعدة البيانات
  /// 
  /// [task] المهمة المراد تحديثها (يجب أن تحتوي على نفس الـ id)
  /// 
  /// إذا كانت المهمة غير موجودة، سيتم إضافتها
  /// Throws: [StorageException] في حالة فشل التحديث
  /// 
  /// مثال:
  /// ```dart
  /// final updatedTask = existingTask.copyWith(
  ///   title: 'عنوان محدث',
  /// );
  /// await repository.update(updatedTask);
  /// ```
  Future<void> update(Task task) async {
    try {
      if (task.id.isEmpty) {
        throw TaskRepositoryException('Task ID cannot be empty');
      }
      
      if (task.title.isEmpty) {
        throw TaskRepositoryException('Task title cannot be empty');
      }
      
      // التحقق من وجود المهمة
      final existingTask = _box.get(task.id);
      if (existingTask == null) {
        throw TaskNotFoundException(task.id);
      }
      
      await _box.put(task.id, task);
      ErrorHandler.logSuccess('Task updated in storage: ${task.title}');
    } catch (e, stackTrace) {
      if (e is TaskRepositoryException || e is TaskNotFoundException) {
        ErrorHandler.handleError(e, stackTrace, context: 'TaskRepository.update.validation');
        rethrow;
      }
      
      ErrorHandler.handleError(e, stackTrace, context: 'TaskRepository.update');
      throw StorageException('update', 'Failed to update task in storage: $e');
    }
  }

  /// حذف مهمة من قاعدة البيانات
  /// 
  /// [id] معرف المهمة المراد حذفها
  /// 
  /// Throws: [TaskNotFoundException] إذا كانت المهمة غير موجودة
  /// Throws: [StorageException] في حالة فشل الحذف
  /// 
  /// مثال:
  /// ```dart
  /// await repository.delete('task-id-123');
  /// ```
  Future<void> delete(String id) async {
    try {
      if (id.isEmpty) {
        throw TaskRepositoryException('Task ID cannot be empty');
      }
      
      // التحقق من وجود المهمة
      final existingTask = _box.get(id);
      if (existingTask == null) {
        throw TaskNotFoundException(id);
      }
      
      await _box.delete(id);
      ErrorHandler.logSuccess('Task deleted from storage: $id');
    } catch (e, stackTrace) {
      if (e is TaskRepositoryException || e is TaskNotFoundException) {
        ErrorHandler.handleError(e, stackTrace, context: 'TaskRepository.delete.validation');
        rethrow;
      }
      
      ErrorHandler.handleError(e, stackTrace, context: 'TaskRepository.delete');
      throw StorageException('delete', 'Failed to delete task from storage: $e');
    }
  }

  /// تبديل حالة إنجاز المهمة (مكتملة/غير مكتملة)
  /// 
  /// [id] معرف المهمة المراد تبديل حالتها
  /// 
  /// Throws: [TaskNotFoundException] إذا كانت المهمة غير موجودة
  /// Throws: [StorageException] في حالة فشل التحديث
  /// 
  /// مثال:
  /// ```dart
  /// // تحويل المهمة من غير مكتملة إلى مكتملة أو العكس
  /// await repository.toggleDone('task-id-123');
  /// ```
  Future<void> toggleDone(String id) async {
    try {
      if (id.isEmpty) {
        throw TaskRepositoryException('Task ID cannot be empty');
      }
      
      final task = _box.get(id);
      if (task == null) {
        throw TaskNotFoundException(id);
      }
      
      await _box.put(id, task.copyWith(isDone: !task.isDone));
      ErrorHandler.logSuccess('Task status toggled in storage: $id');
    } catch (e, stackTrace) {
      if (e is TaskRepositoryException || e is TaskNotFoundException) {
        ErrorHandler.handleError(e, stackTrace, context: 'TaskRepository.toggleDone.validation');
        rethrow;
      }
      
      ErrorHandler.handleError(e, stackTrace, context: 'TaskRepository.toggleDone');
      throw StorageException('toggleDone', 'Failed to toggle task status in storage: $e');
    }
  }
}
