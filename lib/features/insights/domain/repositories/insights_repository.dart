import '../../../journal/domain/entities/journal_entry.dart';
import '../entities/weekly_insights.dart';

/// Abstract contract for the insights repository.
abstract class InsightsRepository {
  /// Sends [entries] to the AI provider and returns structured [WeeklyInsights].
  Future<WeeklyInsights> generateInsights(List<JournalEntry> entries);
}
