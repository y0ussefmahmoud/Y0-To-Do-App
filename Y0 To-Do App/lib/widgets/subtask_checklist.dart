// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../models/sub_task.dart';
import '../../theme/y0_design_system.dart';

/// قائمة التحقق من المهام الفرعية (SubTask Checklist Widget)
///
/// تعرض قائمة تفاعلية من المهام الفرعية مع إمكانية الإضافة والحذف والتبديل.
/// تستخدم في شاشة تعديل المهمة وبطاقة المهمة (TaskCard).
class SubtaskChecklist extends StatefulWidget {
  final List<SubTask> subtasks;
  final bool readOnly;
  final void Function(String id)? onToggle;
  final void Function(String title)? onAdd;
  final void Function(String id)? onDelete;

  const SubtaskChecklist({
    super.key,
    required this.subtasks,
    this.readOnly = false,
    this.onToggle,
    this.onAdd,
    this.onDelete,
  });

  @override
  State<SubtaskChecklist> createState() => _SubtaskChecklistState();
}

class _SubtaskChecklistState extends State<SubtaskChecklist> {
  final TextEditingController _addController = TextEditingController();
  bool _showAddField = false;

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _submitAdd() {
    final text = _addController.text.trim();
    if (text.isNotEmpty) {
      widget.onAdd?.call(text);
      _addController.clear();
      setState(() => _showAddField = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedCount = widget.subtasks.where((s) => s.isDone).length;
    final total = widget.subtasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── رأس القسم ──────────────────────────────────────────────────────
        Row(
          children: [
            Icon(
              Icons.checklist_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.subtasksTitle,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (total > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: completedCount == total
                      ? Colors.green.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.l10n.subtasksProgress(completedCount, total),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: completedCount == total
                        ? Colors.green.shade700
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        // ── شريط تقدم المهام الفرعية ───────────────────────────────────────
        if (total > 0) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? completedCount / total : 0.0,
              minHeight: 4,
              backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                completedCount == total ? Colors.green : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],

        const SizedBox(height: 8),

        // ── قائمة المهام الفرعية ───────────────────────────────────────────
        ...widget.subtasks.map((sub) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Checkbox(
                  value: sub.isDone,
                  onChanged: widget.readOnly
                      ? null
                      : (_) => widget.onToggle?.call(sub.id),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: Text(
                    sub.title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      decoration: sub.isDone ? TextDecoration.lineThrough : null,
                      color: sub.isDone
                          ? (isDark ? Colors.white38 : Colors.grey.shade500)
                          : null,
                    ),
                  ),
                ),
                if (!widget.readOnly)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                    color: Colors.red.shade400,
                    onPressed: () => widget.onDelete?.call(sub.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          );
        }),

        // ── حقل إضافة مهمة فرعية جديدة ───────────────────────────────────
        if (!widget.readOnly) ...[
          if (_showAddField) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: context.l10n.addSubtaskHint,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _submitAdd(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: _submitAdd,
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () {
                    _addController.clear();
                    setState(() => _showAddField = false);
                  },
                ),
              ],
            ),
          ] else
            TextButton.icon(
              onPressed: () => setState(() => _showAddField = true),
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                context.l10n.addSubtaskHint,
                style: const TextStyle(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ],
    );
  }
}
