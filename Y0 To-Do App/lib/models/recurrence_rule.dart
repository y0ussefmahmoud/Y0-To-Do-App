// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:hive/hive.dart';

part 'recurrence_rule.g.dart';

/// تكرار المهمة (Recurrence Frequency)
@HiveType(typeId: 9)
enum RecurrenceFrequency {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,

  @HiveField(3)
  custom,
}

/// قاعدة تكرار المهمة (Recurrence Rule Model)
@HiveType(typeId: 5)
class RecurrenceRule {
  /// وتيرة التكرار (يومي، أسبوعي، شهري، مخصص)
  @HiveField(0)
  final RecurrenceFrequency frequency;

  /// الفاصل الزمني (مثلاً كل 1 يوم، أو كل 2 أسبوع)
  @HiveField(1)
  final int interval;

  /// أيام الأسبوع المحددة في التكرار الأسبوعي/المخصص (1 = الاثنين ... 7 = الأحد)
  @HiveField(2)
  final List<int>? daysOfWeek;

  /// تاريخ انتهاء التكرار (اختياري)
  @HiveField(3)
  final DateTime? endDate;

  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek,
    this.endDate,
  });

  /// حساب تاريخ الاستحقاق التالي بناءً على تاريخ الاستحقاق الحالي
  DateTime? calculateNextDueDate(DateTime fromDate) {
    DateTime nextDate;

    switch (frequency) {
      case RecurrenceFrequency.daily:
        nextDate = fromDate.add(Duration(days: interval > 0 ? interval : 1));
        break;

      case RecurrenceFrequency.weekly:
        if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          final sortedDays = List<int>.from(daysOfWeek!)..sort();
          final currentWeekday = fromDate.weekday;
          int? nextDay;

          for (final day in sortedDays) {
            if (day > currentWeekday) {
              nextDay = day;
              break;
            }
          }

          if (nextDay != null) {
            final daysToAdd = nextDay - currentWeekday;
            nextDate = fromDate.add(Duration(days: daysToAdd));
          } else {
            // الانتقال إلى الأسبوع القادم
            final daysToNextWeekFirstDay =
                (7 - currentWeekday) + sortedDays.first + ((interval - 1) * 7);
            nextDate = fromDate.add(Duration(days: daysToNextWeekFirstDay));
          }
        } else {
          nextDate = fromDate.add(Duration(days: 7 * (interval > 0 ? interval : 1)));
        }
        break;

      case RecurrenceFrequency.monthly:
        final currentMonth = fromDate.month;
        final currentYear = fromDate.year;
        final monthsToAdd = interval > 0 ? interval : 1;

        int newMonth = currentMonth + monthsToAdd;
        int newYear = currentYear;

        while (newMonth > 12) {
          newMonth -= 12;
          newYear += 1;
        }

        // حساب عدد أيام الشهر المستهدف لمنع أخطاء تجاوز الأيام (مثل 31 فبراير)
        final lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;
        final newDay = fromDate.day <= lastDayOfNewMonth ? fromDate.day : lastDayOfNewMonth;

        nextDate = DateTime(
          newYear,
          newMonth,
          newDay,
          fromDate.hour,
          fromDate.minute,
          fromDate.second,
        );
        break;

      case RecurrenceFrequency.custom:
        nextDate = fromDate.add(Duration(days: interval > 0 ? interval : 1));
        break;
    }

    // التحقق من تاريخ انتهاء التكرار
    if (endDate != null && nextDate.isAfter(endDate!)) {
      return null;
    }

    return nextDate;
  }

  /// نص وصفي مختصر للتكرار (بدون سياق — يستخدم مفاتيح ARB في الواجهة مباشرة)
  String get label {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return interval > 1 ? 'كل $interval أيام' : 'يومياً';
      case RecurrenceFrequency.weekly:
        return interval > 1 ? 'كل $interval أسابيع' : 'أسبوعياً';
      case RecurrenceFrequency.monthly:
        return interval > 1 ? 'كل $interval أشهر' : 'شهرياً';
      case RecurrenceFrequency.custom:
        return 'مخصص';
    }
  }

  RecurrenceRule copyWith({
    RecurrenceFrequency? frequency,
    int? interval,
    List<int>? daysOfWeek,
    DateTime? endDate,
  }) {
    return RecurrenceRule(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency.name,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    return RecurrenceRule(
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => RecurrenceFrequency.daily,
      ),
      interval: json['interval'] as int? ?? 1,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)?.map((e) => e as int).toList(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceRule &&
          runtimeType == other.runtimeType &&
          frequency == other.frequency &&
          interval == other.interval &&
          endDate == other.endDate;

  @override
  int get hashCode => frequency.hashCode ^ interval.hashCode ^ endDate.hashCode;
}
