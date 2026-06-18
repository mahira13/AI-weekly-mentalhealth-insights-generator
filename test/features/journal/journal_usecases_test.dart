import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_mental_health_insights/features/journal/domain/entities/journal_entry.dart';
import 'package:ai_mental_health_insights/features/journal/domain/repositories/journal_repository.dart';
import 'package:ai_mental_health_insights/features/journal/domain/usecases/get_weekly_entries.dart';
import 'package:ai_mental_health_insights/features/journal/domain/usecases/save_journal_entry.dart';

class _MockJournalRepository extends Mock implements JournalRepository {}

class _FakeJournalEntry extends Fake implements JournalEntry {}

void main() {
  late _MockJournalRepository mockRepo;
  late GetWeeklyEntries getWeeklyEntries;
  late SaveJournalEntry saveJournalEntry;

  final testDate = DateTime(2024, 6, 1);
  final entry = JournalEntry(
    id: 'id-1',
    date: testDate,
    positiveSymptom: 2.0,
    negativeSymptom: 3.0,
    sleepQuality: 7.0,
    stressLevel: 4.0,
    socialEnergy: 6.0,
    note: 'Felt more social today',
  );

  setUpAll(() {
    registerFallbackValue(_FakeJournalEntry());
  });

  setUp(() {
    mockRepo = _MockJournalRepository();
    getWeeklyEntries = GetWeeklyEntries(mockRepo);
    saveJournalEntry = SaveJournalEntry(mockRepo);
  });

  group('GetWeeklyEntries', () {
    test('calls repository.getWeeklyEntries and returns entries', () async {
      when(() => mockRepo.getWeeklyEntries()).thenAnswer((_) async => [entry]);

      final result = await getWeeklyEntries();

      expect(result, [entry]);
      verify(() => mockRepo.getWeeklyEntries()).called(1);
    });
  });

  group('SaveJournalEntry', () {
    test('calls repository.saveEntry with the given entry', () async {
      when(() => mockRepo.saveEntry(any())).thenAnswer((_) async {});

      await saveJournalEntry(entry);

      verify(() => mockRepo.saveEntry(entry)).called(1);
    });
  });
}
