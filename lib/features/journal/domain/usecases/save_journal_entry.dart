import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

/// Use case: persist a daily [JournalEntry].
class SaveJournalEntry {
  final JournalRepository _repository;

  const SaveJournalEntry(this._repository);

  Future<void> call(JournalEntry entry) => _repository.saveEntry(entry);
}
