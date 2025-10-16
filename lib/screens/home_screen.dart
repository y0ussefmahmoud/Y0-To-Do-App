import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../providers/task_provider.dart';
import '../providers/ai_provider.dart';
import '../models/task.dart';
import '../widgets/voice_input_button.dart';
import '../services/speech_service.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final completedTasks = tasks.where((task) => task.isDone).length;
    final pendingTasks = tasks.length - completedTasks;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern Header
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(context, completedTasks, pendingTasks),
            ),
            title: const Text('Y0 To-Do App'),
          ),
          
          // Smart Suggestions
          if (tasks.isNotEmpty) _buildSmartSuggestions(ref),
          
          // Tasks List
          tasks.isEmpty
              ? SliverFillRemaining(child: const _EmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = tasks[index];
                        return _buildTaskCard(context, ref, task, index);
                      },
                      childCount: tasks.length,
                    ),
                  ),
                ),
        ],
      ),
      
      // Voice FAB + Regular FAB
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice Input FAB
          VoiceInputButton(
            onCommandReceived: (command) => _handleVoiceCommand(context, ref, command),
          ).animate().scale(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          // Regular Add Task FAB
          FloatingActionButton.extended(
            onPressed: () => _navigateToAddTask(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ).animate().slideX(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int completed, int pending) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Greeting
              Text(
                _getGreetingMessage(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(),
              
              const SizedBox(height: 8),
              
              Text(
                DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(),
              
              const SizedBox(height: 32),
              
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'مكتملة',
                      completed.toString(),
                      Icons.check_circle_rounded,
                      const Color(0xFF10B981),
                    ).animate().fadeIn(delay: 300.ms).scale(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'معلقة',
                      pending.toString(),
                      Icons.schedule_rounded,
                      const Color(0xFFF59E0B),
                    ).animate().fadeIn(delay: 400.ms).scale(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSuggestions(WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE2E8F0).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'اقتراحات ذكية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final suggestions = ref.watch(smartSuggestionsProvider);
                
                if (suggestions.suggestions.isEmpty) {
                  ref.read(smartSuggestionsProvider.notifier).loadSuggestions([]);
                  return const Text('جاري تحميل الاقتراحات...');
                }
                
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions.suggestions.map((suggestion) {
                    return ActionChip(
                      label: Text(suggestion),
                      onPressed: () => _addSuggestedTask(ref, suggestion),
                      backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ).animate().fadeIn(delay: 500.ms).slideY(),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE2E8F0).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) {
            ref.read(tasksProvider.notifier).toggleDone(task.id);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
            color: task.isDone ? Colors.grey : const Color(0xFF1E293B),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.note != null && task.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.note!,
                style: TextStyle(
                  color: task.isDone ? Colors.grey : const Color(0xFF64748B),
                ),
              ),
            ],
            if (task.dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: _getDueDateColor(task.dueDate!),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd').format(task.dueDate!),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDueDateColor(task.dueDate!),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Priority Indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('تعديل'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  final updated = await Navigator.push<Task?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditTaskScreen(task: task),
                    ),
                  );
                  if (updated != null) {
                    await ref.read(tasksProvider.notifier).update(updated);
                  }
                } else if (value == 'delete') {
                  await ref.read(tasksProvider.notifier).delete(task.id);
                }
              },
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
      .fadeIn()
      .slideX();
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'صباح الخير! 🌅';
    } else if (hour < 17) {
      return 'مساء الخير! ☀️';
    } else {
      return 'مساء الخير! 🌙';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2: return const Color(0xFFDC2626); // High - Red
      case 1: return const Color(0xFFF59E0B); // Medium - Orange
      default: return const Color(0xFF10B981); // Low - Green
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) return const Color(0xFFDC2626); // Overdue - Red
    if (difference == 0) return const Color(0xFFF59E0B); // Today - Orange
    if (difference <= 3) return const Color(0xFF0891B2); // Soon - Blue
    return const Color(0xFF64748B); // Future - Gray
  }

  void _handleVoiceCommand(BuildContext context, WidgetRef ref, VoiceCommand command) {
    switch (command.type) {
      case VoiceCommandType.addTask:
        final taskText = command.data['taskText'] as String;
        _addTaskFromVoice(ref, taskText);
        break;
      case VoiceCommandType.search:
        // TODO: Implement search
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أمر غير مفهوم')),
        );
    }
  }

  void _addTaskFromVoice(WidgetRef ref, String taskText) {
    final analysis = ref.read(smartSuggestionsProvider.notifier).analyzeTask(taskText);
    
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: taskText,
      priority: analysis.priority,
      dueDate: analysis.dueDate,
    );
    
    ref.read(tasksProvider.notifier).add(task);
  }

  void _addSuggestedTask(WidgetRef ref, String suggestion) {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: suggestion,
    );
    
    ref.read(tasksProvider.notifier).add(task);
  }

  Future<void> _navigateToAddTask(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.push<Task?>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditTaskScreen(),
      ),
    );
    if (created != null) {
      await ref.read(tasksProvider.notifier).add(created);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 60,
                color: Colors.white,
              ),
            ).animate().scale(delay: 200.ms),
            
            const SizedBox(height: 32),
            
            Text(
              'لا توجد مهام بعد! 📝',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 16),
            
            Text(
              'ابدأ رحلتك في الإنتاجية\nبإضافة أول مهمة لك',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 600.ms),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.mic_rounded,
                    color: Color(0xFF6366F1),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'جرب الإدخال الصوتي!',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط على زر الميكروفون وقل:\n"أضف مهمة اجتماع غداً"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF6366F1).withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(),
          ],
        ),
      ),
    );
  }
}
