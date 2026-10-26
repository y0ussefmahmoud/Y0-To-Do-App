// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter_test/flutter_test.dart';
import 'package:y0_todo_app/models/task.dart';
import 'package:y0_todo_app/models/task_category.dart';
import 'package:y0_todo_app/models/sub_task.dart';
import 'package:y0_todo_app/models/recurrence_rule.dart';
import 'package:y0_todo_app/models/task_filter.dart';

/// 🧪 Unit Tests for Task Model
/// 
/// Tests the Task model's functionality including v3.3.0 additions:
///   - sortOrder field default value and backward compat
///   - isArchived logic (completed, overdue > 30 days, pending <= 30 days)
///   - copyWith with sortOrder
///   - toJson / fromJson round-trip
///
/// @author Y0 Tech Solutions
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

    // ── v3.4.0: SubTasks & Recurrence Tests ─────────────────────────────────

    test('Task subtasks defaults to empty list and getters calculate correctly', () {
      final taskWithoutSubtasks = Task(id: 'ts1', title: 'Task without subtasks');
      expect(taskWithoutSubtasks.subtasks, isEmpty);
      expect(taskWithoutSubtasks.completedSubtasksCount, equals(0));
      expect(taskWithoutSubtasks.subtasksProgress, equals(0.0));

      final sub1 = SubTask(id: 's1', title: 'Subtask 1', isDone: true);
      final sub2 = SubTask(id: 's2', title: 'Subtask 2', isDone: false);
      final taskWithSubtasks = Task(
        id: 'ts2',
        title: 'Task with subtasks',
        subtasks: [sub1, sub2],
      );

      expect(taskWithSubtasks.subtasks.length, equals(2));
      expect(taskWithSubtasks.completedSubtasksCount, equals(1));
      expect(taskWithSubtasks.subtasksProgress, equals(0.5));
    });

    test('Task isRecurring getter works based on recurrenceRule presence', () {
      final normalTask = Task(id: 't-normal', title: 'Normal Task');
      expect(normalTask.isRecurring, isFalse);

      final recurringTask = Task(
        id: 't-rec',
        title: 'Recurring Task',
        recurrenceRule: RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          interval: 1,
        ),
      );
      expect(recurringTask.isRecurring, isTrue);
    });

    test('Task completedAt field can be set and preserved in copyWith', () {
      final now = DateTime.now();
      final task = Task(id: 't-comp', title: 'Completed', completedAt: now);
      expect(task.completedAt, equals(now));

      final copy = task.copyWith(title: 'Updated Title');
      expect(copy.completedAt, equals(now));
    });

    test('Task toJson / fromJson round-trip preserves v3.4.0 fields', () {
      final task = Task(
        id: 't-v340',
        title: 'v3.4.0 Task',
        recurrenceRule: RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          interval: 2,
        ),
        subtasks: [
          SubTask(id: 's10', title: 'Sub 1', isDone: true),
          SubTask(id: 's20', title: 'Sub 2', isDone: false),
        ],
        tags: ['urgent', 'project'],
        completedAt: DateTime(2026, 9, 4, 12, 0),
      );

      final json = task.toJson();
      final restored = Task.fromJson(json);

      expect(restored.isRecurring, isTrue);
      expect(restored.recurrenceRule?.frequency, equals(RecurrenceFrequency.weekly));
      expect(restored.recurrenceRule?.interval, equals(2));
      expect(restored.subtasks.length, equals(2));
      expect(restored.subtasks[0].isDone, isTrue);
      expect(restored.subtasks[1].title, equals('Sub 2'));
      expect(restored.tags, containsAll(['urgent', 'project']));
      expect(restored.completedAt, equals(DateTime(2026, 9, 4, 12, 0)));
    });

    // ── v3.4.1: hasTime & Hour/Time-Based Scheduling Tests ──────────────────

    test('Task hasTime returns false when dueDate is null or 00:00', () {
      final noDueDateTask = Task(id: 't-notime-1', title: 'No due date');
      expect(noDueDateTask.hasTime, isFalse);

      final dateOnlyTask = Task(
        id: 't-notime-2',
        title: 'Date only',
        dueDate: DateTime(2026, 9, 25, 0, 0),
      );
      expect(dateOnlyTask.hasTime, isFalse);
    });

    test('Task hasTime returns true when dueDate has non-zero hour or minute', () {
      final taskWithHour = Task(
        id: 't-time-1',
        title: 'With 10 AM',
        dueDate: DateTime(2026, 9, 25, 10, 0),
      );
      expect(taskWithHour.hasTime, isTrue);

      final taskWithMinute = Task(
        id: 't-time-2',
        title: 'With 00:30',
        dueDate: DateTime(2026, 9, 25, 0, 30),
      );
      expect(taskWithMinute.hasTime, isTrue);
    });

    test('Tasks for the same day sort chronologically by scheduled time', () {
      final taskMorning = Task(
        id: 't-morning',
        title: 'Morning Meeting',
        dueDate: DateTime(2026, 9, 25, 9, 30),
      );
      final taskEvening = Task(
        id: 't-evening',
        title: 'Evening Review',
        dueDate: DateTime(2026, 9, 25, 18, 0),
      );
      final taskAfternoon = Task(
        id: 't-afternoon',
        title: 'Lunch with Client',
        dueDate: DateTime(2026, 9, 25, 13, 15),
      );
      final taskAllDay = Task(
        id: 't-allday',
        title: 'All Day Task',
        dueDate: DateTime(2026, 9, 25, 0, 0),
      );

      final list = [taskEvening, taskAllDay, taskMorning, taskAfternoon];

      list.sort((a, b) {
        if (a.hasTime && b.hasTime) {
          return a.dueDate!.compareTo(b.dueDate!);
        } else if (a.hasTime && !b.hasTime) {
          return -1;
        } else if (!a.hasTime && b.hasTime) {
          return 1;
        }
        return 0;
      });

      expect(list.map((t) => t.id).toList(), [
        't-morning',
        't-afternoon',
        't-evening',
        't-allday',
      ]);
    });

    // ── v3.5.0: Tags & TaskFilter Tests ───────────────────────────────────

    test('Task supports custom tags and copyWith updates tags', () {
      final task = Task(
        id: 't-tags',
        title: 'Task with tags',
        tags: ['urgent', 'work'],
      );

      expect(task.tags, ['urgent', 'work']);

      final updated = task.copyWith(tags: ['work', 'design', 'review']);
      expect(updated.tags, ['work', 'design', 'review']);
      expect(updated.id, 't-tags');
    });

    test('TaskFilter toggleTag, isActive, activeFiltersCount, and equality work correctly', () {
      const filter = TaskFilter();
      expect(filter.isActive, isFalse);
      expect(filter.activeFiltersCount, 0);

      final filterWithTag = filter.toggleTag('work');
      expect(filterWithTag.tags, {'work'});
      expect(filterWithTag.isActive, isTrue);
      expect(filterWithTag.activeFiltersCount, 1);

      final filterWithTwoTags = filterWithTag.toggleTag('mobile');
      expect(filterWithTwoTags.tags, {'work', 'mobile'});
      expect(filterWithTwoTags.activeFiltersCount, 2);

      final untoggled = filterWithTwoTags.toggleTag('work');
      expect(untoggled.tags, {'mobile'});
      expect(untoggled.activeFiltersCount, 1);

      // Equality check
      final another = const TaskFilter().toggleTag('mobile');
      expect(untoggled, equals(another));
    });

    // ── v1.0.11: Chronological Sorting & Reordering Tests ─────────────────

    test('Tasks sort chronologically by sortOrder ascending (oldest first)', () {
      final task1 = Task(id: 't-1', title: 'First created', sortOrder: 0);
      final task2 = Task(id: 't-2', title: 'Second created', sortOrder: 1);
      final task3 = Task(id: 't-3', title: 'Third created', sortOrder: 2);

      final tasks = [task3, task1, task2];
      tasks.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      expect(tasks.map((t) => t.id).toList(), ['t-1', 't-2', 't-3']);
      expect(tasks.first.title, 'First created');
      expect(tasks.last.title, 'Third created');
    });

    test('Reordering updates sortOrder positions correctly', () {
      final taskA = Task(id: 'a', title: 'A', sortOrder: 0);
      final taskB = Task(id: 'b', title: 'B', sortOrder: 1);
      final taskC = Task(id: 'c', title: 'C', sortOrder: 2);

      final list = [taskA, taskB, taskC];

      // Simulate dragging task C (index 2) to the top (index 0)
      final moved = list.removeAt(2);
      list.insert(0, moved);

      // Reassign sortOrder sequentially
      final updatedList = [
        for (int i = 0; i < list.length; i++) list[i].copyWith(sortOrder: i)
      ];

      expect(updatedList.map((t) => t.id).toList(), ['c', 'a', 'b']);
      expect(updatedList[0].sortOrder, 0);
      expect(updatedList[1].sortOrder, 1);
      expect(updatedList[2].sortOrder, 2);
    });

    test('Tasks with identical sortOrder fallback to ID comparison for deterministic ordering', () {
      final taskX = Task(id: 'task-a', title: 'Task A', sortOrder: 0);
      final taskY = Task(id: 'task-b', title: 'Task B', sortOrder: 0);

      final list = [taskY, taskX];
      list.sort((a, b) {
        final orderCmp = a.sortOrder.compareTo(b.sortOrder);
        if (orderCmp != 0) return orderCmp;
        return a.id.compareTo(b.id);
      });

      expect(list.map((t) => t.id).toList(), ['task-a', 'task-b']);
    });
  });
}

