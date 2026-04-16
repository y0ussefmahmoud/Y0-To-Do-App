// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart' as intl;

import '../providers/search_provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_filter.dart';
import '../widgets/task_filter_chips.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_results_widget.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/task_skeleton.dart';
import '../widgets/error_snackbar.dart';
import '../widgets/success_snackbar.dart';
import '../widgets/neo_morphic_components.dart';
import '../theme/y0_design_system.dart';
import '../services/haptic_service.dart';
import 'add_edit_task_screen.dart';
import '../services/speech_service.dart';
import '../services/ai_service.dart';

/// 🏠 Y0 To-Do App - Neo-Morphic Home Screen V2.4.0
/// 
/// This screen implements the Editorial Neo-Minimalism design system with:
/// - Neo-morphic cards with ambient shadows
/// - Surface hierarchy without borders (The "No-Line" Rule)
/// - RTL-optimized typography and layouts
/// - Smooth micro-interactions and animations
/// - Glassmorphic elements for floating components
/// 
/// Key Features:
/// - Smart greeting card with daily progress
/// - Neo-morphic task cards with priority colors
/// - Glassmorphic FAB with speed dial
/// - Surface-based filtering system
/// - Ambient shadows for depth perception
/// 
/// @author Y0 Development Team
/// @version 2.4.0
class HomeScreenV2 extends ConsumerWidget {
  const HomeScreenV2({super.key});

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
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompactScreen = screenHeight < 600;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
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
            physics: const BouncingScrollPhysics(),
            cacheExtent: 500, // Improve performance by caching more items
            slivers: [
              // ==================== NEO-MORPHIC HEADER ====================
              SliverAppBar(
                expandedHeight: isCompactScreen ? 280 : 320,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildSmartGreetingCard(context, completedTasks, pendingTasks),
                ),
                actions: [
                  // Statistics Button
                  Y0NeoMorphicComponents.neoCard(
                    padding: const EdgeInsets.all(8),
                    onTap: () {
                      Navigator.pushNamed(context, '/statistics');
                    },
                    child: Icon(
                      Icons.analytics,
                      color: context.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Settings Button
                  Y0NeoMorphicComponents.neoCard(
                    padding: const EdgeInsets.all(8),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: Icon(
                      Icons.settings,
                      color: context.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              // ==================== SEARCH BAR SECTION ====================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Neo-morphic Search Bar
                      Y0NeoMorphicComponents.neoCard(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: const SearchBarWidget(),
                      ),
                      
                      // Surface-based Filter Chips
                      if (searchState.query.isEmpty)
                        _buildFilterSection(context, ref, filter),
                    ],
                  ),
                ),
              ),

              // ==================== TASKS LIST ====================
              if (searchState.query.isNotEmpty)
                // Search Results
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: const SearchResultsWidget().animate().fadeIn(duration: Y0DesignSystem.animationMedium),
                )
              else if (isLoading && tasks.isEmpty)
                // Loading State
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const TaskSkeleton(),
                      childCount: 5,
                    ),
                  ),
                )
              else if (tasks.isEmpty)
                // Empty State
                SliverToBoxAdapter(
                  child: _buildEmptyState(context, ref, filter),
                )
              else
                // Tasks List
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == tasks.length && hasMorePages) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: context.colorScheme.primary,
                              ),
                            ),
                          );
                        }

                        final task = tasks[index];
                        return _buildNeoMorphicTaskCard(context, ref, task, index);
                      },
                      childCount: tasks.length + (hasMorePages ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      
      // ==================== GLASSMORPHIC FAB ====================
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildGlassmorphicFAB(context, ref, isCompactScreen),
    );
  }

  /// 🎴 Smart Greeting Card with Daily Progress
  /// 
  /// Displays personalized greeting based on time of day,
  /// shows daily progress with Progress Orb, and includes
  /// quick stats about today's tasks.
  Widget _buildSmartGreetingCard(BuildContext context, int completedTasks, int pendingTasks) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = _getGreeting(hour);
    final totalTasks = completedTasks + pendingTasks;
    final progressPercentage = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final completionRate = progressPercentage * 100;
    final date = intl.DateFormat('EEEE, d MMMM', 'ar').format(now);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            context.colorScheme.primary.withValues(alpha:0.1),
            context.colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Greeting Section - All elements on the right
              Row(
                textDirection: TextDirection.ltr, // Use LTR to position on right
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Profile Avatar or Icon - Rightmost
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.colorScheme.primary,
                          context.colorScheme.primaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.primary.withValues(alpha:0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      color: context.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ).animate().scale(delay: 400.ms, duration: Y0DesignSystem.animationMedium),
                  
                  const SizedBox(width: 12),
                  
                  // Greeting Text and Date - Right aligned
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Greeting Text
                      Text(
                        greeting,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontSize: context.getResponsiveFontSize(28),
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).animate().fadeIn(duration: Y0DesignSystem.animationMedium),
                      
                      const SizedBox(height: 4),
                      
                      // Date
                      Text(
                        date,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ).animate().fadeIn(delay: 200.ms, duration: Y0DesignSystem.animationMedium),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Progress Section
              Y0NeoMorphicComponents.neoCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    // Progress Indicator
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Progress Title
                          Text(
                            'معدل الإنجاز اليوم',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Progress Bar
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: context.colorScheme.surfaceContainerHighest,
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerRight,
                              widthFactor: completionRate / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [
                                      context.colorScheme.primary,
                                      context.colorScheme.primaryContainer,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Progress Stats
                          Row(
                            textDirection: TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$completedTasks مكتمل',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$totalTasks إجمالي',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Circular Progress
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            context.colorScheme.primary.withValues(alpha:0.1),
                            context.colorScheme.primaryContainer.withValues(alpha:0.1),
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background Circle
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 6,
                            backgroundColor: context.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          // Progress Circle
                          CircularProgressIndicator(
                            value: completionRate / 100,
                            strokeWidth: 6,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colorScheme.primary,
                            ),
                          ),
                          // Percentage Text
                          Text(
                            '${completionRate.toInt()}%',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(delay: 300.ms, duration: Y0DesignSystem.animationMedium),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎯 Filter Section with Surface Hierarchy
  /// 
  /// Implements the "No-Line" rule by using surface tonal shifts
  /// instead of borders to separate filter sections.
  Widget _buildFilterSection(BuildContext context, WidgetRef ref, TaskFilter filter) {
    return Y0NeoMorphicComponents.surfaceSection(
      surfaceLevel: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Filter Header
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تصفية المهام',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ),
              if (filter.isActive)
                GestureDetector(
                  onTap: () => ref.read(taskFilterProvider.notifier).state = const TaskFilter(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'مسح التصفية',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Filter Chips
          TaskFilterChips(filter: filter),
        ],
      ),
    ).animate().slideY(delay: 500.ms, duration: Y0DesignSystem.animationMedium);
  }

  /// 🎴 Neo-Morphic Task Card
  /// 
  /// Implements the core design principles:
  /// - Neo-morphic card with ambient shadows
  /// - Priority-based color coding
  /// - Smooth swipe actions
  /// - RTL-optimized layout
  /// - Micro-interactions on tap
  Widget _buildNeoMorphicTaskCard(BuildContext context, WidgetRef ref, Task task, int index) {
    final priorityColor = _getPriorityColor(task.priority);
    final isCompleted = task.isDone;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Slidable(
        key: ValueKey(task.id),
        direction: Axis.horizontal,
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          children: [
            // Delete Action
            SlidableAction(
              onPressed: (_) => _showDeleteConfirmation(context, ref, task),
              backgroundColor: Colors.red.withValues(alpha:0.1),
              foregroundColor: Colors.red,
              icon: Icons.delete,
              label: 'حذف',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          children: [
            // Edit Action
            SlidableAction(
              onPressed: (_) => _showEditTaskDialog(context, ref, task),
              backgroundColor: context.colorScheme.primary.withValues(alpha:0.1),
              foregroundColor: context.colorScheme.primary,
              icon: Icons.edit,
              label: 'تعديل',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Y0NeoMorphicComponents.neoCard(
            padding: const EdgeInsets.all(8),
            onTap: () => _showEditTaskDialog(context, ref, task),
            child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Priority Indicator
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(width: 4),
              
              // Task Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: isCompleted ? context.colorScheme.onSurfaceVariant : 
                                           context.colorScheme.onSurface,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (task.note?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.note!,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Task Metadata
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Category
                        if (task.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.category!.name,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        
                        const SizedBox(width: 6),
                        
                        // Due Date
                        if (task.dueDate != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                intl.DateFormat('d MMM', 'ar').format(task.dueDate!),
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        
                        // Completion Checkbox
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            ref.read(tasksProvider.notifier).toggleDone(task.id);
                            HapticService.light();
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isCompleted ? context.colorScheme.primary : 
                                             context.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(6),
                              border: isCompleted ? null : Border.all(
                                color: context.colorScheme.outlineVariant.withValues(alpha:0.3),
                              ),
                            ),
                            child: isCompleted
                                ? Icon(
                                    Icons.check,
                                    color: context.colorScheme.onPrimary,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 6),
              
              // Completion Checkbox
              GestureDetector(
                onTap: () {
                  ref.read(tasksProvider.notifier).toggleDone(task.id);
                  HapticService.light();
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted ? context.colorScheme.primary : 
                                   context.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(4),
                    border: isCompleted ? null : Border.all(
                      color: context.colorScheme.outlineVariant.withValues(alpha:0.3),
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: context.colorScheme.onPrimary,
                          size: 14,
                        )
                      : null,
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    ).animate()
     .fadeIn(delay: (index * 100).ms, duration: Y0DesignSystem.animationMedium)
     .slideX(delay: (index * 100).ms, duration: Y0DesignSystem.animationMedium);
  }

  /// 🌊 Glassmorphic FAB with Speed Dial
  /// 
  /// Implements the floating FAB with glassmorphic effect
  /// and speed dial for multiple actions.
  Widget _buildGlassmorphicFAB(BuildContext context, WidgetRef ref, bool isCompactHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Voice Input Button - Smaller
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.primary.withValues(alpha:0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _startVoiceInput(context, ref),
            icon: Icon(
              Icons.mic,
              color: context.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
        ).animate().scale(delay: 200.ms, duration: Y0DesignSystem.animationFast),
        
        const SizedBox(height: 8),
        
        // Add Task Button - Smaller
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colorScheme.primary,
                context.colorScheme.primaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.primary.withValues(alpha:0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _showAddTaskDialog(context, ref),
            icon: Icon(
              Icons.add,
              color: context.colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ).animate().scale(delay: 300.ms, duration: Y0DesignSystem.animationFast),
      ],
    );
  }

  /// 📭 Empty State with Editorial Design
  /// 
  /// Shows a beautiful empty state with editorial typography
  /// and clear call-to-action.
  Widget _buildEmptyState(BuildContext context, WidgetRef ref, TaskFilter filter) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty State Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 60,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ).animate()
           .scale(duration: Y0DesignSystem.animationMedium)
           .then()
           .shimmer(duration: Y0DesignSystem.animationSlow),
          
          const SizedBox(height: 24),
          
          // Empty State Text
          Text(
            'لا توجد مهام حالياً',
            style: context.textTheme.headlineMedium?.copyWith(
              color: context.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: Y0DesignSystem.animationMedium),
          
          const SizedBox(height: 8),
          
          Text(
            'ابدأ بإضافة مهمة جديدة لتنظيم يومك',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms, duration: Y0DesignSystem.animationMedium),
          
          const SizedBox(height: 32),
          
          // Add Task Button
          Y0NeoMorphicComponents.neoPrimaryButton(
            text: 'إضافة أول مهمة',
            onPressed: () => _showAddTaskDialog(context, ref),
            icon: Icons.add,
          ).animate().fadeIn(delay: 400.ms, duration: Y0DesignSystem.animationMedium),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  /// 🌅 Get greeting based on time of day
  String _getGreeting(int hour) {
    if (hour < 12) return 'صباح الخير!';
    if (hour < 17) return 'طاب مساؤك!';
    return 'مساء الخير!';
  }

  /// 🎨 Get priority color based on task priority
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2: return Y0DesignSystem.priorityHigh;
      case 1: return Y0DesignSystem.priorityMedium;
      case 0: return Y0DesignSystem.priorityLow;
      default: return Y0DesignSystem.priorityLow;
    }
  }

  // ==================== TASK OPERATIONS ====================

  /// 🎤 Start voice input
  void _startVoiceInput(BuildContext context, WidgetRef ref) async {
    try {
      HapticService.light();
      final speechService = SpeechService();
      final isAvailable = await speechService.initialize();
      
      if (!isAvailable) {
        if (context.mounted) {
          ErrorSnackBar.show(
              context: context,
              message: 'الإدخال الصوتي غير متاح على جهازك',
              onRetry: () => Navigator.pushNamed(context, '/settings'),
            );
        }
        return;
      }

      String result = '';
      await speechService.startListening(
        onResult: (text) {
          result = text;
        },
        onError: (error) {
          throw Exception(error);
        },
      );
      
      if (result.isNotEmpty && context.mounted) {
        final aiService = AIService();
        final analysis = aiService.analyzeTaskText(result);
        
        // Convert string category to TaskCategory enum
        TaskCategory? category;
        switch (analysis.suggestedCategory) {
          case 'work':
            category = TaskCategory.work;
            break;
          case 'personal':
            category = TaskCategory.personal;
            break;
          case 'study':
            category = TaskCategory.study;
            break;
          case 'health':
            category = TaskCategory.health;
            break;
          default:
            category = TaskCategory.general;
        }
        
        _showAddTaskDialog(
          context,
          ref,
          initialTitle: result, // Use the original result as title
          initialDescription: '', // No description from AI analysis
          initialPriority: analysis.priority,
          initialCategory: category,
          initialDueDate: analysis.dueDate,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ErrorSnackBar.show(
          context: context,
          message: 'حدث خطأ في الإدخال الصوتي: $e',
        );
      }
    }
  }

  /// 📝 Show add task dialog
  void _showAddTaskDialog(
    BuildContext context,
    WidgetRef ref, {
    String? initialTitle,
    String? initialDescription,
    int? initialPriority,
    TaskCategory? initialCategory,
    DateTime? initialDueDate,
  }) async {
    HapticService.light();
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditTaskScreen(),
      ),
    );
    
    if (result != null) {
      ref.read(tasksProvider.notifier).add(result);
      HapticService.success();
    }
  }

  /// ✏️ Show edit task dialog
  Future<void> _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) async {
    HapticService.light();
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(task: task),
      ),
    );
    
    if (result != null) {
      ref.read(tasksProvider.notifier).update(result);
      HapticService.success();
    }
  }

  /// 🗑️ Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref, Task task) async {
    HapticService.medium();
    final result = await ConfirmationDialog.show(
          context: context,
          title: 'حذف المهمة',
          message: 'هل أنت متأكد من حذف "${task.title}"؟',
          confirmText: 'حذف',
          cancelText: 'إلغاء',
        );
        
        if (result == true) {
          ref.read(tasksProvider.notifier).delete(task.id);
          // Store context before showing snackbar to avoid async gap issue
          final ctx = context;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ctx.mounted) {
              SuccessSnackBar.show(
                context: ctx,
                message: 'تم حذف المهمة بنجاح',
              );
            }
          });
        }
  }
}
