import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/task_category.dart';

/// مساعد للتحسينات الخاصة بإمكانية الوصول (Accessibility)
/// 
/// يوفر دوال مساعدة لإنشاء semantic labels وصفية
/// يدعم screen readers و improves overall accessibility
/// يتبع معايير WCAG AA للـ accessibility
class AccessibilityHelper {
  
  /// إنشاء semantic label وصفية للمهمة
  /// 
  /// [task] المهمة المراد إنشاء الـ label لها
  /// Returns: نص وصفي للمهمة suitable لـ screen readers
  /// 
  /// مثال:
  /// ```dart
  /// final label = AccessibilityHelper.getTaskAccessibilityLabel(task);
  /// // "مهمة: اجتماع مع الفريق، أولوية عالية، غير مكتملة، التصنيف: عمل"
  /// ```
  static String getTaskAccessibilityLabel(Task task) {
    final buffer = StringBuffer();
    
    // العنوان
    buffer.write('مهمة: ${task.title}');
    
    // الحالة
    buffer.write(', ${task.isDone ? 'مكتملة' : 'غير مكتملة'}');
    
    // الأولوية
    buffer.write(', الأولوية: ${getPriorityLabel(task.priority)}');
    
    // التصنيف
    buffer.write(', التصنيف: ${getCategoryLabel(task.safeCategory)}');
    
    // التاريخ
    if (task.dueDate != null) {
      buffer.write(', الموعد: ${getDateLabel(task.dueDate)}');
    }
    
    // الملاحظات
    if (task.note != null && task.note!.isNotEmpty) {
      buffer.write(', ملاحظات: ${task.note}');
    }
    
    return buffer.toString();
  }

  /// الحصول على تسمية نصية للأولوية
  /// 
  /// [priority] رقم الأولوية (0-2)
  /// Returns: تسمية وصفية للأولوية
  static String getPriorityLabel(int priority) {
    switch (priority) {
      case 2:
        return 'عالية';
      case 1:
        return 'متوسطة';
      case 0:
      default:
        return 'منخفضة';
    }
  }

  /// الحصول على تسمية نصية للتصنيف
  /// 
  /// [category] تصنيف المهمة
  /// Returns: تسمية وصفية للتصنيف
  static String getCategoryLabel(TaskCategory category) {
    return category.displayName;
  }

  /// الحصول على تسمية نصية للتاريخ
  /// 
  /// [date] التاريخ المراد وصفه
  /// Returns: تسمية وصفية للتاريخ مع الوقت إذا وجد
  static String getDateLabel(DateTime? date) {
    if (date == null) return 'لا يوجد موعد';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    
    // التحقق من التاريخ النسبي
    if (taskDate.isAtSameMomentAs(today)) {
      final timeStr = DateFormat('h:mm a').format(date);
      return 'اليوم الساعة $timeStr';
    } else if (taskDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      final timeStr = DateFormat('h:mm a').format(date);
      return 'غداً الساعة $timeStr';
    } else if (taskDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      final timeStr = DateFormat('h:mm a').format(date);
      return 'أمس الساعة $timeStr';
    } else if (taskDate.isBefore(today)) {
      final daysOverdue = today.difference(taskDate).inDays;
      if (daysOverdue == 1) {
        return 'متأخر يوماً واحد';
      } else if (daysOverdue <= 7) {
        return 'متأخر $daysOverdue أيام';
      } else {
        return DateFormat('d MMMM yyyy').format(date);
      }
    } else if (taskDate.isAtSameMomentAs(today.add(const Duration(days: 7)))) {
      return 'بعد أسبوع';
    } else {
      return DateFormat('d MMMM yyyy').format(date);
    }
  }

  /// إنشاء semantic label لفلتر المهام
  /// 
  /// [filterType] نوع الفلتر
  /// [value] قيمة الفلتر
  /// Returns: تسمية وصفية للفلتر
  static String getFilterLabel(String filterType, dynamic value) {
    switch (filterType.toLowerCase()) {
      case 'status':
        return 'فلتر حسب الحالة: ${_getStatusLabel(value)}';
      case 'priority':
        return 'فلتر حسب الأولوية: ${getPriorityLabel(value as int)}';
      case 'category':
        return 'فلتر حسب التصنيف: ${getCategoryLabel(value as TaskCategory)}';
      case 'date':
        return 'فلتر حسب التاريخ: ${_getDateFilterLabel(value)}';
      default:
        return 'فلتر: $value';
    }
  }

