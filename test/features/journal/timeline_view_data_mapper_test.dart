import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mental_health_insights/features/journal/domain/entities/journal_entry.dart';
import 'package:ai_mental_health_insights/features/journal/presentation/pages/widgets/timeline/timeline_view_data_mapper.dart';

void main() {
  const mapper = TimelineViewDataMapper();
  final now = DateTime(2026, 6, 18);

  JournalEntry buildEntry({
    required String id,
    required DateTime date,
    required double stressLevel,
  }) {
    return JournalEntry(
      id: id,
      date: date,
      positiveSymptom: 2,
      negativeSymptom: 3,
      sleepQuality: 7,
      stressLevel: stressLevel,
      socialEnergy: 6,
      note: 'note-$id',
    );
  }

  group('TimelineViewDataMapper', () {
    test('builds seven day slots and keeps missing days empty', () {
      final entries = [
        buildEntry(
          id: 'a',
          date: DateTime(2026, 6, 12),
          stressLevel: 4,
        ),
        buildEntry(
          id: 'b',
          date: DateTime(2026, 6, 16),
          stressLevel: 7,
        ),
        buildEntry(
          id: 'c',
          date: DateTime(2026, 6, 18),
          stressLevel: 5,
        ),
      ];

      final viewData = mapper.map(entries, now: now);

      expect(viewData.weekSlots, hasLength(7));
      expect(viewData.weekSlots.first.date, DateTime(2026, 6, 12));
      expect(viewData.weekSlots[0].entry?.id, 'a');
      expect(viewData.weekSlots[1].entry, isNull);
      expect(viewData.weekSlots[4].entry?.id, 'b');
      expect(viewData.weekSlots.last.entry?.id, 'c');
    });

    test('builds summary and recent entries from latest entry', () {
      final older = buildEntry(
        id: 'older',
        date: DateTime(2026, 6, 14),
        stressLevel: 3,
      );
      final latest = buildEntry(
        id: 'latest',
        date: DateTime(2026, 6, 18),
        stressLevel: 8,
      );

      final viewData = mapper.map([older, latest], now: now);

      expect(viewData.summary.loggedDaysCount, 2);
      expect(viewData.summary.latestCheckInDate, latest.date);
      expect(viewData.summary.latestStressLevel, 8);
      expect(viewData.recentEntries.first.id, 'latest');
      expect(viewData.recentEntries.last.id, 'older');
    });
  });
}
