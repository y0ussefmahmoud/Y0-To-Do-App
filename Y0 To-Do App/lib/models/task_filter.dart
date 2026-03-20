import 'task_category.dart';

enum TaskStatus {
  all,
  pending,
  completed,
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

class TaskFilter {
  final TaskStatus? status;
  final int? priority;
  final TaskCategory? category;
  final DateFilter? dateFilter;

  const TaskFilter({
    this.status,
    this.priority,
    this.category,
    this.dateFilter,
  });

  TaskFilter copyWith({
    TaskStatus? status,
    int? priority,
    TaskCategory? category,
    DateFilter? dateFilter,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearCategory = false,
    bool clearDateFilter = false,
  }) {
    return TaskFilter(
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      category: clearCategory ? null : (category ?? this.category),
      dateFilter: clearDateFilter ? null : (dateFilter ?? this.dateFilter),
    );
  }

  bool get isActive {
    return status != null || 
           priority != null || 
           category != null || 
           dateFilter != null;
  }

  int get activeFiltersCount {
    int count = 0;
    if (status != null) count++;
    if (priority != null) count++;
    if (category != null) count++;
    if (dateFilter != null) count++;
    return count;
  }

  TaskFilter reset() {
    return const TaskFilter();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskFilter &&
        other.status == status &&
        other.priority == priority &&
        other.category == category &&
        other.dateFilter == dateFilter;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        priority.hashCode ^
        category.hashCode ^
        dateFilter.hashCode;
  }
}
