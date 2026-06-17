import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../features/insights/data/datasources/insights_remote_datasource.dart';
import '../../features/insights/data/repositories/insights_repository_impl.dart';
import '../../features/insights/domain/repositories/insights_repository.dart';
import '../../features/insights/domain/usecases/generate_weekly_insights.dart';
import '../../features/insights/presentation/bloc/insights_bloc.dart';
import '../../features/journal/data/datasources/journal_local_datasource.dart';
import '../../features/journal/data/models/journal_entry_model.dart';
import '../../features/journal/data/repositories/journal_repository_impl.dart';
import '../../features/journal/domain/repositories/journal_repository.dart';
import '../../features/journal/domain/usecases/get_weekly_entries.dart';
import '../../features/journal/domain/usecases/save_journal_entry.dart';
import '../../features/journal/domain/usecases/seed_demo_data.dart';
import '../../features/journal/presentation/bloc/journal_bloc.dart';
import '../utils/constants.dart';

/// Global service-locator instance.
final GetIt sl = GetIt.instance;

/// Initialises Hive, registers all dependencies, and opens storage boxes.
///
/// Call this once before [runApp].
Future<void> initDependencies() async {
  // ── Hive ─────────────────────────────────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryModelAdapter());
  final journalBox =
      await Hive.openBox<JournalEntryModel>(AppConstants.journalBoxName);

  // ── External ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<Box<JournalEntryModel>>(() => journalBox);

  // ── Data sources ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<JournalLocalDataSource>(
    () => JournalLocalDataSourceImpl(box: sl()),
  );

  final aiProvider = dotenv.maybeGet(AppConstants.aiProviderEnv) ??
      AppConstants.providerOpenAi;
  final openAiKey = dotenv.maybeGet(AppConstants.openAiApiKeyEnv) ?? '';
  final claudeKey = dotenv.maybeGet(AppConstants.claudeApiKeyEnv) ?? '';

  sl.registerLazySingleton<InsightsRemoteDataSource>(
    () => InsightsRemoteDataSourceImpl(
      aiProvider: aiProvider,
      openAiApiKey: openAiKey,
      claudeApiKey: claudeKey,
    ),
  );

  // ── Repositories ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<JournalRepository>(
    () => JournalRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<InsightsRepository>(
    () => InsightsRepositoryImpl(remoteDataSource: sl()),
  );

  // ── Use cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => SaveJournalEntry(sl()));
  sl.registerLazySingleton(() => GetWeeklyEntries(sl()));
  sl.registerLazySingleton(() => SeedDemoData(sl()));
  sl.registerLazySingleton(() => GenerateWeeklyInsights(sl()));

  // ── BLoCs (registered as factories so each widget tree gets a fresh instance)
  sl.registerFactory(() => JournalBloc(
        saveJournalEntry: sl(),
        getWeeklyEntries: sl(),
        seedDemoData: sl(),
      ));
  sl.registerFactory(() => InsightsBloc(generateWeeklyInsights: sl()));
}
