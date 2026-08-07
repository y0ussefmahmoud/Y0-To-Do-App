// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/y0_design_system.dart';
import '../../../widgets/neo_morphic_card.dart';
import '../../../models/task.dart';
import '../../../providers/task_provider.dart';
import '../../../services/task_service.dart';
import '../../add_edit_task_screen.dart';

class TaskCardWidget extends ConsumerWidget {
  final String taskId;

  const TaskCardWidget({
    super.key,
    required this.taskId,
  });

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2:
        return Y0DesignSystem.priorityHigh;
      case 1:
        return Y0DesignSystem.priorityMedium;
      case 0:
      default:
        return Y0DesignSystem.priorityLow;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 2:
        return 'عالي';
      case 1:
        return 'متوسط';
      case 0:
      default:
        return 'منخفض';
    }
  }

  void _toggleTaskCompletion(BuildContext context, WidgetRef ref, Task task) {
    final taskService = TaskService(ref);
    taskService.toggleTaskCompletion(task.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(!task.isDone ? 'تم إنجاز المهمة' : 'تم إلغاء إنجاز المهمة'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editTask(BuildContext context, WidgetRef ref, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(task: task),
      ),
    ).then((result) {
      if (result != null && result is Task) {
        final taskService = TaskService(ref);
        taskService.updateTask(result);
      }
    });
  }

  void _deleteTask(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${task.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final taskService = TaskService(ref);
              await taskService.deleteTask(task.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف المهمة بنجاح')),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مراقبة المهمة المحددة فقط لتجنب إعادة بناء الكارد عند تعديل مهام أخرى
    final task = ref.watch(tasksProvider.select((list) {
      for (final t in list) {
        if (t.id == taskId) return t;
      }
      return null;
    }));

    if (task == null) {
      return const SizedBox.shrink();
    }

    return NeoMorphicCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Y0DesignSystem.spacing3,
        vertical: Y0DesignSystem.spacing2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // معلومات المهمة
          Expanded(
            flex: 5,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // مربع الاختيار (Checkbox)
                GestureDetector(
                  onTap: () => _toggleTaskCompletion(context, ref, task),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getPriorityColor(task.priority),
                        width: 2,
                      ),
                    ),
                    child: task.isDone
                        ? Icon(
                            Icons.check,
                            color: _getPriorityColor(task.priority),
                            size: 16,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: Y0DesignSystem.spacing2),
                // العنوان
                Expanded(
                  child: Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      color: task.isDone
                          ? context.colorScheme.onSurface.withValues(alpha: 0.45)
                          : context.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // نقطة الأولوية والإجراءات
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: _getPriorityText(task.priority),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: () => _editTask(context, ref, task),
                      color: context.colorScheme.primary,
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      onPressed: () => _deleteTask(context, ref, task),
                      color: context.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
