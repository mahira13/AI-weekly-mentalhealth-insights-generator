import '../datasources/journal_local_datasource.dart';
import '../models/journal_entry_model.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../../../core/error/failures.dart';

/// Concrete implementation of [JournalRepository] backed by Hive.
class JournalRepositoryImpl implements JournalRepository {
  final JournalLocalDataSource localDataSource;

  const JournalRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveEntry(JournalEntry entry) async {
    try {
      final model = JournalEntryModel.fromEntity(entry);
      await localDataSource.saveEntry(model);
    } on CacheFailure {
      rethrow;
    } catch (e) {
      throw CacheFailure('Unexpected error saving entry: $e');
    }
  }

  @override
  Future<List<JournalEntry>> getWeeklyEntries() async {
    try {
      final models = await localDataSource.getWeeklyEntries();
      return models.map((m) => m.toEntity()).toList();
    } on CacheFailure {
      rethrow;
    } catch (e) {
      throw CacheFailure('Unexpected error loading weekly entries: $e');
    }
  }

  @override
  Future<List<JournalEntry>> getAllEntries() async {
    try {
      final models = await localDataSource.getAllEntries();
      return models.map((m) => m.toEntity()).toList();
    } on CacheFailure {
      rethrow;
    } catch (e) {
      throw CacheFailure('Unexpected error loading all entries: $e');
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      await localDataSource.deleteEntry(id);
    } on CacheFailure {
      rethrow;
    } catch (e) {
      throw CacheFailure('Unexpected error deleting entry: $e');
    }
  }

  @override
  Future<void> seedDemoData() async {
    try {
      await localDataSource.seedDemoData();
    } on CacheFailure {
      rethrow;
    } catch (e) {
      throw CacheFailure('Unexpected error seeding demo data: $e');
    }
  }
}
