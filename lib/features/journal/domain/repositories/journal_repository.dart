import '../entities/journal_entry.dart';

/// Abstract contract for the journal repository.
///
/// Implementations live in the data layer.
abstract class JournalRepository {
  /// Persists a [JournalEntry] to local storage.
  Future<void> saveEntry(JournalEntry entry);

  /// Returns all [JournalEntry] records from the last 7 days,
  /// ordered chronologically (oldest first).
  Future<List<JournalEntry>> getWeeklyEntries();

  /// Returns all stored [JournalEntry] records, ordered chronologically.
  Future<List<JournalEntry>> getAllEntries();

  /// Deletes the entry identified by [id].
  Future<void> deleteEntry(String id);
}
