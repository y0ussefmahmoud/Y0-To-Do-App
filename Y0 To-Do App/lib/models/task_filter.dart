// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'task_category.dart';

enum TaskStatus {
  all,
  pending,
  completed,
  archived,
}

enum DateFilter {
  all,
  today,
  thisWeek,
  overdue,
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.all:
        return 'الكل';
      case TaskStatus.pending:
        return 'معلقة';
      case TaskStatus.completed:
        return 'مكتملة';
      case TaskStatus.archived:
        return 'الأرشيف';
    }
  }
}

extension DateFilterExtension on DateFilter {
  String get displayName {
    switch (this) {
      case DateFilter.all:
        return 'الكل';
      case DateFilter.today:
        return 'اليوم';
      case DateFilter.thisWeek:
        return 'هذا الأسبوع';
      case DateFilter.overdue:
        return 'متأخرة';
    }
  }
}

/// فلتر المهام مع دعم تعدد الاختيارات
///
/// القواعد:
/// - [status]: اختيار فردي فقط (معلقة أو مكتملة — لا يجتمعان)
/// - [priorities]: Set — يمكن اختيار أكثر من أولوية في آن واحد
/// - [categories]: Set — يمكن اختيار أكثر من فئة في آن واحد
/// - [dateFilters]: Set — يمكن اختيار أكثر من فلتر تاريخ (اليوم + هذا الأسبوع مثلاً)
/// - [tags]: Set — يمكن اختيار أكثر من وسم (OR logic)
class TaskFilter {
  final TaskStatus? status;
  final Set<int> priorities;
  final Set<TaskCategory> categories;
  final Set<DateFilter> dateFilters;

  /// الوسوم المختارة للفلترة (OR — أي مهمة تحمل أحد هذه الوسوم)
  final Set<String> tags;

  const TaskFilter({
    this.status,
    this.priorities = const {},
    this.categories = const {},
    this.dateFilters = const {},
    this.tags = const {},
  });

  /// تبديل أولوية (إضافة إن لم تكن موجودة، حذف إن كانت)
  TaskFilter togglePriority(int priority) {
    final newPriorities = Set<int>.from(priorities);
    if (newPriorities.contains(priority)) {
      newPriorities.remove(priority);
    } else {
      newPriorities.add(priority);
    }
    return copyWith(priorities: newPriorities);
  }

  /// تبديل فئة
  TaskFilter toggleCategory(TaskCategory category) {
    final newCategories = Set<TaskCategory>.from(categories);
    if (newCategories.contains(category)) {
      newCategories.remove(category);
    } else {
      newCategories.add(category);
    }
    return copyWith(categories: newCategories);
  }

  /// تبديل فلتر تاريخ
  TaskFilter toggleDateFilter(DateFilter dateFilter) {
    final newDateFilters = Set<DateFilter>.from(dateFilters);
    if (newDateFilters.contains(dateFilter)) {
      newDateFilters.remove(dateFilter);
    } else {
      newDateFilters.add(dateFilter);
    }
    return copyWith(dateFilters: newDateFilters);
  }

  /// تبديل وسم (إضافة إن لم يكن موجوداً، حذف إن كان)
  TaskFilter toggleTag(String tag) {
    final newTags = Set<String>.from(tags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    return copyWith(tags: newTags);
  }

  /// تبديل حالة المهمة (اختيار فردي — يُلغى إن نُقر مرة ثانية)
  TaskFilter toggleStatus(TaskStatus newStatus) {
    if (status == newStatus) {
      return copyWith(clearStatus: true);
    }
    return copyWith(status: newStatus);
  }

  TaskFilter copyWith({
    TaskStatus? status,
    Set<int>? priorities,
    Set<TaskCategory>? categories,
    Set<DateFilter>? dateFilters,
    Set<String>? tags,
    bool clearStatus = false,
  }) {
    return TaskFilter(
      status: clearStatus ? null : (status ?? this.status),
      priorities: priorities ?? this.priorities,
      categories: categories ?? this.categories,
      dateFilters: dateFilters ?? this.dateFilters,
      tags: tags ?? this.tags,
    );
  }

  bool get isActive {
    return status != null ||
        priorities.isNotEmpty ||
        categories.isNotEmpty ||
        dateFilters.isNotEmpty ||
        tags.isNotEmpty;
  }

  int get activeFiltersCount {
    int count = 0;
    if (status != null) count++;
    count += priorities.length;
    count += categories.length;
    count += dateFilters.length;
    count += tags.length;
    return count;
  }

  TaskFilter reset() => const TaskFilter();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TaskFilter) return false;
    if (other.status != status) return false;
    if (other.priorities.length != priorities.length) return false;
    if (other.categories.length != categories.length) return false;
    if (other.dateFilters.length != dateFilters.length) return false;
    if (other.tags.length != tags.length) return false;
    return other.priorities.containsAll(priorities) &&
        other.categories.containsAll(categories) &&
        other.dateFilters.containsAll(dateFilters) &&
        other.tags.containsAll(tags);
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      Object.hashAllUnordered(priorities),
      Object.hashAllUnordered(categories),
      Object.hashAllUnordered(dateFilters),
      Object.hashAllUnordered(tags),
    );
  }
}
