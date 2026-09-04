// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter_test/flutter_test.dart';
import 'package:y0_todo_app/models/task.dart';
import 'package:y0_todo_app/models/task_category.dart';
import 'package:y0_todo_app/providers/task_provider.dart';

/// 🧪 Unit Tests for TaskCounts Provider Logic
void main() {
  /// Helper: compute TaskCounts using the same logic as [taskCountsProvider].
  TaskCounts computeCounts(List<Task> tasks) {
    int completed = 0;
    int pending = 0;
    int archived = 0;
    int archivedOlderThanMonth = 0;
    int activePending = 0;
    int today = 0;
    int todayTotal = 0;
    int todayCompleted = 0;
    int todayPending = 0;
    int thisWeek = 0;
    int overdue = 0;
    int priorityHigh = 0;
    int priorityMedium = 0;
    int priorityLow = 0;
    final categoryCounts = <TaskCategory, int>{};

    for (final c in TaskCategory.values) {
      categoryCounts[c] = 0;
    }

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final weekStart = todayDate.subtract(Duration(days: todayDate.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    for (final task in tasks) {
      if (task.isDone) {
        completed++;
        archived++;
      } else {
        if (task.isArchived) {
          archived++;
          archivedOlderThanMonth++;
        } else {
          pending++;
          activePending++;
        }
      }

      if (task.dueDate != null) {
        final taskDate =
            DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        if (taskDate.isAtSameMomentAs(todayDate)) {
          todayTotal++;
          if (task.isDone) {
            todayCompleted++;
          } else if (!task.isArchived) {
            todayPending++;
          }
        }
      }

      if (task.dueDate != null && !task.isArchived) {
        final taskDate =
            DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        if (taskDate.isAtSameMomentAs(todayDate)) today++;
        if (!taskDate.isBefore(weekStart) && !taskDate.isAfter(weekEnd)) {
          thisWeek++;
        }
        if (taskDate.isBefore(todayDate) && !task.isDone) overdue++;
      }

      switch (task.priority) {
        case 2:
          priorityHigh++;
          break;
        case 1:
          priorityMedium++;
          break;
        default:
          priorityLow++;
      }

      final cat = task.safeCategory;
      categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
    }

    final todayProgress = todayTotal > 0 ? todayCompleted / todayTotal : 0.0;
    final todayProgressPercent = (todayProgress * 100).round();

    return TaskCounts(
      completed: completed,
      pending: pending,
      archived: archived,
      archivedOlderThanMonth: archivedOlderThanMonth,
      activePending: activePending,
      today: today,
      todayTotal: todayTotal,
      todayCompleted: todayCompleted,
      todayPending: todayPending,
      todayProgress: todayProgress,
      todayProgressPercent: todayProgressPercent,
      thisWeek: thisWeek,
      overdue: overdue,
      priorityHigh: priorityHigh,
      priorityMedium: priorityMedium,
      priorityLow: priorityLow,
      categoryCounts: categoryCounts,
    );
  }

  group('TaskCounts — Archive Criteria & No Double-Counting', () {
    test('Task completed 1 day ago is completed & archived, NOT pending', () {
      final tasks = [
        Task(
          id: '1',
          title: 'Done yesterday',
          isDone: true,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      final counts = computeCounts(tasks);

      expect(counts.completed, equals(1));
      expect(counts.archived, equals(1));
      expect(counts.pending, equals(0));
      expect(counts.activePending, equals(0));
    });

    test('Task pending with due date 31 days ago is archived, NOT pending', () {
      final tasks = [
        Task(
          id: '2',
          title: 'Pending 31 days ago',
          isDone: false,
          dueDate: DateTime.now().subtract(const Duration(days: 31)),
        ),
      ];
      final counts = computeCounts(tasks);

      expect(counts.archived, equals(1));
      expect(counts.archivedOlderThanMonth, equals(1));
      expect(counts.pending, equals(0));
      expect(counts.completed, equals(0));
    });

    test('Task pending with due date 10 days ago is active pending, NOT archived', () {
      final tasks = [
        Task(
          id: '3',
          title: 'Pending 10 days ago',
          isDone: false,
          dueDate: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];
      final counts = computeCounts(tasks);

      expect(counts.pending, equals(1));
      expect(counts.activePending, equals(1));
      expect(counts.archived, equals(0));
      expect(counts.completed, equals(0));
      expect(counts.overdue, equals(1));
    });

    test('Mixed tasks: 1 completed, 1 active pending, 1 overdue > 30d', () {
      final tasks = [
        Task(
          id: 'c1',
          title: 'Done',
          isDone: true,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Task(
          id: 'p1',
          title: 'Pending 10d',
          isDone: false,
          dueDate: DateTime.now().subtract(const Duration(days: 10)),
        ),
        Task(
          id: 'a1',
          title: 'Old overdue 40d',
          isDone: false,
          dueDate: DateTime.now().subtract(const Duration(days: 40)),
        ),
      ];
      final counts = computeCounts(tasks);

      expect(counts.completed, equals(1));
      expect(counts.pending, equals(1));
      expect(counts.archived, equals(2));
      expect(counts.archivedOlderThanMonth, equals(1));
    });
  });
}
