import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart' as intl;

import '../providers/ai_provider.dart';
import '../providers/search_provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../utils/accessibility_helper.dart';
import '../widgets/task_filter_chips.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_results_widget.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/task_skeleton.dart';
import '../widgets/accessible_icon_button.dart';
import '../widgets/error_snackbar.dart';
import '../widgets/success_snackbar.dart';
import '../services/haptic_service.dart';
import 'home_screen_empty_filtered.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import '../services/speech_service.dart';
import '../services/ai_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final tasks = ref.watch(searchState.query.isNotEmpty ? searchResultsProvider : paginatedTasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final completedTasks = filteredTasks.where((task) => task.isDone).length;
    final pendingTasks = filteredTasks.length - completedTasks;
    final isPaginationLoading = ref.watch(isLoadingProvider);
    final isLoading = isPaginationLoading;
    final hasMorePages = ref.watch(hasMorePagesProvider);
    final isCompactHeight = MediaQuery.sizeOf(context).height < 520;
    final isCompactWidth = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            // Load next page when user reaches 80% of the list
            if (scrollNotification is ScrollUpdateNotification &&
                scrollNotification.metrics.extentAfter < 300 &&
                !isPaginationLoading &&
                hasMorePages &&
                searchState.query.isEmpty) {
              // Debounce the loading to prevent multiple calls
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!isPaginationLoading && hasMorePages) {
                  ref.read(tasksProvider.notifier).loadNextPage();
                }
              });
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            cacheExtent: 500, // Improve performance by caching more items
            slivers: [
            // Modern Header
            SliverAppBar(
              expandedHeight: isCompactHeight ? 240 : 280,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                AccessibleIconButton(
                  icon: Icons.analytics,
                  label: AccessibilityHelper.getButtonLabel('الإحصائيات'),
                  tooltip: 'الإحصائيات',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                    );
                  },
                ),
                AccessibleIconButton(
                  icon: Icons.settings,
                  label: AccessibilityHelper.getButtonLabel('الإعدادات'),
                  tooltip: 'الإعدادات',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(context, completedTasks, pendingTasks),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Y0 To-Do App'),
                    ),
                  ),
                  if (filter.isActive && !isCompactWidth) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.filter_list, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${filter.activeFiltersCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Search Bar
            const SliverToBoxAdapter(
              child: SearchBarWidget(),
            ),

            // Search Results (only show when searching)
            if (searchState.query.isNotEmpty)
              const SliverToBoxAdapter(
                child: SearchResultsWidget(),
              )
            else ...[
              // Smart Suggestions (only show when not searching)
              if (tasks.isNotEmpty) _buildSmartSuggestions(ref),

              // Task Filters (only show when not searching)
              const SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: TaskFilterChips(),
                ),
              ),
            ],

            // Tasks List (only show when not searching)
            if (searchState.query.isEmpty)
              isLoading && tasks.isEmpty
                  ? const SliverFillRemaining(
                      child: TaskSkeletonList(itemCount: 5),
                    )
                  : tasks.isEmpty
                      ? SliverFillRemaining(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final filter = ref.watch(taskFilterProvider);
                              if (filter.isActive) {
                                return const EmptyFilteredState();
                              } else {
                                return _EmptyState(
                                  onAddTask: () => _showAddTaskDialog(context, ref),
                                );
                              }
                            },
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                // Handle loading and end states
                                if (index >= tasks.length) {
                                  if (hasMorePages && searchState.query.isEmpty) {
                                    return _buildLoadingIndicator();
                                  } else if (!hasMorePages && searchState.query.isEmpty) {
                                    return _buildEndOfListMessage();
                                  }
                                  return const SizedBox.shrink(); // Empty widget for search mode
                                }

                                final task = tasks[index];
                                return _buildTaskCard(context, ref, task, index);
                              },
                              childCount: tasks.length + (searchState.query.isEmpty ? 1 : 0),
                            ),
                          ),
                        ),
          ],
          ),
        ),
      ),
      
      // Voice FAB + Regular FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SafeArea(
        child: isCompactHeight
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AccessibleIconButton(
                    icon: Icons.mic,
                    label: AccessibilityHelper.getFabLabel('إدخال صوتي'),
                    tooltip: AccessibilityHelper.getButtonLabel('إدخال صوتي'),
                    onPressed: () => _startVoiceInput(context, ref),
                  ).animate().scale(delay: 200.ms),
                  const SizedBox(width: 16),
                  AccessibleIconButton(
                    icon: Icons.add,
                    label: AccessibilityHelper.getFabLabel('إضافة مهمة'),
                    tooltip: AccessibilityHelper.getButtonLabel('إضافة مهمة'),
                    onPressed: () => _showAddTaskDialog(context, ref),
                  ).animate().slideX(delay: 300.ms),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Voice Input FAB
                  AccessibleIconButton(
                    icon: Icons.mic,
                    label: AccessibilityHelper.getFabLabel('إدخال صوتي'),
                    tooltip: AccessibilityHelper.getButtonLabel('إدخال صوتي'),
                    onPressed: () => _startVoiceInput(context, ref),
                  ).animate().scale(delay: 200.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Regular Add Task FAB
                  AccessibleIconButton(
                    icon: Icons.add,
                    label: AccessibilityHelper.getFabLabel('إضافة مهمة'),
                    tooltip: AccessibilityHelper.getButtonLabel('إضافة مهمة'),
                    onPressed: () => _showAddTaskDialog(context, ref),
                  ).animate().slideX(delay: 300.ms),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int completed, int pending) {
    final statsLabel = AccessibilityHelper.getStatisticsLabel(
      completed,
      pending,
      completed + pending,
    );
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 260;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isCompact ? 8 : 20),
                  
                  // Greeting with AI Badge
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _getGreetingMessage(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 26 : 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.psychology, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms).slideX(),
                  
                  SizedBox(height: isCompact ? 4 : 8),
                  
                  Text(
                    intl.DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now()),
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: isCompact ? 14 : 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(),
                  
                  const Spacer(),
                  
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'مكتملة',
                          completed.toString(),
                          Icons.check_circle_rounded,
                          const Color(0xFF10B981),
                          statsLabel,
                        ).animate().fadeIn(delay: 300.ms).scale(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'معلقة',
                          pending.toString(),
                          Icons.schedule_rounded,
                          const Color(0xFFF59E0B),
                          statsLabel,
                        ).animate().fadeIn(delay: 400.ms).scale(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String statsLabel,
  ) {
    return Semantics(
      label: statsLabel,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(39),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withAlpha(51),
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
                    color: color.withAlpha(77),
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
                color: Colors.white.withAlpha(204),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
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
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
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
                
                // Only load suggestions if not already loading and suggestions are empty
                if (suggestions.suggestions.isEmpty && !suggestions.isLoading) {
                  // Delay the state modification to avoid modifying provider during widget build
                  Future(() {
                    ref.read(smartSuggestionsProvider.notifier).loadSuggestions([]);
                  });
                  return const Text('جاري تحميل الاقتراحات...');
                }
                
                if (suggestions.isLoading) {
                  return const Text('جاري تحميل الاقتراحات...');
                }
                
                if (suggestions.suggestions.isEmpty) {
                  return const Text('لا توجد اقتراحات حالياً');
                }
                
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions.suggestions.map((suggestion) {
                    return ActionChip(
                      label: Text(suggestion),
                      onPressed: () => _addSuggestedTask(ref, suggestion),
                      backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
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
    void onTap() {
      HapticService.light();
      _showTaskDetailsDialog(context, ref, task);
    }

    return Semantics(
      label: AccessibilityHelper.getTaskAccessibilityLabel(task),
      button: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          onEnter: (_) {
            // Add hover effect for web/desktop
          },
          child: Slidable(
          key: ValueKey(task.id),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (context) async {
                  HapticService.swipeStart();
                  final confirmed = await ConfirmationDialog.show(
                    context: context,
                    title: 'تأكيد الحذف',
                    message: 'هل أنت متأكد من حذف المهمة \'${task.title}\'؟ لا يمكن التراجع عن هذا الإجراء.',
                    confirmText: 'حذف',
                    cancelText: 'إلغاء',
                    isDangerous: true,
                    icon: Icons.delete_rounded,
                  );
                  
                  if (confirmed == true) {
                    HapticService.delete();
                    
                    // Store task for undo functionality
                    final deletedTask = task;
                    
                    // Delete task
                    await ref.read(tasksProvider.notifier).delete(task.id);
                    
                    // Show success message with undo
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(child: Text('تم حذف المهمة بنجاح')),
                          ],
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        action: SnackBarAction(
                          label: 'تراجع',
                          textColor: Colors.white,
                          onPressed: () {
                            HapticService.medium();
                            ref.read(tasksProvider.notifier).add(deletedTask);
                          },
                        ),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                    }
                  }
                },
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                icon: Icons.delete_rounded,
                label: 'حذف',
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (context) {
                  HapticService.swipeStart();
                  HapticService.toggle();
                  ref.read(tasksProvider.notifier).toggleDone(task.id);
                  
                  // Show success message
                  SuccessSnackBar.show(
                    context: context,
                    message: task.isDone 
                        ? SuccessMessages.taskUncompleted 
                        : SuccessMessages.taskCompleted,
                  );
                },
                backgroundColor: task.isDone 
                    ? const Color(0xFF64748B) 
                    : const Color(0xFF10B981),
                foregroundColor: Colors.white,
                icon: task.isDone 
                    ? Icons.cancel_rounded 
                    : Icons.check_circle_rounded,
                label: task.isDone ? 'إلغاء' : 'إكمال',
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ],
          ),
            child: AnimatedContainer(
              duration: 150.ms,
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: AnimatedContainer(
                  duration: 150.ms,
                  child: Checkbox(
                    value: task.isDone,
                    onChanged: (_) {
                      HapticService.toggle();
                      ref.read(tasksProvider.notifier).toggleDone(task.id);
                      
                      // Show success message
                      SuccessSnackBar.show(
                        context: context,
                        message: task.isDone 
                            ? SuccessMessages.taskUncompleted 
                            : SuccessMessages.taskCompleted,
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ).animate(target: task.isDone ? 1 : 0).scale(duration: 100.ms),
                title: AnimatedDefaultTextStyle(
                  duration: 150.ms,
                  style: TextStyle(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.w600,
                    color: task.isDone ? Colors.grey : const Color(0xFF1E293B),
                  ),
                  child: Text(task.title),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.note != null && task.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: 150.ms,
                        style: TextStyle(
                          color: task.isDone ? Colors.grey : const Color(0xFF64748B),
                        ),
                        child: Text(task.note!),
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
                            intl.DateFormat('MMM dd, HH:mm').format(task.dueDate!),
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
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.safeCategory.color.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        task.safeCategory.icon,
                        size: 14,
                        color: task.safeCategory.color,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('تعديل'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
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
                          HapticService.light();
                          _showTaskDetailsDialog(context, ref, task);
                        } else if (value == 'delete') {
                          HapticService.light();
                          final confirmed = await ConfirmationDialog.show(
                            context: context,
                            title: 'تأكيد الحذف',
                            message: 'هل أنت متأكد من حذف المهمة \'${task.title}\'؟ لا يمكن التراجع عن هذا الإجراء.',
                            confirmText: 'حذف',
                            cancelText: 'إلغاء',
                            isDangerous: true,
                            icon: Icons.delete_rounded,
                          );
                          
                          if (confirmed == true) {
                            HapticService.delete();
                            
                            // Store task for undo functionality
                            final deletedTask = task;
                            
                            // Delete task
                            await ref.read(tasksProvider.notifier).delete(task.id);
                            
                            // Show success message with undo
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 8),
                                    Expanded(child: Text('تم حذف المهمة بنجاح')),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF10B981),
                                action: SnackBarAction(
                                  label: 'تراجع',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    HapticService.medium();
                                    ref.read(tasksProvider.notifier).add(deletedTask);
                                  },
                                ),
                                duration: const Duration(seconds: 5),
                              ),
                            );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 50 * index))
      .fadeIn(duration: 150.ms, curve: Curves.easeOutCubic)
      .slideX(begin: 0.2, end: 0, curve: Curves.easeOutCubic)
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), curve: Curves.easeOutCubic);
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

  Future<void> _startVoiceInput(BuildContext context, WidgetRef ref) async {
    final voiceNotifier = ref.read(voiceProvider.notifier);
    final voiceState = ref.read(voiceProvider);

    if (voiceState.isListening) {
      await voiceNotifier.stopListening();
      return;
    }

    _showVoiceDialog(context, ref);

    await voiceNotifier.startListening(
      onResult: (text) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        if (text.isEmpty) return;

        final command = voiceNotifier.processCommand(text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم التعرف على: "$text"'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        _handleVoiceCommand(context, ref, command);
        _speakVoiceConfirmation(ref, command);
      },
    );
  }

  void _showVoiceDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic, color: Colors.red),
            SizedBox(width: 8),
            Text('الاستماع...'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('تحدث الآن...'),
            const SizedBox(height: 8),
            Text(
              'أمثلة:\n• "أضف مهمة اجتماع غداً"\n• "ابحث عن مهام العمل"',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(voiceProvider.notifier).stopListening();
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _speakVoiceConfirmation(WidgetRef ref, VoiceCommand command) {
    String confirmation = '';

    switch (command.type) {
      case VoiceCommandType.addTask:
        confirmation = 'تم إضافة المهمة';
        break;
      case VoiceCommandType.search:
        confirmation = 'جاري البحث';
        break;
      case VoiceCommandType.showTasks:
        confirmation = 'عرض المهام';
        break;
      case VoiceCommandType.completeTask:
        confirmation = 'تم إكمال المهمة';
        break;
      case VoiceCommandType.deleteTask:
        confirmation = 'تم حذف المهمة';
        break;
      default:
        confirmation = 'لم أفهم الأمر';
    }

    ref.read(voiceProvider.notifier).speak(confirmation);
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
        final query = command.data['query'] as String;
        ref.read(searchProvider.notifier).updateQuery(query);
        final allTasks = ref.read(tasksProvider);
        ref.read(searchProvider.notifier).performSearch(query, allTasks);
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
      category: taskCategoryFromString(analysis.suggestedCategory),
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

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final aiService = ref.read(aiServiceProvider);
    DateTime? selectedDate;
    int selectedPriority = 1;
    TaskCategory selectedCategory = TaskCategory.general;
    TaskAnalysis? aiAnalysis;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_task,
                  color: Color(0xFF667EEA),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'إضافة مهمة جديدة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان المهمة',
                    hintText: 'اكتب عنوان المهمة...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.title, color: Color(0xFF667EEA)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    errorText: titleController.text.isEmpty ? 'الرجاء إدخال عنوان المهمة' : null,
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        aiAnalysis = aiService.analyzeTaskText(value);
                        if (aiAnalysis != null) {
                          selectedPriority = aiAnalysis!.priority;
                          if (aiAnalysis!.dueDate != null) {
                            selectedDate = aiAnalysis!.dueDate;
                          }
                          selectedCategory = taskCategoryFromString(aiAnalysis!.suggestedCategory);
                        }
                      });
                    }
                  },
                ),
                if (aiAnalysis != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology, size: 16, color: Color(0xFF667EEA)),
                            SizedBox(width: 4),
                            Text(
                              'اقتراحات الذكاء الاصطناعي:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF667EEA),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
  '⏱️ المدة المتوقعة: ${aiAnalysis!.estimatedDuration}',
  style: const TextStyle(fontSize: 12),
),
                        Text(
                          '📂 الفئة المقترحة: ${aiAnalysis!.suggestedCategory}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    hintText: 'أضف ملاحظات...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.note, color: Color(0xFF667EEA)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('التصنيف:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TaskCategory.values.map((category) {
                    final isSelected = selectedCategory == category;
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
                          Text(category.displayName),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        HapticService.light();
                        setState(() {
                          selectedCategory = selected ? category : TaskCategory.general;
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
                const SizedBox(height: 16),
                const Text('الأولوية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriorityButton(0, 'منخفضة', Colors.green, selectedPriority, (value) {
                        HapticService.light();
                        setState(() {
                          selectedPriority = value;
                        });
                      }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityButton(1, 'متوسطة', Colors.orange, selectedPriority, (value) {
                        HapticService.light();
                        setState(() {
                          selectedPriority = value;
                        });
                      }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityButton(2, 'عالية', Colors.red, selectedPriority, (value) {
                        HapticService.light();
                        setState(() {
                          selectedPriority = value;
                        });
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(selectedDate == null 
                    ? 'تاريخ ووقت الاستحقاق (اختياري)' 
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} - ${selectedDate!.hour.toString().padLeft(2, '0')}:${selectedDate!.minute.toString().padLeft(2, '0')}'),
                  trailing: selectedDate != null 
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          HapticService.light();
                          setState(() {
                            selectedDate = null;
                          });
                        },
                      )
                    : null,
                  onTap: () async {
                    HapticService.light();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      // Show time picker after date picker
                      final time = await showTimePicker(
                        // ignore: use_build_context_synchronously
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
                      );
                      if (time != null) {
                        if (context.mounted) {
                          setState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      } else {
                        // If user cancels time picker, use default time (current time)
                        if (context.mounted) {
                          setState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              DateTime.now().hour,
                              DateTime.now().minute,
                            );
                          });
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticService.light();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('إلغاء', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                HapticService.buttonPress();
                
                if (titleController.text.isEmpty) {
                  setState(() {
                    // Validation error will be shown in the text field
                  });
                  return;
                }
                
                setState(() {
                  isLoading = true;
                });
                
                try {
                  final task = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    note: noteController.text.isEmpty ? null : noteController.text,
                    dueDate: selectedDate,
                    priority: selectedPriority,
                    category: selectedCategory,
                  );
                  
                  await ref.read(tasksProvider.notifier).add(task);
                  
                  // Show success animation
                  setState(() {
                    isLoading = false;
                  });
                  
                  HapticService.success();
                  if (context.mounted) {
                    SuccessSnackBar.show(
                      context: context,
                      message: SuccessMessages.taskAdded,
                    );
                  }
                  
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  
                  HapticService.error();
                  if (context.mounted) {
                    ErrorSnackBar.show(
                      context: context,
                      message: 'فشل في إضافة المهمة: ${e.toString()}',
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('إضافة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context, WidgetRef ref, Task task) {
    final titleController = TextEditingController(text: task.title);
    final noteController = TextEditingController(text: task.note ?? '');
    DateTime? selectedDate = task.dueDate;
    int selectedPriority = task.priority;
    TaskCategory selectedCategory = task.safeCategory;
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: Color(0xFF667EEA),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تفاصيل المهمة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'عنوان المهمة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.title, color: Color(0xFF667EEA)),
                    filled: true,
                    fillColor: isLoading ? Colors.grey[100] : Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.note, color: Color(0xFF667EEA)),
                    filled: true,
                    fillColor: isLoading ? Colors.grey[100] : Colors.grey[50],
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('التصنيف:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TaskCategory.values.map((category) {
                    final isSelected = selectedCategory == category;
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
                          Text(category.displayName),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: isLoading ? null : (selected) {
                        setState(() {
                          selectedCategory = selected ? category : TaskCategory.general;
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
                const SizedBox(height: 16),
                const Text('الأولوية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriorityButton(0, 'منخفضة', Colors.green, selectedPriority, isLoading ? null : (value) {
                        setState(() {
                          selectedPriority = value;
                        });
                      }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityButton(1, 'متوسطة', Colors.orange, selectedPriority, isLoading ? null : (value) {
                        setState(() {
                          selectedPriority = value;
                        });
                      }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityButton(2, 'عالية', Colors.red, selectedPriority, isLoading ? null : (value) {
                        setState(() {
                          selectedPriority = value;
                        });
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(selectedDate == null 
                    ? 'تاريخ ووقت الاستحقاق' 
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} - ${selectedDate!.hour.toString().padLeft(2, '0')}:${selectedDate!.minute.toString().padLeft(2, '0')}'),
                  trailing: selectedDate != null 
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: isLoading ? null : () {
                          setState(() {
                            selectedDate = null;
                          });
                        },
                      )
                    : null,
                  onTap: isLoading ? null : () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      // Show time picker after date picker
                      final time = await showTimePicker(
                        // ignore: use_build_context_synchronously
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
                      );
                      if (time != null) {
                        if (context.mounted) {
                          setState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      } else {
                        // If user cancels time picker, use default time (current time)
                        if (context.mounted) {
                          setState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              DateTime.now().hour,
                              DateTime.now().minute,
                            );
                          });
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('إلغاء', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    isLoading = true;
                  });
                  
                  try {
                    final updatedTask = task.copyWith(
                      title: titleController.text,
                      note: noteController.text.isEmpty ? null : noteController.text,
                      dueDate: selectedDate,
                      priority: selectedPriority,
                      category: selectedCategory,
                    );
                    
                    await ref.read(tasksProvider.notifier).update(updatedTask);
                    
                    HapticService.success();
                    if (context.mounted) {
                      SuccessSnackBar.show(
                        context: context,
                        message: SuccessMessages.taskUpdated,
                      );
                    }
                    
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    HapticService.error();
                    if (context.mounted) {
                      ErrorSnackBar.show(
                        context: context,
                        message: 'فشل في تحديث المهمة: ${e.toString()}',
                      );
                    }
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('حفظ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityButton(
    int value,
    String label,
    Color color,
    int selectedPriority,
    void Function(int)? onTap,
  ) {
    final isSelected = selectedPriority == value;
    return InkWell(
      onTap: onTap == null ? null : () => onTap(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  /// مؤشر التحميل ل Pagination
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF667EEA),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'جاري تحميل المزيد...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// رسالة نهاية القائمة
  Widget _buildEndOfListMessage() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد مهام أخرى',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddTask;

  const _EmptyState({required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              'لا توجد مهام حاليًا',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة مهمة جديدة لتنظيم يومك.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add),
              label: const Text('إضافة مهمة جديدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
