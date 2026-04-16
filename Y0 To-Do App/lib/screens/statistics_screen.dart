import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/y0_design_system.dart';
import '../widgets/neo_morphic_card.dart';
import '../widgets/bottom_navigation.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

/// 📊 Y0 To-Do App - Statistics Screen
/// 
/// شاشة الإحصائيات المبسطة بالتصميم Neo-morphic
/// 
/// @author Y0 Development Team
/// @version 3.1.0
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasks = ref.watch(tasksProvider);
    final completedTasks = tasks.where((task) => task.isDone).length;
    final totalTasks = tasks.length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : context.colorScheme.surface,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Y0DesignSystem.spacing3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Top App Bar
              _buildTopAppBar(context, isDark),
              
              const SizedBox(height: Y0DesignSystem.spacing4),
              
              // Editorial Hero Header
              _buildEditorialHeroHeader(context, completionRate, isDark),
              
              const SizedBox(height: Y0DesignSystem.spacing4),
              
              // Quick Stats Cards
              _buildQuickStatsCards(context, tasks, isDark),
              
              const SizedBox(height: Y0DesignSystem.spacing4),
              
              // Weekly Chart Card
              _buildWeeklyChartCard(context, tasks, isDark),
              
              const SizedBox(height: Y0DesignSystem.spacing4),
              
              // Achievement Badges Section
              _buildAchievementBadges(context, completedTasks, isDark),
              
              const SizedBox(height: Y0DesignSystem.spacing4),
              
              // Bottom padding for navigation
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1,
        onTap: (index) => _handleNavigationTap(context, index),
      ),
    );
  }

  /// 📱 Top App Bar
  Widget _buildTopAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Y0DesignSystem.spacing3,
        vertical: Y0DesignSystem.spacing2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Title
          Text(
            'Y0 To-Do',
            style: context.textTheme.headlineSmall?.copyWith(
              color: isDark 
                  ? const Color(0xFF66bb6a)
                  : context.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 Editorial Hero Header
  Widget _buildEditorialHeroHeader(BuildContext context, int completionRate, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Version Badge
        Text(
          'V3.2.3 • نظرة عامة',
          style: context.textTheme.labelMedium?.copyWith(
            color: isDark 
                ? const Color(0xFF66bb6a)
                : context.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: Y0DesignSystem.spacing2),
        
        // Main Title
        Text(
          'إحصائيات الإنجاز',
          style: context.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark 
                ? Colors.white
                : context.colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: Y0DesignSystem.spacing3),
        
        // Description
        Text(
          'أداء رائع هذا الأسبوع! لقد أكملت $completionRate% من مهامك المخطط لها.',
          style: context.textTheme.bodyLarge?.copyWith(
            color: isDark 
                ? const Color(0xFFB3B3B3)
                : context.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }

  /// 📊 Quick Stats Cards
  Widget _buildQuickStatsCards(BuildContext context, List<Task> tasks, bool isDark) {
    final completedTasks = tasks.where((task) => task.isDone).length;
    final totalTasks = tasks.length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;
    
    return Column(
      children: [
        // Completion Rate Card
        _buildQuickStatCard(
          context,
          'المهام المكتملة',
          '$totalTasks مهمة',
          '$completionRate%',
          Icons.circle_outlined,
          true,
          isDark,
        ),
        
        const SizedBox(height: Y0DesignSystem.spacing3),
        
        // Goals Card
        _buildQuickStatCard(
          context,
          'الأهداف الحالية',
          '${tasks.where((t) => !t.isDone).length} هدف',
          null,
          Icons.flag,
          false,
          isDark,
        ),
        
        const SizedBox(height: Y0DesignSystem.spacing3),
        
        // Focus Time Card
        _buildQuickStatCard(
          context,
          'وقت التركيز',
          '${(completedTasks * 0.5).toStringAsFixed(1)} ساعة',
          null,
          Icons.schedule,
          false,
          isDark,
        ),
      ],
    );
  }

  /// 📈 Weekly Chart Card
  Widget _buildWeeklyChartCard(BuildContext context, List<Task> tasks, bool isDark) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final weeklyData = List.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      final dayTasks = tasks.where((task) =>
        task.dueDate != null &&
        DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day)
            .isAtSameMomentAs(DateTime(day.year, day.month, day.day)) &&
        task.isDone
      ).length;
      return (dayTasks * 10).clamp(0, 100).toDouble(); // 10 points per task
    });
    final weekDays = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
    
    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeoMorphicCard(
                padding: const EdgeInsets.all(Y0DesignSystem.spacing2),
                borderRadius: BorderRadius.circular(Y0DesignSystem.radiusSmall),
                color: isDark 
                    ? const Color(0xFF126d27).withValues(alpha: 0.1)
                    : context.colorScheme.primaryContainer.withValues(alpha: 0.2),
                child: Icon(
                  Icons.insights,
                  color: isDark 
                      ? const Color(0xFF66bb6a)
                      : context.colorScheme.primary,
                  size: 24,
                ),
              ),
              
              Text(
                'الإنتاجية الأسبوعية',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark 
                      ? Colors.white
                      : context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: Y0DesignSystem.spacing3),
          
          // Chart
          SizedBox(
            height: 192,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bar
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? const Color(0xFF2D2D2D)
                                  : context.colorScheme.surfaceContainerLow,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.bottomCenter,
                              heightFactor: weeklyData[index] / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: isDark ? [
                                      const Color(0xFF66bb6a),
                                      const Color(0xFF126d27),
                                    ] : [
                                      context.colorScheme.primary.withValues(alpha: 0.8),
                                      context.colorScheme.primaryContainer,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Day Label
                        Text(
                          weekDays[index],
                          style: context.textTheme.labelSmall?.copyWith(
                            color: isDark 
                                ? const Color(0xFFB3B3B3)
                                : context.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 Quick Stat Card
  Widget _buildQuickStatCard(
    BuildContext context,
    String label,
    String value,
    String? percentage,
    IconData icon,
    bool showProgress,
    bool isDark,
  ) {
    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing3),
      color: isDark 
          ? const Color(0xFF1E1E1E)
          : null,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Icon or Progress Circle
          if (showProgress && percentage != null)
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                children: [
                  // Background Circle
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark 
                            ? const Color(0xFF66bb6a)
                            : context.colorScheme.primary,
                        width: 4,
                      ),
                    ),
                  ),
                  
                  // Progress Circle
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: _parsePercentage(percentage) / 100,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark 
                            ? const Color(0xFF66bb6a)
                            : context.colorScheme.primary,
                      ),
                    ),
                  ),
                  
                  // Percentage Text
                  Center(
                    child: Text(
                      percentage,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: isDark 
                            ? const Color(0xFF66bb6a)
                            : context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            NeoMorphicCard(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(Y0DesignSystem.radiusSmall),
              color: isDark 
                  ? const Color(0xFF2D2D2D)
                  : context.colorScheme.surface,
              child: Icon(
                icon,
                color: isDark 
                    ? const Color(0xFF66bb6a)
                    : context.colorScheme.primary,
                size: 24,
              ),
            ),
          
          const SizedBox(width: Y0DesignSystem.spacing3),
          
          // Stats Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isDark 
                        ? const Color(0xFFB3B3B3)
                        : context.colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(height: Y0DesignSystem.spacing2 / 2),
                
                Text(
                  value,
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark 
                        ? Colors.white
                        : context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// تحويل النسبة المئوية من نص إلى رقم
  double _parsePercentage(String percentage) {
    try {
      // إزالة علامة % وتحويل إلى رقم
      final cleanValue = percentage.replaceAll('%', '').trim();
      return double.parse(cleanValue);
    } catch (e) {
      // في حالة الخطأ، إرجاع 0
      return 0.0;
    }
  }

  /// 🏆 Achievement Badges Section
  Widget _buildAchievementBadges(BuildContext context, int completedTasks, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                // Achievements navigation - optional feature
              },
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: isDark 
                          ? const Color(0xFF66bb6a)
                          : context.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_left,
                    color: isDark 
                        ? const Color(0xFF66bb6a)
                        : context.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
            
            Text(
              'أوسمة الإنجاز',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark 
                    ? Colors.white
                    : context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: Y0DesignSystem.spacing3),
        
        // Badges Grid
        Wrap(
          spacing: Y0DesignSystem.spacing3,
          runSpacing: Y0DesignSystem.spacing3,
          alignment: WrapAlignment.end,
          children: [
            _buildAchievementBadge(
              context,
              'البداية القوية',
              Icons.star,
              isDark ? Colors.yellow : Colors.amber,
              completedTasks >= 1,
              isDark,
            ),
            _buildAchievementBadge(
              context,
              'قناص المهام',
              Icons.workspace_premium,
              isDark ? Colors.blue.shade400 : Colors.blue,
              completedTasks >= 10,
              isDark,
            ),
            _buildAchievementBadge(
              context,
              'بطل الإنجاز',
              Icons.emoji_events,
              isDark ? Colors.green.shade400 : Colors.green,
              completedTasks >= 50,
              isDark,
            ),
            _buildAchievementBadge(
              context,
              'الأسطورة',
              Icons.workspace_premium,
              isDark ? Colors.purple.shade400 : Colors.purple,
              completedTasks >= 100,
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  /// 🏆 Achievement Badge
  Widget _buildAchievementBadge(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool isUnlocked,
    bool isDark,
  ) {
    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing3),
      width: 112,
      color: isDark 
          ? const Color(0xFF1E1E1E)
          : null,
      child: Column(
        children: [
          // Badge Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked 
                  ? color.withValues(alpha: 0.2)
                  : (isDark 
                      ? const Color(0xFF313030)
                      : Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? color : (isDark ? const Color(0xFFB3B3B3) : Colors.grey),
              size: 32,
              fill: isUnlocked ? 1 : 0,
            ),
          ),
          
          const SizedBox(height: Y0DesignSystem.spacing2),
          
          // Badge Title
          Text(
            title,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isUnlocked 
                  ? (isDark 
                      ? Colors.white
                      : context.colorScheme.onSurface)
                  : (isDark 
                      ? const Color(0xFFB3B3B3).withValues(alpha: 0.4)
                      : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 🧭 Navigation Handler
  void _handleNavigationTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Home Screen
        Navigator.of(context).pushReplacementNamed('/');
        break;
      case 1:
        // Statistics Screen (we're already here)
        break;
      case 2:
        // Settings Screen
        Navigator.of(context).pushNamed('/settings');
        break;
    }
  }
}
