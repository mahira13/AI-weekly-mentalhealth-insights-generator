import '../../../../domain/entities/journal_entry.dart';
import 'timeline_models.dart';

class TimelineViewDataMapper {
  const TimelineViewDataMapper();

  TimelineViewData map(
    List<JournalEntry> entries, {
    required DateTime now,
  }) {
    final recentEntries = [...entries]
      ..sort((left, right) => right.date.compareTo(left.date));
    final latestEntry = recentEntries.first;

    return TimelineViewData(
      weekSlots: _buildWeekSlots(entries, now: now),
      summary: TimelineSummaryData(
        loggedDaysCount: entries.length,
        latestCheckInDate: latestEntry.date,
        latestStressLevel: latestEntry.stressLevel,
      ),
      recentEntries: recentEntries,
    );
  }

  List<TimelineDaySlot> _buildWeekSlots(
    List<JournalEntry> entries, {
    required DateTime now,
  }) {
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return TimelineDaySlot(
        date: date,
        entry: _entryForDate(entries, date),
      );
    });
  }

  JournalEntry? _entryForDate(List<JournalEntry> entries, DateTime date) {
    for (final entry in entries) {
      if (_isSameDate(entry.date, date)) {
        return entry;
      }
    }
    return null;
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
