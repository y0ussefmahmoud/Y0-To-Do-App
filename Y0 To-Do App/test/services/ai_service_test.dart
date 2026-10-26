// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter_test/flutter_test.dart';
import 'package:y0_todo_app/services/ai_service.dart';

void main() {
  group('AIService', () {
    test('analyzeTaskText extracts priority and due date', () {
      final analysis = AIService().analyzeTaskText('مهمة مهمة غداً');

      expect(analysis.priority, 2);
      expect(analysis.dueDate, isNotNull);
    });

    test('getSmartSuggestions returns three items and is stable within hour', () {
      final service = AIService();
      final first = service.getSmartSuggestions([]);
      final second = service.getSmartSuggestions([]);

      expect(first.length, 3);
      expect(second.length, 3);
      expect(second, first);
    });

    test('analyzeProductivity handles empty list', () {
      final analysis = AIService().analyzeProductivity([]);

      expect(analysis.score, 0);
      expect(analysis.suggestions, isNotEmpty);
    });

    // ── v3.5.0: Deep NLP Time & Date Extraction Tests ─────────────────────

    test('NLP extracts Arabic time and tomorrow date correctly', () {
      final analysis = AIService().analyzeTaskText('اجتماع الفريق غداً الساعة 5 مساءً عاجل');

      expect(analysis.priority, 2); // عاجل -> high priority
      expect(analysis.dueDate, isNotNull);
      expect(analysis.dueDate!.hour, 17); // 5 PM -> 17:00
      expect(analysis.dueDate!.minute, 0);
    });

    test('NLP extracts Arabic morning time correctly', () {
      final analysis = AIService().analyzeTaskText('تسليم التقرير اليوم الساعة 9:30 صباحاً ضروري');

      expect(analysis.priority, 2); // ضروري -> high priority
      expect(analysis.dueDate, isNotNull);
      expect(analysis.dueDate!.hour, 9);
      expect(analysis.dueDate!.minute, 30);
    });

    test('NLP extracts English 12h time and date correctly', () {
      final analysis = AIService().analyzeTaskText('Team sync tomorrow at 3:15pm urgent');

      expect(analysis.priority, 2); // urgent -> high priority
      expect(analysis.dueDate, isNotNull);
      expect(analysis.dueDate!.hour, 15);
      expect(analysis.dueDate!.minute, 15);
    });

    test('NLP extracts English 24h time correctly', () {
      final analysis = AIService().analyzeTaskText('Project review next week at 14:00 important');

      expect(analysis.priority, 2); // important -> high priority
      expect(analysis.dueDate, isNotNull);
      expect(analysis.dueDate!.hour, 14);
      expect(analysis.dueDate!.minute, 0);
    });

    test('NLP handles text without time as standard date', () {
      final analysis = AIService().analyzeTaskText('مهمة عادية غداً');

      expect(analysis.dueDate, isNotNull);
      expect(analysis.dueDate!.hour, 0);
      expect(analysis.dueDate!.minute, 0);
    });
  });
}
