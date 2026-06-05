import '../../../journal/domain/entities/journal_entry.dart';
import '../entities/weekly_insights.dart';
import '../repositories/insights_repository.dart';

/// Use case: generate AI-powered weekly insights from [entries].
class GenerateWeeklyInsights {
  final InsightsRepository _repository;

  const GenerateWeeklyInsights(this._repository);

  Future<WeeklyInsights> call(List<JournalEntry> entries) =>
      _repository.generateInsights(entries);
}
