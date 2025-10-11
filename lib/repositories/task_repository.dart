import 'package:hive/hive.dart';

import '../models/task.dart';

class TaskRepository {
  TaskRepository(this._box);

  final Box<Task> _box;

  List<Task> getAll() {
    return _box.values.toList();
  }

  Future<void> add(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> update(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleDone(String id) async {
    final task = _box.get(id);
    if (task != null) {
      await _box.put(id, task.copyWith(isDone: !task.isDone));
    }
  }
}
