// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter_test/flutter_test.dart';
import 'package:y0_todo_app/models/recurrence_rule.dart';

void main() {
  group('RecurrenceRule — Next Due Date Calculations', () {
    final baseDate = DateTime(2026, 9, 4, 10, 0); // Thursday 2026-09-04

    test('Daily recurrence moves exactly 1 day forward', () {
      final rule = RecurrenceRule(frequency: RecurrenceFrequency.daily, interval: 1);
      final next = rule.calculateNextDueDate(baseDate);
      expect(next, isNotNull);
      expect(next!.year, equals(2026));
      expect(next.month, equals(9));
      expect(next.day, equals(5));
    });

    test('Daily recurrence with interval 3 moves 3 days forward', () {
      final rule = RecurrenceRule(frequency: RecurrenceFrequency.daily, interval: 3);
      final next = rule.calculateNextDueDate(baseDate);
      expect(next!.day, equals(7));
    });

    test('Weekly recurrence moves exactly 7 days forward', () {
      final rule = RecurrenceRule(frequency: RecurrenceFrequency.weekly, interval: 1);
      final next = rule.calculateNextDueDate(baseDate);
      expect(next!.day, equals(11)); // 4 + 7 = 11 September
    });

    test('Monthly recurrence moves exactly 1 month forward', () {
      final rule = RecurrenceRule(frequency: RecurrenceFrequency.monthly, interval: 1);
      final next = rule.calculateNextDueDate(baseDate);
      expect(next!.month, equals(10));
      expect(next.day, equals(4));
    });

    test('Monthly recurrence handles month overflow (end-of-month safety)', () {
      final endOfJan = DateTime(2026, 1, 31, 10, 0);
      final rule = RecurrenceRule(frequency: RecurrenceFrequency.monthly, interval: 1);
      final next = rule.calculateNextDueDate(endOfJan);
      expect(next!.month, equals(2));
      expect(next.day, lessThanOrEqualTo(28)); // Feb never has 31 days
    });

    test('endDate boundary: returns null when next date exceeds endDate', () {
      final rule = RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        endDate: DateTime(2026, 9, 4, 23, 59), // same day
      );
      final next = rule.calculateNextDueDate(baseDate);
      expect(next, isNull);
    });

    test('endDate boundary: returns date when next date is before endDate', () {
      final rule = RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        endDate: DateTime(2026, 12, 31),
      );
      final next = rule.calculateNextDueDate(baseDate);
      expect(next, isNotNull);
    });

    test('Tasks due on non-today dates do not contaminate today calculation', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      final ruleTomorrow = RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        endDate: DateTime(2030),
      );

      final nextFromTomorrow = ruleTomorrow.calculateNextDueDate(tomorrow);
      expect(nextFromTomorrow, isNotNull);
      // Spawned occurrence should be 1 day after tomorrow, not today
      final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      expect(nextFromTomorrow!.isAfter(todayStart), isTrue);
    });
  });
}