  /// الحصول على تسمية نصية لحالة المهمة
  /// 
  /// [status] حالة المهمة
  /// Returns: تسمية وصفية للحالة
  static String _getStatusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'المعلقة';
      case 'completed':
        return 'المكتملة';
      case 'all':
        return 'الكل';
      default:
        return 'غير محدد';
    }
  }

  /// الحصول على تسمية نصية لفلتر التاريخ
  /// 
  /// [dateFilter] فلتر التاريخ
  /// Returns: تسمية وصفية لفلتر التاريخ
  static String _getDateFilterLabel(String? dateFilter) {
    switch (dateFilter) {
      case 'today':
        return 'اليوم';
      case 'thisWeek':
        return 'هذا الأسبوع';
      case 'overdue':
        return 'المتأخرة';
      case 'all':
        return 'الكل';
      default:
        return 'غير محدد';
    }
  }

  /// إنشاء semantic label للإحصائيات
  /// 
  /// [completed] عدد المهام المكتملة
  /// [pending] عدد المهام المعلقة
  /// [total] العدد الإجمالي
  /// Returns: تسمية وصفية للإحصائيات
  static String getStatisticsLabel(int completed, int pending, int total) {
    return 'إحصائيات المهام: $completed مكتملة، $pending معلقة، من إجمالي $total مهمة';
  }

  /// إنشاء semantic label للإشعار
  /// 
  /// [task] المهمة المرتبطة بالإشعار
  /// [minutesBefore] الدقائق قبل الموعد
  /// Returns: تسمية وصفية للإشعار
  static String getNotificationLabel(Task task, int minutesBefore) {
    final timeStr = minutesBefore == 0 
        ? 'في وقت الموعد' 
        : '$minutesBefore دقيقة قبل الموعد';
    
    return 'إشعار للمهمة: ${task.title}، $timeStr';
  }

  /// إنشاء semantic label للأزرار
  /// 
  /// [action] الإجراء الذي يقوم به الزر
  /// [target] الهدف من الإجراء (اختياري)
  /// Returns: تسمية وصفية للزر
  static String getButtonLabel(String action, {String? target}) {
    final buffer = StringBuffer();
    buffer.write('زر: $action');
    
    if (target != null && target.isNotEmpty) {
      buffer.write(' لـ $target');
    }
    
    return buffer.toString();
  }

  /// إنشاء semantic label لـ FAB (Floating Action Button)
  /// 
  /// [action] الإجراء الذي يقوم به الـ FAB
  /// Returns: تسمية وصفية للـ FAB
  static String getFabLabel(String action) {
    return 'زر الإجراء العائم: $action';
  }

  /// إنشاء semantic label لحقل الإدخال
  /// 
  /// [label] وصف الحقل
  /// [isRequired] هل الحقل مطلوب
  /// [value] القيمة الحالية (اختياري)
  /// Returns: تسمية وصفية لحقل الإدخال
  static String getInputFieldLabel(String label, bool isRequired, {String? value}) {
    final buffer = StringBuffer();
    buffer.write('حقل إدخال: $label');
    
    if (isRequired) {
      buffer.write('، مطلوب');
    }
    
    if (value != null && value.isNotEmpty) {
      buffer.write('، القيمة الحالية: $value');
    } else {
      buffer.write('، فارغ');
    }
    
    return buffer.toString();
  }

  /// إنشاء semantic label للـ chip
  /// 
  /// [label] نص الـ chip
  /// [isSelected] هل الـ chip محدد
  /// [isSelectable] هل الـ chip قابل للاختيار
  /// Returns: تسمية وصفية للـ chip
  static String getChipLabel(String label, bool isSelected, bool isSelectable) {
    final buffer = StringBuffer();
    
    if (isSelectable) {
      buffer.write('خيار: $label');
      buffer.write('، ${isSelected ? 'محدد' : 'غير محدد'}');
    } else {
      buffer.write('بطاقة: $label');
    }
    
    return buffer.toString();
  }

  /// إنشاء semantic label للـ slider
  /// 
  /// [label] وصف الـ slider
  /// [value] القيمة الحالية
  /// [min] الحد الأدنى
  /// [max] الحد الأقصى
  /// Returns: تسمية وصفية للـ slider
  static String getSliderLabel(String label, double value, double min, double max) {
    return 'شريط تمرير: $label، القيمة الحالية: $value، من $min إلى $max';
  }

  /// إنشاء semantic label للـ switch
  /// 
  /// [label] وصف الـ switch
  /// [isOn] هل الـ switch مفعّل
  /// Returns: تسمية وصفية للـ switch
  static String getSwitchLabel(String label, bool isOn) {
    return 'مفتاح تبديل: $label، ${isOn ? 'مفعّل' : 'معطّل'}';
  }

  /// إنشاء semantic label للقائمة
  /// 
  /// [title] عنوان القائمة
  /// [itemCount] عدد العناصر
  /// [selectedIndex] فهرس العنصر المحدد (اختياري)
  /// Returns: تسمية وصفية للقائمة
  static String getListLabel(String title, int itemCount, {int? selectedIndex}) {
    final buffer = StringBuffer();
    buffer.write('قائمة: $title');
    buffer.write('، تحتوي على $itemCount عناصر');
    
    if (selectedIndex != null && selectedIndex >= 0 && selectedIndex < itemCount) {
      buffer.write('، العنصر المحدد: ${selectedIndex + 1} من $itemCount');
    }
    
    return buffer.toString();
  }

  /// إنشاء semantic label للـ card
  /// 
  /// [title] عنوان الـ card
  /// [subtitle] العنوان الفرعي (اختياري)
  /// [action] الإجراء المتاح (اختياري)
  /// Returns: تسمية وصفية للـ card
  static String getCardLabel(String title, {String? subtitle, String? action}) {
    final buffer = StringBuffer();
    buffer.write('بطاقة: $title');
    
    if (subtitle != null && subtitle.isNotEmpty) {
      buffer.write('، $subtitle');
    }
    
    if (action != null && action.isNotEmpty) {
      buffer.write('، الإجراء: $action');
    }
    
    return buffer.toString();
  }

  /// إنشاء semantic label للـ dialog
  /// 
  /// [title] عنوان الـ dialog
  /// [message] الرسالة الرئيسية
  /// [hasActions] هل يوجد أزرار إجراءات
  /// Returns: تسمية وصفية للـ dialog
  static String getDialogLabel(String title, String message, bool hasActions) {
    final buffer = StringBuffer();
    buffer.write('نافذة حوار: $title');
    buffer.write('، $message');
    
    if (hasActions) {
      buffer.write('، متاح أزرار الإجراءات');
    }
    
    return buffer.toString();
  }

  /// التحقق من contrast ratio مناسب
  /// 
  /// [foregroundColor] لون النص
  /// [backgroundColor] لون الخلفية
  /// Returns: true إذا كان contrast ratio مناسب (WCAG AA: 4.5:1)
  static bool hasGoodContrast(Color foregroundColor, Color backgroundColor) {
    // حساب relative luminance
    final fgLuminance = _calculateLuminance(foregroundColor);
    final bgLuminance = _calculateLuminance(backgroundColor);
    
    // حساب contrast ratio
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    
    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    
    // WCAG AA يتطلب contrast ratio 4.5:1
    return contrastRatio >= 4.5;
  }

  /// حساب relative luminance للون
  /// 
  /// [color] اللون المراد حسابه
  /// Returns: relative luminance value (0.0 - 1.0)
  static double _calculateLuminance(Color color) {
    final r = _adjustColorComponent(color.r);
    final g = _adjustColorComponent(color.g);
    final b = _adjustColorComponent(color.b);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// تعديل مكون اللون لحساب luminance
  /// 
  /// [component] مكون اللون (0-255)
  /// Returns: المكون المعدل
  static double _adjustColorComponent(double component) {
    return ((component * 299).round().clamp(0, 255) + 500) / 1000;
  }
}
