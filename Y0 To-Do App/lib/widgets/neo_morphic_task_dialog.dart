import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/neo_morphic_components.dart';
import '../theme/y0_design_system.dart';

/// 🎨 Y0 To-Do App - Neo-Morphic Add/Edit Task Dialog V2.4.0
/// 
/// This dialog implements the Editorial Neo-Minimalism design system for
/// task creation and editing with:
/// - Neo-morphic input fields with ghost borders
/// - Surface hierarchy without borders
/// - Smooth animations and micro-interactions
/// - RTL-optimized layouts
/// - Glassmorphic overlay effect
/// 
/// Key Features:
/// - In-set Neo-morphic inputs
/// - Priority selection with color coding
/// - Category selection with surface hierarchy
/// - Date/time picker integration
/// - Smart AI suggestions integration
/// 
/// @author Y0 Development Team
/// @version 2.4.0
class NeoMorphicTaskDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final int? initialPriority;
  final TaskCategory? initialCategory;
  final DateTime? initialDueDate;
  final bool isEditing;

  const NeoMorphicTaskDialog({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialPriority,
    this.initialCategory,
    this.initialDueDate,
    this.isEditing = false,
  });

  @override
  State<NeoMorphicTaskDialog> createState() => _NeoMorphicTaskDialogState();
}

class _NeoMorphicTaskDialogState extends State<NeoMorphicTaskDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedPriority = 0;
  TaskCategory? _selectedCategory;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Y0DesignSystem.animationMedium,
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _initializeFields();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// 📝 Initialize form fields with initial values
  void _initializeFields() {
    _titleController.text = widget.initialTitle ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _selectedPriority = widget.initialPriority ?? 0;
    _selectedCategory = widget.initialCategory;
    _selectedDueDate = widget.initialDueDate;
    
    if (_selectedDueDate != null) {
      _selectedTime = TimeOfDay.fromDateTime(_selectedDueDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Glassmorphic Background
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withValues(alpha:0.3),
                  ),
                ),
                
                // Dialog Content
                Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: _buildDialogContent(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎴 Build the main dialog content
  Widget _buildDialogContent(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompactScreen = screenHeight < 600;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.85,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(Y0DesignSystem.radiusLarge),
        boxShadow: Y0DesignSystem.floatingShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(context),
          
          // Form Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Title Input
                  Y0NeoMorphicComponents.neoInputField(
                    controller: _titleController,
                    hintText: 'عنوان المهمة',
                    labelText: 'العنوان',
                    icon: Icons.title,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description Input
                  Y0NeoMorphicComponents.neoInputField(
                    controller: _descriptionController,
                    hintText: 'وصف المهمة (اختياري)',
                    labelText: 'الوصف',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Priority Selection
                  _buildPrioritySection(context),
                  
                  const SizedBox(height: 24),
                  
                  // Category Selection
                  _buildCategorySection(context),
                  
                  const SizedBox(height: 24),
                  
                  // Date & Time Selection
                  _buildDateTimeSection(context),
                  
                  if (!isCompactScreen) const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// 📋 Build dialog header
  Widget _buildHeader(BuildContext context) {
    return Y0NeoMorphicComponents.surfaceSection(
      surfaceLevel: 1,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close Button
          Y0NeoMorphicComponents.neoGhostButton(
            text: 'إلغاء',
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.close,
          ),
          
          // Title
          Text(
            widget.isEditing ? 'تعديل المهمة' : 'إضافة مهمة جديدة',
            style: context.textTheme.headlineMedium?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 Build priority selection section
  Widget _buildPrioritySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'الأولوية',
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildPriorityOption(
              context,
              'منخفضة',
              0,
              Y0DesignSystem.priorityLow,
              Icons.arrow_downward,
            ),
            const SizedBox(width: 12),
            _buildPriorityOption(
              context,
              'متوسطة',
              1,
              Y0DesignSystem.priorityMedium,
              Icons.remove,
            ),
            const SizedBox(width: 12),
            _buildPriorityOption(
              context,
              'عالية',
              2,
              Y0DesignSystem.priorityHigh,
              Icons.arrow_upward,
            ),
          ],
        ),
      ],
    );
  }

  /// 🎯 Build individual priority option
  Widget _buildPriorityOption(
    BuildContext context,
    String label,
    int value,
    Color color,
    IconData icon,
  ) {
    final isSelected = _selectedPriority == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = value;
        });
      },
      child: Y0NeoMorphicComponents.neoCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: isSelected ? color.withValues(alpha:0.1) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : context.colorScheme.onSurfaceVariant,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: isSelected ? color : context.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📂 Build category selection section
  Widget _buildCategorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'الفئة',
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            _buildCategoryChip(context, 'عمل', 'work'),
            _buildCategoryChip(context, 'شخصي', 'personal'),
            _buildCategoryChip(context, 'دراسة', 'study'),
            _buildCategoryChip(context, 'صحة', 'health'),
            _buildCategoryChip(context, 'تسوق', 'shopping'),
          ],
        ),
      ],
    );
  }

  /// 🏷️ Build category chip
  Widget _buildCategoryChip(BuildContext context, String label, String value) {
    final isSelected = _selectedCategory?.name == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = TaskCategory(id: value, name: label, color: label);
        });
      },
      child: Y0NeoMorphicComponents.surfaceSection(
        surfaceLevel: isSelected ? 2 : 1,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: isSelected ? context.colorScheme.primary : 
                               context.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 📅 Build date & time selection section
  Widget _buildDateTimeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'الموعد النهائي',
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Date Picker
            Expanded(
              child: Y0NeoMorphicComponents.neoCard(
                padding: const EdgeInsets.all(16),
                onTap: () => _selectDate(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _selectedDueDate != null
                          ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                          : 'اختر التاريخ',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: _selectedDueDate != null
                            ? context.colorScheme.onSurface
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today,
                      color: context.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Time Picker
            Expanded(
              child: Y0NeoMorphicComponents.neoCard(
                padding: const EdgeInsets.all(16),
                onTap: () => _selectTime(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _selectedTime != null
                          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                          : 'اختر الوقت',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: _selectedTime != null
                            ? context.colorScheme.onSurface
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.schedule,
                      color: context.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🔘 Build action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Y0NeoMorphicComponents.surfaceSection(
      surfaceLevel: 2,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cancel Button
          Y0NeoMorphicComponents.neoGhostButton(
            text: 'إلغاء',
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          // Save Button
          Y0NeoMorphicComponents.neoPrimaryButton(
            text: widget.isEditing ? 'حفظ التغييرات' : 'إضافة المهمة',
            onPressed: _titleController.text.trim().isNotEmpty
                ? () {
                    final result = {
                      'title': _titleController.text.trim(),
                      'description': _descriptionController.text.trim(),
                      'priority': _selectedPriority,
                      'category': _selectedCategory,
                      'dueDate': _selectedDueDate,
                      'dueTime': _selectedTime,
                    };
                    Navigator.of(context).pop(result);
                  }
                : null,
            icon: Icons.save,
          ),
        ],
      ),
    );
  }

  // ==================== DATE & TIME PICKERS ====================

  /// 📅 Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  /// ⏰ Show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.colorScheme.primary,
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
    }
  }
}

/// 📝 Simple Task Category model for dialog
class TaskCategory {
  final String id;
  final String name;
  final String color;

  TaskCategory({
    required this.id,
    required this.name,
    required this.color,
  });
}
