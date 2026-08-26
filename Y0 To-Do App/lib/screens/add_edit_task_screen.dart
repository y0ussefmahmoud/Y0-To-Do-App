// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../l10n/l10n_extension.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../services/ai_service.dart';

/// شاشة إضافة أو تعديل مهمة
class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key, this.task});

  final Task? task;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _dueDate;
  int _priority = 0;
  TaskCategory _category = TaskCategory.general;
  TaskAnalysis? _aiAnalysis;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    if (t != null) {
      _titleController.text = t.title;
      _noteController.text = t.note ?? '';
      _dueDate = t.dueDate;
      _priority = t.priority;
      _category = t.safeCategory;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.task != null;
    final id = isEditing ? widget.task!.id : const Uuid().v4();

    final result = Task(
      id: id,
      title: _titleController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      category: _category,
      isDone: widget.task?.isDone ?? false,
      sortOrder: widget.task?.sortOrder ?? 0,
    );

    Navigator.pop(context, result);
  }

  void _analyzeTaskText(String text) {
    if (text.isNotEmpty) {
      final analysis = AIService().analyzeTaskText(text);
      setState(() {
        _aiAnalysis = analysis;
        _category = taskCategoryFromString(analysis.suggestedCategory);
      });
    } else {
      setState(() {
        _aiAnalysis = null;
      });
    }
  }

  String _getPriorityText(BuildContext context, int priority) {
    switch (priority) {
      case 2:
        return context.l10n.priorityHigh;
      case 1:
        return context.l10n.priorityMedium;
      default:
        return context.l10n.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.task == null ? context.l10n.addTaskTitle : context.l10n.editTaskTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _saveTask,
              icon: const Icon(Icons.save, size: 18),
              label: Text(context.l10n.save),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: context.l10n.taskTitleLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? context.l10n.taskTitleRequired : null,
                  onChanged: _analyzeTaskText,
                ),
                const SizedBox(height: 16),
                
                // AI Suggestions
                if (_aiAnalysis != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.smartSuggestions, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(context.l10n.suggestedPriority(_getPriorityText(context, _aiAnalysis!.priority))),
                        if (_aiAnalysis!.dueDate != null)
                          Text(context.l10n.suggestedDate(DateFormat('dd/MM/yyyy').format(_aiAnalysis!.dueDate!))),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => setState(() => _priority = _aiAnalysis!.priority),
                              child: Text(context.l10n.applyPriority),
                            ),
                            const SizedBox(width: 8),
                            if (_aiAnalysis!.dueDate != null)
                              ElevatedButton(
                                onPressed: () => setState(() => _dueDate = _aiAnalysis!.dueDate),
                                child: Text(context.l10n.applyDate),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: context.l10n.taskNoteLabel,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDueDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_dueDate == null
                            ? context.l10n.pickDueDateLabel
                            : context.l10n.dueDatePrefix(DateFormat('dd/MM/yyyy').format(_dueDate!))),
                      ),
                    ),
                    if (_dueDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => setState(() => _dueDate = null),
                        icon: const Icon(Icons.clear),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(context.l10n.priorityLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: _priority == 2 
                                ? LinearGradient(
                                    colors: [Colors.red.shade700, Colors.red.shade500],
                                  )
                                : null,
                            color: _priority == 2 ? null : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.priorityHigh,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _priority == 2 ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _priority == 1 ? Colors.orange.shade200 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.priorityMedium,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _priority == 1 ? Colors.orange.shade800 : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _priority == 0 ? const Color(0xFFC8E6C9) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.priorityLow,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _priority == 0 ? const Color(0xFF2E7D32) : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(context.l10n.categoryLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TaskCategory.values.map((category) {
                    final isSelected = _category == category;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 16,
                            color: isSelected ? Colors.white : category.color,
                          ),
                          const SizedBox(width: 4),
                          Text(category.localizedName(context)),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _category = category;
                        });
                      },
                      backgroundColor: category.color.withValues(alpha: 0.1),
                      selectedColor: category.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : category.color,
                        fontSize: 12,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveTask,
                    icon: const Icon(Icons.save),
                    label: Text(widget.task == null ? context.l10n.createTaskButton : context.l10n.saveChangesButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
