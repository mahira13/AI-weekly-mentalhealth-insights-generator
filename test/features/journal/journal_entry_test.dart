import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mental_health_insights/features/journal/domain/entities/journal_entry.dart';

void main() {
  // Use a fixed DateTime so tests are deterministic.
  final testDate = DateTime(2024, 6, 1);

  group('JournalEntry', () {
    late JournalEntry entry;

    setUp(() {
      entry = JournalEntry(
        id: 'test-id',
        date: testDate,
        positiveSymptom: 3.0,
        negativeSymptom: 5.0,
        sleepQuality: 6.5,
        stressLevel: 7.0,
        socialEnergy: 8.0,
        note: 'Calmer by evening',
      );
    });

    test('copyWith creates a new entry with updated fields', () {
      final updated = entry.copyWith(positiveSymptom: 8.0, stressLevel: 9.0);

      expect(updated.positiveSymptom, 8.0);
      expect(updated.stressLevel, 9.0);
      // unchanged fields preserved
      expect(updated.id, entry.id);
      expect(updated.negativeSymptom, entry.negativeSymptom);
      expect(updated.sleepQuality, entry.sleepQuality);
    });

    test('two entries with same data are equal (Equatable)', () {
      final other = JournalEntry(
        id: 'test-id',
        date: testDate,
        positiveSymptom: 3.0,
        negativeSymptom: 5.0,
        sleepQuality: 6.5,
        stressLevel: 7.0,
        socialEnergy: 8.0,
        note: 'Calmer by evening',
      );
      expect(entry, equals(other));
    });

    test('different ids produce different entries', () {
      final other = entry.copyWith(id: 'other-id');
      expect(entry, isNot(equals(other)));
    });

    test('props list contains all fields', () {
      expect(entry.props, hasLength(8));
    });
  });
}
