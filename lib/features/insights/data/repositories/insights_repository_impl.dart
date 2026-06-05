import '../datasources/insights_remote_datasource.dart';
import '../../../journal/domain/entities/journal_entry.dart';
import '../../domain/entities/weekly_insights.dart';
import '../../domain/repositories/insights_repository.dart';
import '../../../../core/error/failures.dart';

/// Concrete implementation of [InsightsRepository].
class InsightsRepositoryImpl implements InsightsRepository {
  final InsightsRemoteDataSource remoteDataSource;

  const InsightsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WeeklyInsights> generateInsights(List<JournalEntry> entries) async {
    try {
      final model = await remoteDataSource.fetchInsights(entries);
      return model.toEntity();
    } on AuthFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } on ParseFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Unexpected error generating insights: $e');
    }
  }
}
