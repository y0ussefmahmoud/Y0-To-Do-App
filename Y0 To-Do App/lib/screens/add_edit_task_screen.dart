// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n_extension.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../models/recurrence_rule.dart';
import '../models/sub_task.dart';
import '../services/ai_service.dart';
import '../widgets/subtask_checklist.dart';
import '../widgets/recurrence_picker.dart';
import '../theme/y0_design_system.dart';

/// شاشة إضافة أو تعديل مهمة
class AddEditTaskScreen extends ConsumerStatefulWidget {
  const AddEditTaskScreen({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();
  DateTime? _dueDate;
  int _priority = 0;
  TaskCategory _category = TaskCategory.general;
  TaskAnalysis? _aiAnalysis;

  // v3.4.0 fields
  RecurrenceRule? _recurrenceRule;
  List<SubTask> _subtasks = [];

  // v3.5.0 tags
  List<String> _tags = [];

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
      _recurrenceRule = t.recurrenceRule;
      _subtasks = List<SubTask>.from(t.subtasks);
      _tags = List<String>.from(t.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    final tag = raw.trim();
    if (tag.isEmpty || _tags.contains(tag)) {
      _tagController.clear();
      return;
    }
    setState(() {
      _tags = [..._tags, tag];
      _tagController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags = _tags.where((t) => t != tag).toList();
    });
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
      setState(() {
        if (_dueDate != null) {
          // الحفاظ على الوقت المحدد سابقاً إن وجد
          _dueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _dueDate!.hour,
            _dueDate!.minute,
          );
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _pickDueTime() async {
    final initialTime = _dueDate != null
        ? TimeOfDay(hour: _dueDate!.hour, minute: _dueDate!.minute)
        : TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        final baseDate = _dueDate ?? DateTime.now();
        _dueDate = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _clearDueTime() {
    if (_dueDate == null) return;
    setState(() {
      _dueDate = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        0,
        0,
      );
    });
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
      recurrenceRule: _recurrenceRule,
      subtasks: _subtasks,
      tags: _tags,
      completedAt: widget.task?.completedAt,
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

  void _onSubtaskToggle(String id) {
    setState(() {
      _subtasks = _subtasks.map((s) {
        if (s.id == id) return s.copyWith(isDone: !s.isDone);
        return s;
      }).toList();
    });
  }

  void _onSubtaskAdd(String title) {
    setState(() {
      _subtasks = [
        ..._subtasks,
        SubTask(id: const Uuid().v4(), title: title, isDone: false),
      ];
    });
  }

  void _onSubtaskDelete(String id) {
    setState(() {
      _subtasks = _subtasks.where((s) => s.id != id).toList();
    });
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _saveTask,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text(
                context.l10n.save,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? Y0DesignSystem.primaryContainer
                    : Y0DesignSystem.primary,
                foregroundColor: isDark
                    ? const Color(0xFF00390E)
                    : Y0DesignSystem.onPrimary,
                elevation: 2,
                shadowColor: (isDark ? Y0DesignSystem.primaryContainer : Y0DesignSystem.primary)
                    .withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                // ── حقل العنوان ───────────────────────────────────────────
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

                // ── اقتراحات الذكاء الاصطناعي ────────────────────────────
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
                        Text(context.l10n.smartSuggestions,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(context.l10n.suggestedPriority(
                            _getPriorityText(context, _aiAnalysis!.priority))),
                        if (_aiAnalysis!.dueDate != null)
                          Text(context.l10n.suggestedDate(
                            _aiAnalysis!.dueDate!.hour != 0 || _aiAnalysis!.dueDate!.minute != 0
                                ? '${DateFormat('dd/MM/yyyy').format(_aiAnalysis!.dueDate!)} - ${DateFormat.jm(Localizations.localeOf(context).languageCode).format(_aiAnalysis!.dueDate!)}'
                                : DateFormat('dd/MM/yyyy').format(_aiAnalysis!.dueDate!),
                          )),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  setState(() => _priority = _aiAnalysis!.priority),
                              child: Text(context.l10n.applyPriority),
                            ),
                            const SizedBox(width: 8),
                            if (_aiAnalysis!.dueDate != null)
                              ElevatedButton(
                                onPressed: () =>
                                    setState(() => _dueDate = _aiAnalysis!.dueDate),
                                child: Text(context.l10n.applyDate),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // ── حقل الملاحظات ─────────────────────────────────────────
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: context.l10n.taskNoteLabel,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // ── تاريخ ووقت الاستحقاق ───────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: OutlinedButton.icon(
                        onPressed: _pickDueDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          _dueDate == null
                              ? context.l10n.pickDueDateLabel
                              : context.l10n.dueDatePrefix(
                                  DateFormat('dd/MM/yyyy').format(_dueDate!)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (_dueDate != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: _pickDueTime,
                          icon: const Icon(Icons.access_time, size: 18),
                          label: Text(
                            (_dueDate!.hour != 0 || _dueDate!.minute != 0)
                                ? DateFormat.jm(Localizations.localeOf(context).languageCode).format(_dueDate!)
                                : context.l10n.pickDueTimeLabel,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: (_dueDate!.hour != 0 || _dueDate!.minute != 0)
                              ? OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 1.5,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (_dueDate!.hour != 0 || _dueDate!.minute != 0) ...[
                        IconButton(
                          onPressed: _clearDueTime,
                          icon: const Icon(Icons.timer_off_outlined, size: 20),
                          tooltip: context.l10n.clearTimeTooltip,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                      IconButton(
                        onPressed: () => setState(() => _dueDate = null),
                        icon: const Icon(Icons.clear, size: 20),
                        tooltip: context.l10n.clearDateTooltip,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                // ── تكرار المهمة ─────────────────────────────────────────
                if (_dueDate != null) ...[
                  RecurrencePicker(
                    selectedRule: _recurrenceRule,
                    onChanged: (rule) => setState(() => _recurrenceRule = rule),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── الأولوية ──────────────────────────────────────────────
                Text(context.l10n.priorityLabel,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                                ? LinearGradient(colors: [
                                    Colors.red.shade700,
                                    Colors.red.shade500
                                  ])
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
                            color: _priority == 1
                                ? Colors.orange.shade200
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.priorityMedium,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _priority == 1
                                  ? Colors.orange.shade800
                                  : Colors.grey.shade700,
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
                            color: _priority == 0
                                ? const Color(0xFFC8E6C9)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.priorityLow,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _priority == 0
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── التصنيف ───────────────────────────────────────────────
                Text(context.l10n.categoryLabel,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          Icon(category.icon,
                              size: 16,
                              color: isSelected ? Colors.white : category.color),
                          const SizedBox(width: 4),
                          Text(category.localizedName(context)),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _category = category),
                      backgroundColor: category.color.withValues(alpha: 0.1),
                      selectedColor: category.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : category.color,
                        fontSize: 12,
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ── المهام الفرعية (قائمة التحقق) ────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                  ),
                  child: SubtaskChecklist(
                    subtasks: _subtasks,
                    onToggle: _onSubtaskToggle,
                    onAdd: _onSubtaskAdd,
                    onDelete: _onSubtaskDelete,
                  ),
                ),
                const SizedBox(height: 24),

                // ── الوسوم (Tags) ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.label_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.l10n.tagsLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _tags.map((tag) => Chip(
                            label: Text(
                              '#$tag',
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => _removeTag(tag),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            deleteIconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          )).toList(),
                        ),
                        const SizedBox(height: 10),
                      ],
                      TextField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          hintText: context.l10n.tagsHint,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          prefixIcon: const Icon(Icons.tag, size: 18),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            onPressed: () => _addTag(_tagController.text),
                            tooltip: context.l10n.tagsLabel,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: _addTag,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── زر الحفظ الرئيسي ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Y0DesignSystem.primaryContainer : Y0DesignSystem.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _saveTask,
                    icon: const Icon(Icons.save_rounded),
                    label: Text(
                      widget.task == null
                          ? context.l10n.createTaskButton
                          : context.l10n.saveChangesButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Y0DesignSystem.primaryContainer
                          : Y0DesignSystem.primary,
                      foregroundColor: isDark
                          ? const Color(0xFF00390E)
                          : Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
