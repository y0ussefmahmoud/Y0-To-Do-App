import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/y0_design_system.dart';
import '../widgets/neo_morphic_card.dart';
import '../widgets/daily_progress_orb.dart';
import '../widgets/bottom_navigation.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_filter.dart';
import '../models/app_settings.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/search_provider.dart';
import '../services/task_service.dart';
import 'add_edit_task_screen.dart';

/// 🏠 Y0 To-Do App - Neo-morphic Home Screen
/// 
/// الشاشة الرئيسية الجديدة بالتصميم Neo-morphic المحول من HTML
/// تحتوي على كل المكونات الرئيسية مع الحفاظ على جودة الكود 100%
/// 
/// المكونات الرئيسية:
/// - Top App Bar مع معلومات المستخدم
/// - Smart Greeting Card مع تحية ذكية
/// - Daily Progress Orb Card مع مؤشر التقدم
/// - Search Bar مع الفلاتر السريعة
/// - Quick Filters للمهام
/// - Task List مع نظام الأولويات
/// - Multi-functional FAB
/// - Bottom Navigation
/// 
/// @author Y0 Development Team
/// @version 3.1.0
class HomeScreenNeoMorphic extends ConsumerStatefulWidget {
  const HomeScreenNeoMorphic({super.key});

  @override
  ConsumerState<HomeScreenNeoMorphic> createState() => _HomeScreenNeoMorphicState();
}

