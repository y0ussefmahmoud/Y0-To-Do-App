import 'package:flutter_test/flutter_test.dart';
import 'package:y0_todo_app/models/task.dart';
import 'package:y0_todo_app/models/task_category.dart';

/// 🧪 Unit Tests for Task Model
/// 
/// Tests the Task model's functionality.
/// 
/// @author Y0 Development Team
/// @version 3.2.5
void main() {
  group('Task Model Tests', () {
    test('Task should be created with valid parameters', () {
      final task = Task(
        id: 'test-1',
        title: 'Test Task',
        note: 'Test Note',
        dueDate: DateTime.now(),
        priority: 2,
        isDone: false,
        category: TaskCategory.work,
      );

      expect(task.id, equals('test-1'));
      expect(task.title, equals('Test Task'));
      expect(task.note, equals('Test Note'));
      expect(task.priority, equals(2));
      expect(task.isDone, isFalse);
      expect(task.category, equals(TaskCategory.work));
    });

    test('Task copyWith should create a new instance with updated values', () {
      final task = Task(
        id: 'test-1',
        title: 'Original Title',
        priority: 2,
        isDone: false,
        category: TaskCategory.work,
      );

      final updatedTask = task.copyWith(
        title: 'Updated Title',
        isDone: true,
      );

      expect(updatedTask.id, equals(task.id));
      expect(updatedTask.title, equals('Updated Title'));
      expect(updatedTask.isDone, isTrue);
      expect(updatedTask.priority, equals(task.priority));
    });

    test('Task safeCategory should return default when category is null', () {
      final task = Task(
        id: 'test-1',
        title: 'Test Task',
        priority: 2,
        isDone: false,
      );

      expect(task.safeCategory, equals(TaskCategory.general));
    });

    test('Task safeCategory should return category when not null', () {
      final task = Task(
        id: 'test-1',
        title: 'Test Task',
        priority: 2,
        isDone: false,
        category: TaskCategory.work,
      );

      expect(task.safeCategory, equals(TaskCategory.work));
    });
  });
}
