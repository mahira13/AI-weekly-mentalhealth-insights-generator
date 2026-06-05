import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mental_health_insights/features/insights/domain/entities/weekly_insights.dart';

void main() {
  group('WeeklyInsights', () {
    test('hasEarlyWarning is true when earlyWarning is non-empty', () {
      const insights = WeeklyInsights(
        patterns: 'Some pattern',
        earlyWarning: 'Elevated suspicion trend detected',
        selfCareSuggestion: 'Try a 5-minute grounding exercise',
        summary: 'Overall a mixed week.',
      );

      expect(insights.hasEarlyWarning, isTrue);
    });

    test('hasEarlyWarning is false when earlyWarning is empty', () {
      const insights = WeeklyInsights(
        patterns: 'Stable mood',
        earlyWarning: '',
        selfCareSuggestion: 'Maintain current routine',
        summary: 'Good week overall.',
      );

      expect(insights.hasEarlyWarning, isFalse);
    });

    test('hasEarlyWarning is false for whitespace-only earlyWarning', () {
      const insights = WeeklyInsights(
        patterns: 'Stable',
        earlyWarning: '   ',
        selfCareSuggestion: 'Keep journaling',
        summary: 'A quiet week.',
      );

      expect(insights.hasEarlyWarning, isFalse);
    });

    test('two equal instances are equal via Equatable', () {
      const a = WeeklyInsights(
        patterns: 'p',
        earlyWarning: 'w',
        selfCareSuggestion: 's',
        summary: 'sum',
      );
      const b = WeeklyInsights(
        patterns: 'p',
        earlyWarning: 'w',
        selfCareSuggestion: 's',
        summary: 'sum',
      );
      expect(a, equals(b));
    });
  });
}
