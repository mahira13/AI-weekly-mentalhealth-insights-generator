import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

/// Use case: retrieve the last 7 days of journal entries.
class GetWeeklyEntries {
  final JournalRepository _repository;

  const GetWeeklyEntries(this._repository);

  Future<List<JournalEntry>> call() => _repository.getWeeklyEntries();
}
