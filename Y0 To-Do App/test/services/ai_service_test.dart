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
  });
}
