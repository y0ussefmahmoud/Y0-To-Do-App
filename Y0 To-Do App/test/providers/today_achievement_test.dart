// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:y0_todo_app/models/task.dart';
import 'package:y0_todo_app/providers/task_provider.dart';

void main() {
  group('Today Achievement Logic Tests', () {
    test('Tasks due on previous or future days do not contaminate today calculation', () {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day, 14, 0);
      final yesterdayDate = now.subtract(const Duration(days: 1));
      final tomorrowDate = now.add(const Duration(days: 1));
      final pastOverdue35d = now.subtract(const Duration(days: 35));

      final tasks = [
        // 1. Task due today - completed
        Task(
          id: '1',
          title: 'Today Completed 1',
          dueDate: todayDate,
          isDone: true,
        ),
        // 2. Task due today - pending
        Task(
          id: '2',
          title: 'Today Pending 1',
          dueDate: todayDate,
          isDone: false,
        ),
        // 3. Task due yesterday - completed (must NOT contaminate today's count)
        Task(
          id: '3',
          title: 'Yesterday Completed',
          dueDate: yesterdayDate,
          isDone: true,
        ),
        // 4. Task due tomorrow - pending (must NOT contaminate today's count)
        Task(
          id: '4',
          title: 'Tomorrow Pending',
          dueDate: tomorrowDate,
          isDone: false,
        ),
        // 5. Task overdue 35 days ago (must NOT contaminate today's count)
        Task(
          id: '5',
          title: 'Old Overdue',
          dueDate: pastOverdue35d,
          isDone: false,
        ),
        // 6. Task without due date (must NOT contaminate today's count)
        Task(
          id: '6',
          title: 'No Due Date Task',
          isDone: false,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          tasksProvider.overrideWith((ref) => FakeTasksNotifier(tasks)),
        ],
      );

      final counts = container.read(taskCountsProvider);

      // Total lifetime
      expect(counts.completed, equals(2)); // Task 1 + Task 3
      
      // Strict Today's Tasks
      expect(counts.todayTotal, equals(2)); // Only Task 1 and Task 2
      expect(counts.todayCompleted, equals(1)); // Only Task 1
      expect(counts.todayPending, equals(1)); // Only Task 2
      expect(counts.todayProgress, equals(0.5)); // 1/2 = 50%
      expect(counts.todayProgressPercent, equals(50));
    });

    test('Zero tasks for today returns 0.0 progress safely without division by zero', () {
      final now = DateTime.now();
      final tomorrowDate = now.add(const Duration(days: 2));

      final tasks = [
        Task(
          id: '1',
          title: 'Tomorrow Task',
          dueDate: tomorrowDate,
          isDone: true,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          tasksProvider.overrideWith((ref) => FakeTasksNotifier(tasks)),
        ],
      );

      final counts = container.read(taskCountsProvider);

      expect(counts.todayTotal, equals(0));
      expect(counts.todayCompleted, equals(0));
      expect(counts.todayPending, equals(0));
      expect(counts.todayProgress, equals(0.0));
      expect(counts.todayProgressPercent, equals(0));
    });

    test('All today tasks completed returns 100% progress', () {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day, 9, 30);

      final tasks = [
        Task(
          id: '1',
          title: 'Today 1',
          dueDate: todayDate,
          isDone: true,
        ),
        Task(
          id: '2',
          title: 'Today 2',
          dueDate: todayDate,
          isDone: true,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          tasksProvider.overrideWith((ref) => FakeTasksNotifier(tasks)),
        ],
      );

      final counts = container.read(taskCountsProvider);

      expect(counts.todayTotal, equals(2));
      expect(counts.todayCompleted, equals(2));
      expect(counts.todayPending, equals(0));
      expect(counts.todayProgress, equals(1.0));
      expect(counts.todayProgressPercent, equals(100));
    });
  });
}

class FakeTasksNotifier extends StateNotifier<List<Task>> implements TasksNotifier {
  FakeTasksNotifier(super.state);

  @override
  Future<void> add(Task task) async {}
  @override
  Future<void> addTask(Task task) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> reorderTasks(int oldIndex, int newIndex) async {}
  @override
  Future<void> rescheduleAllNotifications() async {}
  @override
  void resetPagination() {}
  @override
  Future<void> toggleDone(String id) async {}
  @override
  Future<void> update(Task task) async {}
  @override
  Future<void> loadNextPage() async {}
  @override
  List<Task> getFilteredTasks(dynamic filter) => state;
}