class _HomeScreenNeoMorphicState extends ConsumerState<HomeScreenNeoMorphic> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على المهام الحقيقية من قاعدة البيانات
    final tasks = ref.watch(filteredTasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final settings = ref.watch(settingsProvider);
    final completedTasks = tasks.where((task) => task.isDone).length;
    final totalTasks = tasks.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            _buildSliverAppBar(context, settings),
            
            // Main Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: Y0DesignSystem.spacing3,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Smart Greeting Card
                  _buildSmartGreetingCard(context, settings),
                  
                  const SizedBox(height: Y0DesignSystem.spacing3),
                  
                  // Daily Progress Orb Card
                  _buildDailyProgressCard(context, progress, completedTasks, totalTasks),
                  
                  const SizedBox(height: Y0DesignSystem.spacing3),
                  
                  // Search Bar with Quick Filters
                  _buildSearchSection(context),
                  
                  const SizedBox(height: Y0DesignSystem.spacing3),
                  
                  // Quick Filters
                  _buildQuickFilters(context, filter, ref),
                  
                  const SizedBox(height: Y0DesignSystem.spacing2),
                  
                  // Task List
                  _buildTaskList(context, ref, tasks),
                  
                  // Bottom padding for FAB and navigation
                  const SizedBox(height: 160),
                ]),
              ),
            ),
          ],
        ),
      ),
      
      // Multi-functional FAB
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice Input FAB
          FloatingActionButton(
            heroTag: "voice",
            onPressed: () => _startVoiceInput(context, ref),
            backgroundColor: context.colorScheme.primaryContainer,
            foregroundColor: context.colorScheme.onPrimaryContainer,
            child: const Icon(Icons.mic),
          ),
          
          const SizedBox(height: 16),
          
          // Regular Add Task FAB
          FloatingActionButton(
            heroTag: "add",
            onPressed: () => _showAddTaskDialog(context, ref),
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      
      // Bottom Navigation
      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        onTap: (index) => _handleNavigationTap(context, ref, index),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ==================== WIDGET BUILDERS ====================
  
  /// 📱 شريط التطبيق العلوي مع معلومات المستخدم وزر البحث
  Widget _buildSliverAppBar(BuildContext context, AppSettings settings) {
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
                  // User Info
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      // App Name
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

  // ==================== SMART GREETING CARD ====================
  
  /// 👋 بطاقة الترحيب الذكية مع معلومات الوقت والتاريخ
  Widget _buildSmartGreetingCard(BuildContext context, AppSettings settings) {
    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            // Greeting Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'أهلاً بك، ${settings.userName}!',
                  style: context.textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: Y0DesignSystem.spacing2),
                
                Text(
                  'مساء الخير، حان وقت إنجاز مهامك.',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(height: Y0DesignSystem.spacing3),
                
                // Date and Time Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Y0DesignSystem.spacing3,
                    vertical: Y0DesignSystem.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        Icons.schedule,
                        color: context.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: Y0DesignSystem.spacing2),
                      Text(
                        _getCurrentDateArabic(),
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DAILY PROGRESS CARD ====================
  
  /// 📊 بطاقة إنجاز اليوم مع مؤشر دائري
  Widget _buildDailyProgressCard(BuildContext context, double progress, int completedTasks, int totalTasks) {
    return Container(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      decoration: BoxDecoration(
        gradient: Y0DesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
        boxShadow: Y0DesignSystem.floatingShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // معلومات التقدم
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'إنجازك لليوم: ${(progress * 100).round()}%',
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: Y0DesignSystem.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: Y0DesignSystem.spacing2),
                
                Text(
                  progress >= 0.75
                      ? 'أنت قريب جداً من إنهاء خطتك اليومية!'
                      : progress >= 0.5
                          ? 'أنت تسير بخطى جيدة، استمر!'
                          : 'لنبدأ اليوم بإنجاز مهامك!',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: Y0DesignSystem.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                
                const SizedBox(height: Y0DesignSystem.spacing2),
                
                // إحصائيات المهام
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Y0DesignSystem.spacing2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Y0DesignSystem.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$completedTasks من $totalTasks مهمة',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: Y0DesignSystem.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: Y0DesignSystem.spacing3),
                
                // شريط التقدم الخطي
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Y0DesignSystem.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Y0DesignSystem.onPrimary,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Y0DesignSystem.onPrimary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // المؤشر الدائري
          Expanded(
            flex: 1,
            child: DailyProgressOrb(
              progress: progress,
              size: 80,
              progressColor: Y0DesignSystem.onPrimary,
              backgroundColor: Y0DesignSystem.onPrimary.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SEARCH SECTION ====================
  
  /// 🔍 شريط البحث مع الفلاتر السريعة
  Widget _buildSearchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search Bar
        NeoMorphicCard(
          isInset: true,
          padding: const EdgeInsets.symmetric(
            horizontal: Y0DesignSystem.spacing3,
            vertical: Y0DesignSystem.spacing3,
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                Icons.search,
                color: context.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: Y0DesignSystem.spacing2),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: context.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مهمة...',
                    hintStyle: TextStyle(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // Search functionality will filter tasks
                    ref.read(searchProvider.notifier).updateQuery(value);
                  },
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: Y0DesignSystem.spacing2),
        
        // Quick Filter Tags - Horizontal Scrollable
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            children: [
              'مشروع التخرج',
              'قائمة التسوق',
              'تمارين الصباح',
              'العمل',
              'الدراسة',
            ].map((tag) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: NeoMorphicCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: Y0DesignSystem.spacing2,
                  vertical: 4,
                ),
                child: Text(
                  tag,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  // ==================== QUICK FILTERS ====================
  
  /// 🎯 أزرار الفلترة السريعة للمهام
  Widget _buildQuickFilters(BuildContext context, TaskFilter currentFilter, WidgetRef ref) {
    final allTasks = ref.watch(tasksProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _handleViewAll(context, ref),
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            Text(
              'المهام',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: Y0DesignSystem.spacing2),
        
        // Filter Buttons with Neo-morphic design - Horizontal Scrollable
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            children: [
              _buildStatusFilterButton(context, TaskStatus.completed, currentFilter.status, ref, allTasks),
              _buildStatusFilterButton(context, TaskStatus.pending, currentFilter.status, ref, allTasks),
              _buildDateFilterButton(context, DateFilter.today, currentFilter.dateFilter, ref, allTasks),
              _buildDateFilterButton(context, DateFilter.thisWeek, currentFilter.dateFilter, ref, allTasks),
              _buildPriorityFilterButton(context, 3, currentFilter.priority, ref, allTasks), // عالي
              _buildCategoryFilterButton(context, TaskCategory.work, currentFilter.category, ref, allTasks), // العمل
              _buildCategoryFilterButton(context, TaskCategory.personal, currentFilter.category, ref, allTasks), // الشخصي
              _buildCategoryFilterButton(context, TaskCategory.study, currentFilter.category, ref, allTasks), // الدراسة
              _buildCategoryFilterButton(context, TaskCategory.health, currentFilter.category, ref, allTasks), // الصحة
              _buildCategoryFilterButton(context, TaskCategory.general, currentFilter.category, ref, allTasks), // عامة
              _buildCategoryFilterButton(context, TaskCategory.shopping, currentFilter.category, ref, allTasks), // التسوق
              _buildCategoryFilterButton(context, TaskCategory.entertainment, currentFilter.category, ref, allTasks), // الترفيه
            ],
          ),
        ),
      ],
    );
  }

  /// أيقونة فلتر الحالة
  Widget _buildStatusFilterIcon(BuildContext context, TaskStatus status, bool isActive) {
    return Icon(
      status == TaskStatus.completed ? Icons.check_circle : Icons.pending,
      size: 14,
      color: isActive 
          ? context.colorScheme.onPrimary 
          : context.colorScheme.onSurfaceVariant,
    );
  }

  /// زر فلتر الحالة (مكتملة/غير مكتملة)
  Widget _buildStatusFilterButton(BuildContext context, TaskStatus status, TaskStatus? currentStatus, WidgetRef ref, List<Task> allTasks) {
    final isActive = status == currentStatus;
    final filteredCount = status == TaskStatus.completed
        ? allTasks.where((task) => task.isDone).length
        : allTasks.where((task) => !task.isDone).length;
    
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: NeoMorphicCard(
        padding: const EdgeInsets.symmetric(
          horizontal: Y0DesignSystem.spacing2,
          vertical: Y0DesignSystem.spacing2 / 2,
        ),
        borderRadius: BorderRadius.circular(50),
        color: isActive 
            ? context.colorScheme.primary 
            : context.colorScheme.surfaceContainerLow,
        onTap: () {
          ref.read(taskFilterProvider.notifier).state = TaskFilter(status: status);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة الفلتر
            _buildStatusFilterIcon(context, status, isActive),
            
            const SizedBox(width: 4),
            
            // نص الفلتر
            Text(
              status.displayName,
              style: TextStyle(
                color: isActive 
                    ? context.colorScheme.onPrimary 
                    : context.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            
            const SizedBox(width: 4),
            
            // عدد المهام
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive 
                    ? context.colorScheme.onPrimary.withValues(alpha: 0.2)
                    : context.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                filteredCount.toString(),
                style: TextStyle(
                  color: isActive 
                      ? context.colorScheme.onPrimary 
                      : context.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// زر فلتر التاريخ
  Widget _buildDateFilterButton(BuildContext context, DateFilter filter, DateFilter? currentFilter, WidgetRef ref, List<Task> allTasks) {
    final isActive = filter == currentFilter;
    final filteredCount = _getTasksCountForDateFilter(allTasks, filter);
    
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: NeoMorphicCard(
        padding: const EdgeInsets.symmetric(
          horizontal: Y0DesignSystem.spacing2,
          vertical: Y0DesignSystem.spacing2 / 2,
        ),
        borderRadius: BorderRadius.circular(50),
        color: isActive 
            ? context.colorScheme.primary 
            : context.colorScheme.surfaceContainerLow,
        onTap: () {
          ref.read(taskFilterProvider.notifier).state = TaskFilter(dateFilter: filter);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة الفلتر
            Icon(
              _getDateFilterIcon(filter),
              size: 14,
              color: isActive 
                  ? context.colorScheme.onPrimary 
                  : context.colorScheme.onSurfaceVariant,
            ),
            
            const SizedBox(width: 4),
            
            // نص الفلتر
            Text(
              filter.displayName,
              style: context.textTheme.labelSmall?.copyWith(
                color: isActive 
                    ? context.colorScheme.onPrimary 
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            
            if (filteredCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive 
                      ? context.colorScheme.onPrimary.withValues(alpha: 0.2)
                      : context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$filteredCount',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isActive 
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onPrimaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// زر فلتر الأولوية
  Widget _buildPriorityFilterButton(BuildContext context, int priority, int? currentPriority, WidgetRef ref, List<Task> allTasks) {
    final isActive = priority == currentPriority;
    final filteredCount = allTasks.where((task) => task.priority == priority).length;
    
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: NeoMorphicCard(
        padding: const EdgeInsets.symmetric(
          horizontal: Y0DesignSystem.spacing2,
          vertical: Y0DesignSystem.spacing2 / 2,
        ),
        borderRadius: BorderRadius.circular(50),
        color: isActive 
            ? context.colorScheme.primary 
            : context.colorScheme.surfaceContainerLow,
        onTap: () {
          ref.read(taskFilterProvider.notifier).state = TaskFilter(priority: priority);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة الفلتر
            Icon(
              Icons.flag,
              size: 14,
              color: isActive 
                  ? context.colorScheme.onPrimary 
                  : context.colorScheme.onSurfaceVariant,
            ),
            
            const SizedBox(width: 4),
            
            // نص الفلتر
            Text(
              'الأولوية',
              style: context.textTheme.labelSmall?.copyWith(
                color: isActive 
                    ? context.colorScheme.onPrimary 
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            
            if (filteredCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive 
                      ? context.colorScheme.onPrimary.withValues(alpha: 0.2)
                      : context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$filteredCount',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isActive 
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onPrimaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// زر فلتر الفئة
  Widget _buildCategoryFilterButton(BuildContext context, TaskCategory category, TaskCategory? currentCategory, WidgetRef ref, List<Task> allTasks) {
    final isActive = category == currentCategory;
    final filteredCount = allTasks.where((task) => task.category == category).length;
    
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: NeoMorphicCard(
        padding: const EdgeInsets.symmetric(
          horizontal: Y0DesignSystem.spacing2,
          vertical: Y0DesignSystem.spacing2 / 2,
        ),
        borderRadius: BorderRadius.circular(50),
        color: isActive 
            ? context.colorScheme.primary 
            : context.colorScheme.surfaceContainerLow,
        onTap: () {
          ref.read(taskFilterProvider.notifier).state = TaskFilter(category: category);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة الفلتر
            Icon(
              _getCategoryIcon(category),
              size: 14,
              color: isActive 
                  ? context.colorScheme.onPrimary 
                  : context.colorScheme.onSurfaceVariant,
            ),
            
            const SizedBox(width: 4),
            
            // نص الفلتر
            Text(
              _getCategoryName(category),
              style: context.textTheme.labelSmall?.copyWith(
                color: isActive 
                    ? context.colorScheme.onPrimary 
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            
            if (filteredCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive 
                      ? context.colorScheme.onPrimary.withValues(alpha: 0.2)
                      : context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$filteredCount',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isActive 
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onPrimaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// الحصول على عدد المهام لفلتر التاريخ
  int _getTasksCountForDateFilter(List<Task> tasks, DateFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    switch (filter) {
      case DateFilter.today:
        return tasks.where((task) {
          if (task.dueDate == null) return false;
          final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
          return taskDate.isAtSameMomentAs(today);
        }).length;
      case DateFilter.thisWeek:
        return tasks.where((task) {
          if (task.dueDate == null) return false;
          final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
          return !taskDate.isBefore(weekStart) && !taskDate.isAfter(weekEnd);
        }).length;
      case DateFilter.overdue:
        return tasks.where((task) {
          return task.dueDate != null && task.dueDate!.isBefore(now) && !task.isDone;
        }).length;
      case DateFilter.all:
        return tasks.length;
    }
  }

  /// الحصول على أيقونة فلتر التاريخ
  IconData _getDateFilterIcon(DateFilter filter) {
    switch (filter) {
      case DateFilter.today:
        return Icons.today;
      case DateFilter.thisWeek:
        return Icons.date_range;
      case DateFilter.overdue:
        return Icons.warning;
      case DateFilter.all:
        return Icons.calendar_today;
    }
  }

  /// الحصول على أيقونة الفئة
  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.shopping:
        return Icons.shopping_cart;
      case TaskCategory.health:
        return Icons.favorite;
      case TaskCategory.study:
        return Icons.school;
      case TaskCategory.general:
        return Icons.category;
      case TaskCategory.entertainment:
        return Icons.movie;
    }
  }

  /// الحصول على اسم الفئة
  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'العمل';
      case TaskCategory.personal:
        return 'الشخصي';
      case TaskCategory.shopping:
        return 'التسوق';
      case TaskCategory.health:
        return 'الصحة';
      case TaskCategory.study:
        return 'الدراسة';
      case TaskCategory.general:
        return 'عامة';
      case TaskCategory.entertainment:
        return 'الترفيه';
    }
  }

  // ==================== TASK LIST ====================
  
  /// مربع اختيار المهمة
  Widget _buildTaskCheckbox(BuildContext context, WidgetRef ref, Task task) {
    return GestureDetector(
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
    );
  }
  
  /// تفاصيل المهمة
  Widget _buildTaskDetails(BuildContext context, Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          task.title,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            decoration: task.isDone
                ? TextDecoration.lineThrough
                : null,
            color: task.isDone
                ? context.colorScheme.onSurface.withValues(alpha: 0.5)
                : null,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          task.note ?? '',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  /// قائمة المهام مع نظام الأولويات
  Widget _buildTaskList(BuildContext context, WidgetRef ref, List<Task> tasks) {
    return Column(
      children: tasks.map((task) => Padding(
        padding: const EdgeInsets.only(bottom: Y0DesignSystem.spacing2),
        child: _buildTaskCard(context, ref, task),
      )).toList(),
    );
  }

  /// بطاقة المهمة الواحدة
  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task) {
    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Task Info
          Expanded(
            flex: 4,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // Checkbox
                _buildTaskCheckbox(context, ref, task),
                
                const SizedBox(width: Y0DesignSystem.spacing2),
                
                // Task Details
                Expanded(
                  child: _buildTaskDetails(context, task),
                ),
              ],
            ),
          ),
          
          // Priority Badge
          _buildPriorityBadge(context, task),
          
          // Edit and Delete Buttons
          _buildTaskActionButtons(context, ref, task),
        ],
      ),
    );
  }

  /// 🎨 شارة الأولوية
  Widget _buildPriorityBadge(BuildContext context, Task task) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getPriorityColor(task.priority).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getPriorityColor(task.priority),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _getPriorityText(task.priority),
            style: TextStyle(
              color: _getPriorityColor(task.priority),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 🛠️ أزرار إجراءات المهمة (تعديل/حذف)
  Widget _buildTaskActionButtons(BuildContext context, WidgetRef ref, Task task) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _editTask(context, ref, task),
          color: context.colorScheme.primary,
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 20),
          onPressed: () => _deleteTask(context, ref, task),
          color: Colors.red,
        ),
      ],
    );
  }

  // ==================== HELPER METHODS ====================
  
  /// 🎨 الحصول على لون الأولوية
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3: // high
        return Y0DesignSystem.priorityHigh;
      case 2: // medium
        return Y0DesignSystem.priorityMedium;
      case 1: // low
      default:
        return Y0DesignSystem.priorityLow;
    }
  }

  /// 📝 الحصول على نص الأولوية
  String _getPriorityText(int priority) {
    switch (priority) {
      case 3: // high
        return 'عالي';
      case 2: // medium
        return 'متوسط';
      case 1: // low
      default:
        return 'منخفض';
    }
  }

  /// 📅 الحصول على التاريخ الحالي بالعربية
  String _getCurrentDateArabic() {
    final now = DateTime.now();
    
    // أسماء الأيام بالعربية
    const arabicWeekdays = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    
    // أسماء الأشهر بالعربية
    const arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    
    // تحويل الأرقام إلى أرقام عربية
    String toArabicNumeral(int number) {
      const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      return number.toString().split('').map((d) => arabicNumerals[int.parse(d)]).join('');
    }
    
    final weekday = arabicWeekdays[now.weekday % 7];
    final month = arabicMonths[now.month - 1];
    final day = toArabicNumeral(now.day);
    
    return '$weekday، $day $month';
  }

  // ==================== EVENT HANDLERS ====================
  
  /// 🎤 بدء الإدخال الصوتي للمهمة
  void _startVoiceInput(BuildContext context, WidgetRef ref) {
    // Voice input feature - optional
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('الإدخال الصوتي قيد التطوير')),
    );
  }

  /// 📝 عرض حوار إضافة مهمة جديدة
  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditTaskScreen(),
      ),
    );
  }

  ///  معالج عرض كل المهام
  void _handleViewAll(BuildContext context, WidgetRef ref) {
    // إعادة تعيين جميع الفلاتر
    ref.read(taskFilterProvider.notifier).state = const TaskFilter();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم عرض جميع المهام')),
    );
  }

  /// 🧭 معالج التنقل
  void _handleNavigationTap(BuildContext context, WidgetRef ref, int index) {
    switch (index) {
      case 0:
        // الشاشة الرئيسية (نحن فيها بالفعل)
        break;
      case 1:
        // شاشة الإحصائيات
        Navigator.pushReplacementNamed(context, '/statistics');
        break;
      case 2:
        // شاشة الإعدادات
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  /// ✅ معالج تبديل حالة إتمام المهمة
  void _toggleTaskCompletion(BuildContext context, WidgetRef ref, Task task) {
    final taskService = TaskService(ref);
    taskService.toggleTaskCompletion(task.id);
    
    // إظهار رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(task.isDone ? 'تم إلغاء إنجاز المهمة' : 'تم إنجاز المهمة'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// ✏️ تعديل المهمة
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

  /// 🗑️ حذف المهمة
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
}
