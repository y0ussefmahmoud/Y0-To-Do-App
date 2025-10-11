import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';

// Provides the Hive box for tasks
final tasksBoxProvider = Provider<Box<Task>>((ref) {
  final box = Hive.box<Task>('tasksBox');
  return box;
});

// Repository provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final box = ref.watch(tasksBoxProvider);
  return TaskRepository(box);
});

// StateNotifier holding the list of tasks
class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier(this._repo) : super(_repo.getAll());

  final TaskRepository _repo;

  Future<void> refresh() async {
    state = _repo.getAll();
  }

  Future<void> add(Task task) async {
    await _repo.add(task);
    await refresh();
  }

  Future<void> update(Task task) async {
    await _repo.update(task);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await refresh();
  }

  Future<void> toggleDone(String id) async {
    await _repo.toggleDone(id);
    await refresh();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TasksNotifier(repo);
});
