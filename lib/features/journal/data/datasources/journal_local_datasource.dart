import 'package:hive/hive.dart';

import '../models/journal_entry_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';

/// Contract for local journal storage operations.
abstract class JournalLocalDataSource {
  Future<void> saveEntry(JournalEntryModel model);
  Future<List<JournalEntryModel>> getWeeklyEntries();
  Future<List<JournalEntryModel>> getAllEntries();
  Future<void> deleteEntry(String id);
}

/// Hive implementation of [JournalLocalDataSource].
class JournalLocalDataSourceImpl implements JournalLocalDataSource {
  final Box<JournalEntryModel> box;

  const JournalLocalDataSourceImpl({required this.box});

  @override
  Future<void> saveEntry(JournalEntryModel model) async {
    try {
      await box.put(model.id, model);
    } catch (e) {
      throw CacheFailure('Failed to save journal entry: $e');
    }
  }

  @override
  Future<List<JournalEntryModel>> getWeeklyEntries() async {
    try {
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: AppConstants.weekDays));
      final entries = box.values
          .where((e) => e.date.isAfter(cutoff))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      return entries;
    } catch (e) {
      throw CacheFailure('Failed to load weekly entries: $e');
    }
  }

  @override
  Future<List<JournalEntryModel>> getAllEntries() async {
    try {
      final entries = box.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      return entries;
    } catch (e) {
      throw CacheFailure('Failed to load all entries: $e');
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      await box.delete(id);
    } catch (e) {
      throw CacheFailure('Failed to delete journal entry: $e');
    }
  }
}
