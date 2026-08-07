// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../theme/y0_design_system.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/voice_input_button.dart';
import '../../models/task.dart';
import '../../services/speech_service.dart';
import '../../services/task_service.dart';
import '../../screens/add_edit_task_screen.dart';
import 'widgets/greeting_card.dart';
import 'widgets/progress_card.dart';
import 'widgets/search_section.dart';
import 'widgets/quick_filters.dart';
import 'widgets/task_list_widget.dart';

/// 🏠 Y0 To-Do App - Refactored Home Screen (High Performance)
class HomeScreenNeoMorphic extends ConsumerWidget {
  const HomeScreenNeoMorphic({super.key});

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditTaskScreen(),
      ),
    ).then((result) {
      if (result != null && result is Task) {
        final taskService = TaskService(ref);
        taskService.addTask(result);
      }
    });
  }

  void _startVoiceInput(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'الإدخال الصوتي والتحليل الذكي',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Y0DesignSystem.spacing3),
            VoiceInputButton(
              onCommandReceived: (command) {
                if (command.type == VoiceCommandType.addTask && command.data.containsKey('taskText')) {
                  final taskText = command.data['taskText'] as String;
                  if (taskText.isNotEmpty) {
                    final newTask = Task(
                      id: const Uuid().v4(),
                      title: taskText,
                    );
                    TaskService(ref).addTask(newTask);
                  }
                }
              },
            ),
            const SizedBox(height: Y0DesignSystem.spacing2),
            Text(
              'انقر الميكروفون للتحدث بأمر صوتي',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Y0DesignSystem.spacing3),
          ],
        ),
      ),
    );
  }

  void _handleNavigationTap(BuildContext context, WidgetRef ref, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/statistics');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: context.colorScheme.surface,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.onSurface.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Y0DesignSystem.spacing3,
                vertical: Y0DesignSystem.spacing2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Y0 To-Do',
                            style: context.textTheme.headlineMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            _buildSliverAppBar(context),
            
            // Main Content Components
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: Y0DesignSystem.spacing3,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: Y0DesignSystem.spacing3),
                  const GreetingCard(),
                  const SizedBox(height: Y0DesignSystem.spacing3),
                  const ProgressCard(),
                  const SizedBox(height: Y0DesignSystem.spacing3),
                  const SearchSection(),
                  const SizedBox(height: Y0DesignSystem.spacing3),
                  const QuickFilters(),
                  const SizedBox(height: Y0DesignSystem.spacing2),
                ]),
              ),
            ),
            
            // Lazy-loaded Tasks list directly in the CustomScrollView
            const SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: Y0DesignSystem.spacing3,
              ),
              sliver: TaskListWidget(),
            ),
            
            // Bottom spacing for navigation and FABs
            const SliverToBoxAdapter(
              child: SizedBox(height: 160),
            ),
          ],
        ),
      ),
      // Multi-functional FABs
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "voice",
            onPressed: () => _startVoiceInput(context, ref),
            backgroundColor: context.colorScheme.primaryContainer,
            foregroundColor: context.colorScheme.onPrimaryContainer,
            child: const Icon(Icons.mic),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "add",
            onPressed: () => _showAddTaskDialog(context, ref),
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        onTap: (index) => _handleNavigationTap(context, ref, index),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
