// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter_test/flutter_test.dart';
import 'package:y0_todo_app/utils/date_utils.dart';

void main() {
  group('AppDateUtils Tests', () {
    test('isToday returns true for DateTime.now() and dates matching today', () {
      final now = DateTime.now();
      final todayMorning = DateTime(now.year, now.month, now.day, 6, 0);
      final todayNight = DateTime(now.year, now.month, now.day, 23, 59);

      expect(AppDateUtils.isToday(now), isTrue);
      expect(AppDateUtils.isToday(todayMorning), isTrue);
      expect(AppDateUtils.isToday(todayNight), isTrue);
    });

    test('isToday returns false for yesterday, tomorrow, and null', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      expect(AppDateUtils.isToday(yesterday), isFalse);
      expect(AppDateUtils.isToday(tomorrow), isFalse);
      expect(AppDateUtils.isToday(null), isFalse);
    });

    test('isSameDay matches year, month, and day regardless of time', () {
      final d1 = DateTime(2026, 8, 26, 10, 30, 45);
      final d2 = DateTime(2026, 8, 26, 22, 15, 0);
      final d3 = DateTime(2026, 8, 27, 10, 30, 45);

      expect(AppDateUtils.isSameDay(d1, d2), isTrue);
      expect(AppDateUtils.isSameDay(d1, d3), isFalse);
      expect(AppDateUtils.isSameDay(d1, null), isFalse);
      expect(AppDateUtils.isSameDay(null, null), isFalse);
    });
  });
}
