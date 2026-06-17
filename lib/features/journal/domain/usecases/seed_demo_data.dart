import '../repositories/journal_repository.dart';

/// Use case: seed 7 days of demo journal data for testing.
class SeedDemoData {
  final JournalRepository _repository;

  const SeedDemoData(this._repository);

  Future<void> call() => _repository.seedDemoData();
}
