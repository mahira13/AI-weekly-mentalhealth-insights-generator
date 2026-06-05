import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mental_health_insights/features/insights/data/models/weekly_insights_model.dart';
import 'package:ai_mental_health_insights/features/journal/domain/entities/journal_entry.dart';

void main() {
  group('WeeklyInsightsModel', () {
    test('fromJson parses all fields correctly', () {
      final json = <String, dynamic>{
        'patterns': 'High stress mid-week',
        'early_warning': 'Elevated suspicion on Thu/Fri',
        'self_care_suggestion': 'Practise 4-7-8 breathing',
        'summary': 'You had a challenging week.',
      };

      final model = WeeklyInsightsModel.fromJson(json);

      expect(model.patterns, 'High stress mid-week');
      expect(model.earlyWarning, 'Elevated suspicion on Thu/Fri');
      expect(model.selfCareSuggestion, 'Practise 4-7-8 breathing');
      expect(model.summary, 'You had a challenging week.');
    });

    test('fromJson uses empty string for missing fields', () {
      final model = WeeklyInsightsModel.fromJson({});

      expect(model.patterns, '');
      expect(model.earlyWarning, '');
      expect(model.selfCareSuggestion, '');
      expect(model.summary, '');
    });

    test('toEntity produces a WeeklyInsights with matching fields', () {
      const model = WeeklyInsightsModel(
        patterns: 'p',
        earlyWarning: 'w',
        selfCareSuggestion: 's',
        summary: 'sum',
      );

      final entity = model.toEntity();

      expect(entity.patterns, model.patterns);
      expect(entity.earlyWarning, model.earlyWarning);
      expect(entity.selfCareSuggestion, model.selfCareSuggestion);
      expect(entity.summary, model.summary);
    });

    group('buildPrompt', () {
      test('includes all entry data in the prompt', () {
        final entries = [
          JournalEntry(
            id: 'id-1',
            date: DateTime(2024, 6, 3),
            racingThoughts: 5.0,
            suspicion: 3.0,
            lowMotivation: 4.0,
            socialWithdrawal: 2.0,
            sleepHours: 6.0,
            stressLevel: 7.0,
          ),
        ];

        final prompt = WeeklyInsightsModel.buildPrompt(entries);

        expect(prompt, contains('2024-06-03'));
        expect(prompt, contains('racingThoughts=5.0'));
        expect(prompt, contains('stressLevel=7.0'));
      });
    });
  });
}
