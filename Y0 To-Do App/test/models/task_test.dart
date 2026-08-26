// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter_test/flutter_test.dart';
import 'package:y0_todo_app/models/task.dart';
import 'package:y0_todo_app/models/task_category.dart';

/// 🧪 Unit Tests for Task Model
/// 
/// Tests the Task model's functionality including v3.3.0 additions:
///   - sortOrder field default value and backward compat
///   - isArchived logic (completed, overdue > 30 days, pending <= 30 days)
///   - copyWith with sortOrder
///   - toJson / fromJson round-trip
///
/// @author Y0 Development Team
/// @version 3.3.0
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

    // ── v3.3.0: Specific Archive Criteria Verification ─────────────────────

    test('1. Task completed 1 day ago -> isArchived == true', () {
      final completedTask = Task(
        id: 't-comp-1',
        title: 'Completed Yesterday',
        isDone: true,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(completedTask.isArchived, isTrue);
    });

    test('2. Task pending with due date 31 days ago -> isArchived == true', () {
      final overdueTask = Task(
        id: 't-overdue-31',
        title: 'Pending 31 Days Overdue',
        isDone: false,
        dueDate: DateTime.now().subtract(const Duration(days: 31)),
      );
      expect(overdueTask.isArchived, isTrue);
    });

    test('3. Task pending with due date 10 days ago -> isArchived == false (Stays in Home view)', () {
      final pendingTask = Task(
        id: 't-pending-10',
        title: 'Pending 10 Days Overdue',
        isDone: false,
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(pendingTask.isArchived, isFalse);
    });

    test('Task pending with no dueDate -> isArchived == false', () {
      final task = Task(id: 't5', title: 'No due date', isDone: false);
      expect(task.isArchived, isFalse);
    });

    test('Task pending due in the future -> isArchived == false', () {
      final task = Task(
        id: 't-future',
        title: 'Due in future',
        isDone: false,
        dueDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(task.isArchived, isFalse);
    });

    // ── v3.3.0: sortOrder Tests ─────────────────────────────────────────────

    test('sortOrder defaults to 0 when not specified', () {
      final task = Task(id: 't1', title: 'No sortOrder specified');
      expect(task.sortOrder, equals(0));
    });

    test('sortOrder is set correctly when specified', () {
      final task = Task(id: 't2', title: 'With sortOrder', sortOrder: 5);
      expect(task.sortOrder, equals(5));
    });

    test('copyWith preserves sortOrder when not provided', () {
      final task = Task(id: 't3', title: 'Original', sortOrder: 3);
      final copy = task.copyWith(title: 'Updated');
      expect(copy.sortOrder, equals(3));
    });

    test('copyWith updates sortOrder when provided', () {
      final task = Task(id: 't4', title: 'Original', sortOrder: 1);
      final copy = task.copyWith(sortOrder: 10);
      expect(copy.sortOrder, equals(10));
    });

    // ── v3.3.0: toJson / fromJson round-trip ───────────────────────────────

    test('toJson / fromJson round-trip preserves sortOrder', () {
      final original = Task(
        id: 'rt1',
        title: 'Round-trip task',
        priority: 1,
        isDone: false,
        sortOrder: 7,
        category: TaskCategory.study,
        dueDate: DateTime(2026, 9, 1),
      );

      final json = original.toJson();
      final restored = Task.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.sortOrder, equals(7));
      expect(restored.priority, equals(1));
      expect(restored.category, equals(TaskCategory.study));
    });

    test('fromJson sets sortOrder=0 when key is missing (backward compat)', () {
      final json = <String, dynamic>{
        'id': 'old-task',
        'title': 'Legacy Task',
        'priority': 0,
        'isDone': false,
        'category': 'general',
      };

      final task = Task.fromJson(json);
      expect(task.sortOrder, equals(0));
    });
  });
}
