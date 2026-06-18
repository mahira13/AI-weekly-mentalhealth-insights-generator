import 'package:ai_mental_health_insights/features/insights/data/models/weekly_insights_model.dart';
import 'package:ai_mental_health_insights/features/journal/domain/entities/journal_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklyInsightsModel', () {
    test('fromJson parses all fields correctly', () {
      final json = <String, dynamic>{
        'patterns': 'High stress mid-week',
        'positives': 'Better social contact on two days.',
        'concerns': 'Poor sleep was followed by more distress.',
        'note_observations':
            'Notes described smoking, withdrawal, and fear at night.',
        'early_warning': 'Elevated suspicion on Thu/Fri',
        'self_care_suggestion': 'Practise 4-7-8 breathing',
        'clinician_summary': 'Symptoms intensified after low-sleep nights.',
        'summary': 'You had a challenging week.',
      };

      final model = WeeklyInsightsModel.fromJson(json);

      expect(model.patterns, 'High stress mid-week');
      expect(model.positives, 'Better social contact on two days.');
      expect(
        model.concerns,
        'Poor sleep was followed by more distress.',
      );
      expect(
        model.noteObservations,
        'Notes described smoking, withdrawal, and fear at night.',
      );
      expect(model.earlyWarning, 'Elevated suspicion on Thu/Fri');
      expect(model.selfCareSuggestion, 'Practise 4-7-8 breathing');
      expect(
        model.clinicianSummary,
        'Symptoms intensified after low-sleep nights.',
      );
      expect(model.summary, 'You had a challenging week.');
    });

    test('fromJson uses empty string for missing fields', () {
      final model = WeeklyInsightsModel.fromJson({});

      expect(model.patterns, '');
      expect(model.positives, '');
      expect(model.concerns, '');
      expect(model.noteObservations, '');
      expect(model.earlyWarning, '');
      expect(model.selfCareSuggestion, '');
      expect(model.clinicianSummary, '');
      expect(model.summary, '');
    });

    test('fromJson coerces list fields into readable text', () {
      final json = <String, dynamic>{
        'patterns': [
          'Stress was higher mid-week.',
          'Sleep dipped on two days.'
        ],
        'positives': ['A friend meet-up looked supportive.'],
        'concerns': ['Withdrawal increased after rough nights.'],
        'note_observations': [
          {'text': 'Notes linked smoking, fear, and poor sleep.'},
        ],
        'early_warning': ['Low sleep and high stress clustered together.'],
        'self_care_suggestion': [
          {'text': 'Protect a consistent wind-down routine.'},
        ],
        'clinician_summary': [
          'Brief improvement days were present but unstable.',
        ],
        'summary': [
          'This week showed some strain.',
          'There were also signs of recovery at the end.',
        ],
      };

      final model = WeeklyInsightsModel.fromJson(json);

      expect(
        model.patterns,
        'Stress was higher mid-week. Sleep dipped on two days.',
      );
      expect(
        model.earlyWarning,
        'Low sleep and high stress clustered together.',
      );
      expect(model.positives, 'A friend meet-up looked supportive.');
      expect(
        model.concerns,
        'Withdrawal increased after rough nights.',
      );
      expect(
        model.noteObservations,
        'Notes linked smoking, fear, and poor sleep.',
      );
      expect(
        model.selfCareSuggestion,
        'Protect a consistent wind-down routine.',
      );
      expect(
        model.clinicianSummary,
        'Brief improvement days were present but unstable.',
      );
      expect(
        model.summary,
        'This week showed some strain. There were also signs of recovery at the end.',
      );
    });

    test('toEntity produces a WeeklyInsights with matching fields', () {
      const model = WeeklyInsightsModel(
        patterns: 'p',
        positives: 'pos',
        concerns: 'conc',
        noteObservations: 'notes',
        earlyWarning: 'w',
        selfCareSuggestion: 's',
        clinicianSummary: 'clin',
        summary: 'sum',
      );

      final entity = model.toEntity();

      expect(entity.patterns, model.patterns);
      expect(entity.positives, model.positives);
      expect(entity.concerns, model.concerns);
      expect(entity.noteObservations, model.noteObservations);
      expect(entity.earlyWarning, model.earlyWarning);
      expect(entity.selfCareSuggestion, model.selfCareSuggestion);
      expect(entity.clinicianSummary, model.clinicianSummary);
      expect(entity.summary, model.summary);
    });

    group('buildPrompt', () {
      test('includes all entry data in the prompt', () {
        final entries = [
          JournalEntry(
            id: 'id-1',
            date: DateTime(2024, 6, 3),
            positiveSymptom: 5.0,
            negativeSymptom: 4.0,
            sleepQuality: 6.0,
            stressLevel: 7.0,
            socialEnergy: 8.0,
            note: 'Reached out to a friend',
          ),
        ];

        final prompt = WeeklyInsightsModel.buildPrompt(entries);

        expect(prompt, contains('2024-06-03'));
        expect(prompt, contains('positive symptoms moderate'));
        expect(prompt, contains('stress high'));
        expect(prompt, contains('social energy fairly steady'));
        expect(prompt, contains('Note: Reached out to a friend'));
        expect(prompt.contains('your week in words'), isFalse);
        expect(prompt, contains('compassionate observer'));
        expect(prompt, contains('Do not quote raw numbers'));
        expect(
          prompt,
          contains('Never reuse the same sentence or phrasing across two keys'),
        );
      });

      test('truncates long notes to keep prompt compact', () {
        final entries = [
          JournalEntry(
            id: 'id-2',
            date: DateTime(2024, 6, 4),
            positiveSymptom: 4.0,
            negativeSymptom: 3.0,
            sleepQuality: 5.0,
            stressLevel: 6.0,
            socialEnergy: 7.0,
            note: 'This is a very long journal note that should be shortened '
                'before it is sent to the local model so the prompt stays '
                'within the token budget.',
          ),
        ];

        final prompt = WeeklyInsightsModel.buildPrompt(entries);

        expect(prompt, contains('Note: This is a very long journal note'));
        expect(prompt, contains('…'));
        expect(prompt, isNot(contains('within the token budget.')));
      });
    });

    group('fromRawResponse', () {
      test('parses plain json', () {
        final model = WeeklyInsightsModel.fromRawResponse('''
{
  "patterns": "Sleep improved midweek.",
  "positives": "Energy felt steadier on the days with better sleep.",
  "concerns": "Stress still rose when routines slipped.",
  "note_observations": "Notes described relief after reaching out to someone.",
  "early_warning": "",
  "self_care_suggestion": "Keep a stable bedtime.",
  "clinician_summary": "Symptoms were milder on better-sleep days and worsened when routine destabilized.",
  "summary": "This week showed steadier energy."
}
''');

        expect(model.patterns, 'Sleep improved midweek.');
        expect(
          model.positives,
          'Energy felt steadier on the days with better sleep.',
        );
        expect(model.earlyWarning, isEmpty);
        expect(model.selfCareSuggestion, 'Keep a stable bedtime.');
        expect(
          model.clinicianSummary,
          'Symptoms were milder on better-sleep days and worsened when routine destabilized.',
        );
        expect(model.summary, 'This week showed steadier energy.');
      });

      test('parses fenced json with surrounding text', () {
        final model = WeeklyInsightsModel.fromRawResponse('''
Here is the response:
```json
{
  "patterns": "Stress was higher on low-sleep days.",
  "positives": "A walk and a conversation appeared to help on one day.",
  "concerns": "Poor sleep clustered with more distress.",
  "note_observations": "Notes connected fear, avoidance, and heavy smoking with the harder nights.",
  "early_warning": "Notice the cluster of poor sleep and rising stress.",
  "self_care_suggestion": "Plan one earlier wind-down routine this week.",
  "clinician_summary": "The week shows alternating brief stabilization and sharper symptom increases after reduced sleep.",
  "summary": "There was a clear link between sleep and stress. A small sleep routine may help steady the next few days."
}
```
''');

        expect(model.patterns, 'Stress was higher on low-sleep days.');
        expect(
          model.earlyWarning,
          'Notice the cluster of poor sleep and rising stress.',
        );
        expect(
          model.noteObservations,
          'Notes connected fear, avoidance, and heavy smoking with the harder nights.',
        );
      });

      test('parses function-call styled wrapper output', () {
        final model = WeeklyInsightsModel.fromRawResponse('''
<start_function_call>call
[
  {
    "patterns": "Stress rose on the same days that sleep dropped.",
    "positives": "A calmer social day suggested some recovery capacity.",
    "concerns": "Sleep disruption and suspiciousness appeared together.",
    "note_observations": "The notes described withdrawal, smoking, and hypervigilance on the toughest days.",
    "early_warning": "Several low-sleep days clustered with higher strain.",
    "self_care_suggestion": "Protect one consistent wind-down routine before bed.",
    "clinician_summary": "The overall week shows repeated worsening after low-sleep periods with intermittent better-functioning days.",
    "summary": "This week suggests that sleep disruption may be making the harder days feel heavier. A small bedtime routine may help steady the next week."
  }
]
<end_function_call>
''');

        expect(
            model.patterns, 'Stress rose on the same days that sleep dropped.');
        expect(
          model.earlyWarning,
          'Several low-sleep days clustered with higher strain.',
        );
        expect(
          model.selfCareSuggestion,
          'Protect one consistent wind-down routine before bed.',
        );
        expect(
          model.clinicianSummary,
          'The overall week shows repeated worsening after low-sleep periods with intermittent better-functioning days.',
        );
      });
    });
  });
}
