// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

/// 🎯 Task Service - Business Logic Layer for Task Operations
/// 
/// This service encapsulates business logic related to task operations,
/// separating it from the presentation layer (screens).
/// 
/// Key Responsibilities:
/// - Task CRUD operations with notification management
/// - Task completion toggling with haptic feedback
/// - Notification rescheduling based on settings changes
/// - Task validation and error handling
/// 
/// Example Usage:
/// ```dart
/// final taskService = TaskService(ref);
/// await taskService.completeTask(taskId);
/// await taskService.rescheduleAllNotifications();
/// ```
/// 
/// @author Y0 Development Team
/// @version 3.2.5
class TaskService {
  final WidgetRef _ref;

  TaskService(this._ref);

  /// ✅ Toggle task completion status
  /// 
  /// Toggles the completion status of a task and schedules/cancels
  /// notifications accordingly.
  /// 
  /// Parameters:
  /// - [taskId] The ID of the task to toggle
  /// 
  /// Returns: Future<void>
  /// 
  /// Example:
  /// ```dart
  /// await taskService.toggleTaskCompletion('task-123');
  /// ```
  Future<void> toggleTaskCompletion(String taskId) async {
    await _ref.read(tasksProvider.notifier).toggleDone(taskId);
  }

  /// 📝 Update an existing task
  /// 
  /// Updates a task and reschedules its notifications if needed.
  /// 
  /// Parameters:
  /// - [task] The task to update
  /// 
  /// Returns: Future<void>
  /// 
  /// Example:
  /// ```dart
  /// await taskService.updateTask(updatedTask);
  /// ```
  Future<void> updateTask(Task task) async {
    await _ref.read(tasksProvider.notifier).update(task);
  }

  /// ➕ Add a new task
  /// 
  /// Adds a new task and schedules notifications if enabled.
  Future<void> addTask(Task task) async {
    await _ref.read(tasksProvider.notifier).add(task);
  }

  /// 🗑️ Delete a task
  /// 
  /// Deletes a task and cancels its notifications.
  Future<void> deleteTask(String taskId) async {
    await _ref.read(tasksProvider.notifier).delete(taskId);
  }

  /// 🔔 Reschedule all notifications
  /// 
  /// Reschedules all notifications based on current settings.
  /// Called when notification settings change.
  /// 
  /// Returns: Future<void>
  /// 
  /// Example:
  /// ```dart
  /// await taskService.rescheduleAllNotifications();
  /// ```
  Future<void> rescheduleAllNotifications() async {
    await _ref.read(tasksProvider.notifier).rescheduleAllNotifications();
  }

  /// 📋 Get all tasks
  /// 
  /// Returns all tasks from the repository.
  /// 
  /// Returns: List<Task>
  /// 
  /// Example:
  /// ```dart
  /// final tasks = await taskService.getAllTasks();
  /// ```
  List<Task> getAllTasks() {
    return _ref.read(tasksProvider);
  }

  /// 🔍 Get task by ID
  /// 
  /// Returns a task with the specified ID, or null if not found.
  /// 
  /// Parameters:
  /// - [taskId] The ID of the task to find
  /// 
  /// Returns: Task?
  /// 
  /// Example:
  /// ```dart
  /// final task = await taskService.getTaskById('task-123');
  /// ```
  Task? getTaskById(String taskId) {
    final tasks = _ref.read(tasksProvider);
    try {
      return tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }
}
