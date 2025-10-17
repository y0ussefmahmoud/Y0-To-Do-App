import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/ai_provider.dart';
import '../widgets/voice_input_button.dart';
import '../services/ai_service.dart';

/// شاشة إضافة أو تعديل مهمة
/// 
/// توفر واجهة لإنشاء مهمة جديدة أو تعديل مهمة موجودة
/// 
/// الميزات:
/// - تحليل ذكي للنص باستخدام AI
/// - اقتراح الأولوية والتاريخ تلقائياً
/// - اختيار تاريخ الاستحقاق
/// - تحديد مستوى الأولوية
/// - إضافة ملاحظات
/// 
/// مثال على الاستخدام:
/// ```dart
/// // إضافة مهمة جديدة
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => AddEditTaskScreen()),
/// );
/// 
/// // تعديل مهمة موجودة
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => AddEditTaskScreen(task: existingTask),
///   ),
/// );
/// ```
class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key, this.task});

  /// المهمة المراد تعديلها (اختياري)
  /// إذا كانت null، سيتم إنشاء مهمة جديدة
  final Task? task;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  /// مفتاح النموذج للتحقق من صحة البيانات
  final _formKey = GlobalKey<FormState>();
  
  /// متحكم في حقل عنوان المهمة
  final _titleController = TextEditingController();
  
  /// متحكم في حقل الملاحظات
  final _noteController = TextEditingController();
  
  /// تاريخ استحقاق المهمة
  DateTime? _dueDate;
  
  /// مستوى أولوية المهمة (0-2)
  int _priority = 0;
  
  /// نتيجة تحليل AI للمهمة
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
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// فتح محدد التاريخ لاختيار تاريخ الاستحقاق
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

  /// حفظ المهمة وإرجاعها إلى الشاشة السابقة
  /// 
  /// يتحقق من صحة البيانات قبل الحفظ
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
      isDone: widget.task?.isDone ?? false,
    );

    Navigator.pop(context, result);
  }

  /// تحليل نص المهمة باستخدام AI
  /// 
  /// يتم استدعاؤها عند تغيير نص المهمة
  /// [text] نص المهمة الجديد
  void _analyzeTaskText(String text) {
    if (text.isNotEmpty) {
      final analysis = AIService().analyzeTaskText(text);
      setState(() {
        _aiAnalysis = analysis;
      });
    } else {
      setState(() {
        _aiAnalysis = null;
      });
    }
  }

  /// تحويل رقم الأولوية إلى نص
  /// 
  /// [priority] رقم الأولوية (0-2)
  /// Returns: نص الأولوية (منخفضة، متوسطة، عالية)
  String _getPriorityText(int priority) {
    switch (priority) {
      case 2: return 'عالية';
      case 1: return 'متوسطة';
      default: return 'منخفضة';
    }
  }

  /// الحصول على لون الأولوية
  /// 
  /// [priority] رقم الأولوية (0-2)
  /// Returns: لون يمثل الأولوية (أخضر، برتقالي، أحمر)
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2: return const Color(0xFFDC2626); // High - Red
      case 1: return const Color(0xFFF59E0B); // Medium - Orange
      default: return const Color(0xFF10B981); // Low - Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'إضافة مهمة جديدة' : 'تعديل المهمة',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _saveTask,
              icon: const Icon(Icons.save, size: 18),
              label: const Text('حفظ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المهمة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'عنوان المهمة مطلوب' : null,
                onChanged: _analyzeTaskText,
              ),
              const SizedBox(height: 16),
              
              // AI Suggestions
              if (_aiAnalysis != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('اقتراحات ذكية:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('الأولوية المقترحة: ${_getPriorityText(_aiAnalysis!.priority)}'),
                      if (_aiAnalysis!.dueDate != null)
                        Text('التاريخ المقترح: ${DateFormat('dd/MM/yyyy').format(_aiAnalysis!.dueDate!)}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => setState(() => _priority = _aiAnalysis!.priority),
                            child: const Text('تطبيق الأولوية'),
                          ),
                          const SizedBox(width: 8),
                          if (_aiAnalysis!.dueDate != null)
                            ElevatedButton(
                              onPressed: () => setState(() => _dueDate = _aiAnalysis!.dueDate),
                              child: const Text('تطبيق التاريخ'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختيارية)',
                  border: OutlineInputBorder(),
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
                          ? 'تحديد تاريخ الاستحقاق'
                          : 'الاستحقاق: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}'),
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
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'الأولوية',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('منخفضة')),
                  DropdownMenuItem(value: 1, child: Text('متوسطة')),
                  DropdownMenuItem(value: 2, child: Text('عالية')),
                ],
                onChanged: (value) => setState(() => _priority = value!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveTask,
                  icon: const Icon(Icons.save),
                  label: Text(widget.task == null ? 'إنشاء المهمة' : 'حفظ التغييرات'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
