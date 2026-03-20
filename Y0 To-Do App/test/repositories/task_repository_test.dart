import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:y0_todo_app/models/task.dart';
import 'package:y0_todo_app/models/task_category.dart';
import 'package:y0_todo_app/repositories/task_repository.dart';
import 'package:y0_todo_app/utils/error_handler.dart';

void main() {
  late Box<Task> box;
  late TaskRepository repository;

  setUp(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }
    box = await Hive.openBox<Task>('tasksBoxTest');
    repository = TaskRepository(box);
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('add stores a task', () async {
    final task = Task(id: '1', title: 'Test');

    await repository.add(task);

    final tasks = repository.getAll();
    expect(tasks, hasLength(1));
    expect(tasks.first.title, 'Test');
  });

  test('add throws when id is empty', () async {
    final task = Task(id: '', title: 'Test');

    expect(() => repository.add(task), throwsA(isA<TaskRepositoryException>()));
  });

  test('update throws when task not found', () async {
    final task = Task(id: 'missing', title: 'Missing');

    expect(() => repository.update(task), throwsA(isA<TaskNotFoundException>()));
  });

  test('delete throws when task not found', () async {
    expect(() => repository.delete('missing'), throwsA(isA<TaskNotFoundException>()));
  });

  test('toggleDone flips completion state', () async {
    final task = Task(id: '2', title: 'Toggle');
    await repository.add(task);

    await repository.toggleDone('2');

    final updated = repository.getAll().first;
    expect(updated.isDone, isTrue);
  });
}
