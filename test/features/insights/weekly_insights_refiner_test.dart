import 'package:ai_mental_health_insights/features/insights/data/models/weekly_insights_model.dart';
import 'package:ai_mental_health_insights/features/insights/data/services/weekly_insights_refiner.dart';
import 'package:ai_mental_health_insights/features/journal/domain/entities/journal_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklyInsightsRefiner', () {
    test('replaces repetitive echoed output with section-specific insights',
        () {
      final entries = [
        JournalEntry(
          id: '1',
          date: DateTime(2024, 6, 3),
          positiveSymptom: 3,
          negativeSymptom: 4,
          sleepQuality: 7,
          stressLevel: 4,
          socialEnergy: 7,
          note: 'Had coffee with a friend and felt more present.',
        ),
        JournalEntry(
          id: '2',
          date: DateTime(2024, 6, 4),
          positiveSymptom: 5,
          negativeSymptom: 5,
          sleepQuality: 5,
          stressLevel: 6,
          socialEnergy: 5,
          note: 'Work felt intense and I kept replaying it at night.',
        ),
        JournalEntry(
          id: '3',
          date: DateTime(2024, 6, 5),
          positiveSymptom: 6,
          negativeSymptom: 7,
          sleepQuality: 3,
          stressLevel: 8,
          socialEnergy: 3,
          note: 'Stayed home, avoided messages, and felt worn down.',
        ),
      ];

      const echoed = 'Positive symptoms mixed, negative symptoms mixed, '
          'sleep mixed, stress mixed, social energy mixed. '
          'Note: Two weeks of tracking now. Looking back is strange.';

      const draft = WeeklyInsightsModel(
        patterns: echoed,
        positives: echoed,
        concerns: echoed,
        noteObservations: echoed,
        earlyWarning: echoed,
        selfCareSuggestion: echoed,
        clinicianSummary: echoed,
        summary: echoed,
      );

      final refined = WeeklyInsightsRefiner.refine(
        draft: draft,
        entries: entries,
      );

      expect(refined.summary, isNot(contains('positive symptoms mixed')));
      expect(refined.positives, isNot(equals(refined.summary)));
      expect(refined.patterns, isNot(equals(refined.concerns)));
      expect(refined.noteObservations, contains('friend'));
      expect(refined.noteObservations, contains('Work'));
      expect(refined.earlyWarning, isNotEmpty);
    });
  });
}
