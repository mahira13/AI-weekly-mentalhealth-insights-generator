import '../../../../domain/entities/journal_entry.dart';

class TimelineDaySlot {
  const TimelineDaySlot({
    required this.date,
    required this.entry,
  });

  final DateTime date;
  final JournalEntry? entry;
}

class TimelineSummaryData {
  const TimelineSummaryData({
    required this.loggedDaysCount,
    required this.latestCheckInDate,
    required this.latestStressLevel,
  });

  final int loggedDaysCount;
  final DateTime latestCheckInDate;
  final double latestStressLevel;
}

class TimelineViewData {
  const TimelineViewData({
    required this.weekSlots,
    required this.summary,
    required this.recentEntries,
  });

  final List<TimelineDaySlot> weekSlots;
  final TimelineSummaryData summary;
  final List<JournalEntry> recentEntries;
}
