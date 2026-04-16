import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/y0_design_system.dart';
import '../widgets/neo_morphic_card.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../providers/task_provider.dart';

/// 📝 Y0 To-Do App - Add Task Screen
/// 
/// شاشة إضافة مهمة جديدة بالتصميم Neo-morphic المحول من HTML
/// تحتوي على كل المكونات الرئيسية مع الحفاظ على جودة الكود 100%
/// 
/// المكونات الرئيسية:
/// - Top Navigation Bar مع زر الإغلاق
/// - Editorial Header مع عنوان جذاب
/// - Task Form Layout بتصميم Bento-inspired Grid
/// - Smart Suggestions Chips
/// - Description Card مع Neo-morphic design
/// - Category Selector مع ألوان مختلفة
/// - Date & Time Picker
/// - Priority Selector مع Gradients
/// - Progress Orb Decoration
/// - Fixed Bottom Action Area
/// 
/// @author Y0 Development Team
/// @version 3.1.0
class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TaskCategory _selectedCategory = TaskCategory.work;
  int _priority = 2; // medium by default

  final List<String> _suggestions = [
    'اجتماع عمل',
    'تمارين رياضية',
    'قراءة كتاب',
    'شراء مستلزمات',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // Main Content
            CustomScrollView(
              slivers: [
                // Top Navigation Bar
                _buildTopAppBar(context),
                
                // Main Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Y0DesignSystem.spacing3,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Editorial Header
                      _buildEditorialHeader(context),
                      
                      const SizedBox(height: Y0DesignSystem.spacing4),
                      
                      // Main Task Form Layout
                      _buildTaskFormLayout(context),
                      
                      const SizedBox(height: Y0DesignSystem.spacing4),
                      
                      // Progress Orb Decoration
                      _buildProgressOrbDecoration(context),
                      
                      // Bottom padding for fixed action button
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
            
            // Fixed Bottom Action Area
            _buildFixedBottomAction(context),
            
            // Background Decorations
            _buildBackgroundDecorations(),
          ],
        ),
      ),
    );
  }

  /// 📱 Top Navigation Bar
  Widget _buildTopAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: context.colorScheme.surface,
      flexibleSpace: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Y0DesignSystem.spacing3,
            vertical: Y0DesignSystem.spacing2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Close Button
              NeoMorphicCard(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.close,
                  color: context.colorScheme.onSurface,
                  size: 20,
                ),
              ),
              
              // Title
              Text(
                'إضافة مهمة جديدة',
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // User Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colorScheme.primaryContainer,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    color: context.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      color: context.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📝 Editorial Header
  Widget _buildEditorialHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'خطط ليومك بكل هدوء',
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: Y0DesignSystem.spacing2),
        
        RichText(
          textAlign: TextAlign.end,
          text: TextSpan(
            style: context.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.colorScheme.onSurface,
            ),
            children: [
              const TextSpan(text: 'ما هي خطوتك '),
              TextSpan(
                text: 'التالية؟',
                style: TextStyle(
                  color: context.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📋 Main Task Form Layout (Bento-inspired Grid)
  Widget _buildTaskFormLayout(BuildContext context) {
    return Column(
      children: [
        // Title & Suggestions (Wide Span)
        _buildTitleAndSuggestions(context),
        
        const SizedBox(height: Y0DesignSystem.spacing3),
        
        // Grid Layout
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 768) {
              // Desktop Layout
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Card (4 columns)
                  Expanded(
                    flex: 4,
                    child: _buildDescriptionCard(context),
                  ),
                  
                  const SizedBox(width: Y0DesignSystem.spacing3),
                  
                  // Category Selector (2 columns)
                  Expanded(
                    flex: 2,
                    child: _buildCategorySelector(context),
                  ),
                ],
              );
            } else {
              // Mobile Layout
              return Column(
                children: [
                  _buildDescriptionCard(context),
                  const SizedBox(height: Y0DesignSystem.spacing3),
                  _buildCategorySelector(context),
                ],
              );
            }
          },
        ),
        
        const SizedBox(height: Y0DesignSystem.spacing3),
        
        // Date & Time and Priority Row
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 768) {
              // Desktop Layout
              return Row(
                children: [
                  // Date & Time Picker (3 columns)
                  Expanded(
                    flex: 3,
                    child: _buildDateTimePicker(context),
                  ),
                  
                  const SizedBox(width: Y0DesignSystem.spacing3),
                  
                  // Priority Selector (3 columns)
                  Expanded(
                    flex: 3,
                    child: _buildPrioritySelector(context),
                  ),
                ],
              );
            } else {
              // Mobile Layout
              return Column(
                children: [
                  _buildDateTimePicker(context),
                  const SizedBox(height: Y0DesignSystem.spacing3),
                  _buildPrioritySelector(context),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  /// 📝 Title & Suggestions
  Widget _buildTitleAndSuggestions(BuildContext context) {
    return Column(
      children: [
        // Title Input
        NeoMorphicCard(
          isInset: true,
          padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  textDirection: TextDirection.rtl,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اسم المهمة...',
                    hintStyle: context.textTheme.headlineSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              
              const SizedBox(width: Y0DesignSystem.spacing2),
              
              // Mic Button
              NeoMorphicCard(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // TODO: Implement voice input
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الإدخال الصوتي قيد التطوير')),
                  );
                },
                child: Icon(
                  Icons.mic,
                  color: context.colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: Y0DesignSystem.spacing2),
        
        // Smart Suggestions Chips
        Wrap(
          spacing: Y0DesignSystem.spacing2,
          runSpacing: Y0DesignSystem.spacing2,
          alignment: WrapAlignment.end,
          children: _suggestions.map((suggestion) {
            return NeoMorphicCard(
              padding: const EdgeInsets.symmetric(
                horizontal: Y0DesignSystem.spacing3,
                vertical: Y0DesignSystem.spacing2 / 2,
              ),
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                _titleController.text = suggestion;
              },
              child: Text(
                suggestion,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 📄 Description Card
  Widget _buildDescriptionCard(BuildContext context) {
    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Label
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                Icons.notes,
                color: context.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: Y0DesignSystem.spacing2 / 2),
              Text(
                'تفاصيل إضافية',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: Y0DesignSystem.spacing3),
          
          // Description Text Area
          TextField(
            controller: _descriptionController,
            textDirection: TextDirection.rtl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'اكتب وصفاً مختصراً هنا...',
              hintStyle: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  /// 🏷️ Category Selector
  Widget _buildCategorySelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      color: isDark 
          ? context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
          : context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Label
          Text(
            'التصنيف',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: Y0DesignSystem.spacing3),
          
          // Category Options
          ...TaskCategory.values.map((category) {
            final isSelected = category == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NeoMorphicCard(
                padding: const EdgeInsets.all(Y0DesignSystem.spacing2),
                color: isSelected 
                    ? (isDark 
                        ? context.colorScheme.surfaceContainerLowest 
                        : context.colorScheme.surfaceContainerLowest)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(Y0DesignSystem.radiusSmall),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    // Category Dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? _getCategoryColorDark(category) : _getCategoryColor(category),
                      ),
                    ),
                    
                    const SizedBox(width: Y0DesignSystem.spacing2),
                    
                    // Category Name
                    Text(
                      _getCategoryName(category),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected 
                            ? context.colorScheme.onSurface 
                            : (isDark 
                                ? context.colorScheme.onSurfaceVariant
                                : context.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 📅 Date & Time Picker
  Widget _buildDateTimePicker(BuildContext context) {
    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Label
          Text(
            'التوقيت',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: Y0DesignSystem.spacing3),
          
          // Date and Time Row
          Row(
            children: [
              // Date Picker
              Expanded(
                child: NeoMorphicCard(
                  isInset: true,
                  padding: const EdgeInsets.all(Y0DesignSystem.spacing3),
                  onTap: _selectDate,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: context.colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: Y0DesignSystem.spacing2),
              
              // Time Picker
              Expanded(
                child: NeoMorphicCard(
                  isInset: true,
                  padding: const EdgeInsets.all(Y0DesignSystem.spacing3),
                  onTap: _selectTime,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime.format(context),
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.schedule,
                        color: context.colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🚨 Priority Selector
  Widget _buildPrioritySelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return NeoMorphicCard(
      padding: const EdgeInsets.all(Y0DesignSystem.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Label
          Text(
            'الأولوية',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: Y0DesignSystem.spacing3),
          
          // Priority Buttons
          Row(
            children: [
              // High Priority
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priority = 3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: Y0DesignSystem.spacing3),
                    decoration: BoxDecoration(
                      gradient: _priority == 3 
                          ? LinearGradient(
                              colors: isDark ? [
                                const Color(0xFFB71C1C), // أحمر داكن للوضع الليلي
                                const Color(0xFFD32F2F), // أحمر متوسط للوضع الليلي
                              ] : [
                                Y0DesignSystem.priorityHigh,
                                Y0DesignSystem.priorityHigh.withValues(alpha: 0.8),
                              ],
                            )
                          : null,
                      color: _priority == 3 ? null : context.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(Y0DesignSystem.radiusSmall),
                      boxShadow: _priority == 3 ? [
                        BoxShadow(
                          color: isDark 
                              ? const Color(0xFFB71C1C).withValues(alpha: 0.3)
                              : Y0DesignSystem.priorityHigh.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ] : null,
                    ),
                    child: Text(
                      'عالية',
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: _priority == 3 
                            ? (isDark ? Colors.white : Y0DesignSystem.onPrimary)
                            : context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: Y0DesignSystem.spacing2),
              
              // Medium Priority
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priority = 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: Y0DesignSystem.spacing3),
                    decoration: BoxDecoration(
                      color: _priority == 2 
                          ? (isDark 
                              ? context.colorScheme.primary.withValues(alpha: 0.2)
                              : context.colorScheme.secondaryContainer)
                          : context.colorScheme.surfaceContainerHighest,
                      border: _priority == 2 && isDark 
                          ? Border.all(
                              color: context.colorScheme.primary.withValues(alpha: 0.2),
                              width: 1,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(Y0DesignSystem.radiusSmall),
                    ),
                    child: Text(
                      'متوسطة',
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: _priority == 2 
                            ? (isDark 
                                ? context.colorScheme.primary
                                : context.colorScheme.onSecondaryContainer)
                            : context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: Y0DesignSystem.spacing2),
              
              // Low Priority
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priority = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: Y0DesignSystem.spacing3),
                    decoration: BoxDecoration(
                      color: _priority == 1 
                          ? const Color(0xFFC8E6C9) // أخضر خفيف
                          : context.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(Y0DesignSystem.radiusSmall),
                    ),
                    child: Text(
                      'منخفضة',
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: _priority == 1 
                            ? const Color(0xFF2E7D32) // أخضر داكن للنص
                            : context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🎯 Progress Orb Decoration
  Widget _buildProgressOrbDecoration(BuildContext context) {
    const progress = 0.25; // Mock progress
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Progress Orb
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            children: [
              // Background Circle
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.surfaceContainerHigh,
                ),
              ),
              
              // Progress Circle
              SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: context.colorScheme.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colorScheme.primary,
                  ),
                ),
              ),
              
              // Progress Text
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'مكتمل',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: Y0DesignSystem.spacing3),
        
        // Progress Message
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'أنت تتقدم بشكل رائع!',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'باقي 3 مهام لهذا اليوم.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🔽 Fixed Bottom Action Area
  Widget _buildFixedBottomAction(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Y0DesignSystem.spacing3,
          vertical: Y0DesignSystem.spacing2,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isDark 
                  ? LinearGradient(
                      colors: [
                        context.colorScheme.primary,
                        const Color(0xFF83DA85), // لون فاتح للوضع الليلي
                      ],
                    )
                  : Y0DesignSystem.primaryGradient,
              borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? context.colorScheme.primary.withValues(alpha: 0.1)
                      : context.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: isDark ? 8 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(Y0DesignSystem.radiusMedium),
                onTap: _saveTask,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Y0DesignSystem.spacing3),
                  child: Text(
                    'حفظ المهمة',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: isDark 
                          ? const Color(0xFF121212) // أسود للوضع الليلي
                          : Y0DesignSystem.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 Background Decorations
  Widget _buildBackgroundDecorations() {
    return const Stack(
      children: [],
    );
  }

  // ==================== HELPER METHODS ====================
  
  /// 🎨 الحصول على لون الفئة
  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.personal:
        return Colors.amber;
      case TaskCategory.health:
        return Colors.purple;
      case TaskCategory.study:
        return Colors.green;
      case TaskCategory.shopping:
        return Colors.orange;
      case TaskCategory.general:
        return Colors.grey;
      case TaskCategory.entertainment:
        return Colors.pink;
    }
  }

  /// 🎨 الحصول على لون الفئة للوضع الليلي
  Color _getCategoryColorDark(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return const Color(0xFF2196F3); // أزرق أفتح للوضع الليلي
      case TaskCategory.personal:
        return const Color(0xFFFFB74D); // أصفر أفتح للوضع الليلي
      case TaskCategory.health:
        return const Color(0xFFBA68C8); // بنفسجي أفتح للوضع الليلي
      case TaskCategory.study:
        return const Color(0xFF4CAF50); // أخضر أفتح للوضع الليلي
      case TaskCategory.shopping:
        return const Color(0xFFFF9800); // برتقالي أفتح للوضع الليلي
      case TaskCategory.general:
        return const Color(0xFF9E9E9E); // رمادي أفتح للوضع الليلي
      case TaskCategory.entertainment:
        return const Color(0xFFF06292); // وردي أفتح للوضع الليلي
    }
  }

  /// 📝 الحصول على اسم الفئة
  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'العمل';
      case TaskCategory.personal:
        return 'شخصي';
      case TaskCategory.health:
        return 'صحة';
      case TaskCategory.study:
        return 'دراسة';
      case TaskCategory.shopping:
        return 'تسوق';
      case TaskCategory.general:
        return 'عامة';
      case TaskCategory.entertainment:
        return 'ترفيه';
    }
  }

  /// 📅 الحصول على اسم الشهر
  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }

  /// 📅 اختيار التاريخ
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)), // السماح بالتواريخ السابقة
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.colorScheme.primary,
              onPrimary: context.colorScheme.onPrimary,
              surface: context.colorScheme.surface,
              onSurface: context.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم اختيار التاريخ: ${_getMonthName(picked.month)} ${picked.day}')),
      );
    }
  }

  /// ⏰ اختيار الوقت
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.colorScheme.primary,
              onPrimary: context.colorScheme.onPrimary,
              surface: context.colorScheme.surface,
              onSurface: context.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم اختيار الوقت: ${picked.format(context)}')),
      );
    }
  }

  /// 💾 حفظ المهمة
  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال عنوان المهمة')),
      );
      return;
    }

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      note: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
      priority: _priority,
      isDone: false,
      category: _selectedCategory,
      dueDate: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
    );

    ref.read(tasksProvider.notifier).add(newTask);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إضافة المهمة بنجاح')),
    );
    
    Navigator.of(context).pop();
  }
}
