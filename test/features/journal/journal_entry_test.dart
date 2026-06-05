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
        racingThoughts: 3.0,
        suspicion: 2.0,
        lowMotivation: 5.0,
        socialWithdrawal: 4.0,
        sleepHours: 6.5,
        stressLevel: 7.0,
      );
    });

    test('copyWith creates a new entry with updated fields', () {
      final updated = entry.copyWith(racingThoughts: 8.0, stressLevel: 9.0);

      expect(updated.racingThoughts, 8.0);
      expect(updated.stressLevel, 9.0);
      // unchanged fields preserved
      expect(updated.id, entry.id);
      expect(updated.suspicion, entry.suspicion);
      expect(updated.sleepHours, entry.sleepHours);
    });

    test('two entries with same data are equal (Equatable)', () {
      final other = JournalEntry(
        id: 'test-id',
        date: testDate,
        racingThoughts: 3.0,
        suspicion: 2.0,
        lowMotivation: 5.0,
        socialWithdrawal: 4.0,
        sleepHours: 6.5,
        stressLevel: 7.0,
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
