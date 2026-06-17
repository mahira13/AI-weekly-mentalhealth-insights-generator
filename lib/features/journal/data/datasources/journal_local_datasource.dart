import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/journal_entry_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';

/// Contract for local journal storage operations.
abstract class JournalLocalDataSource {
  Future<void> saveEntry(JournalEntryModel model);
  Future<List<JournalEntryModel>> getWeeklyEntries();
  Future<List<JournalEntryModel>> getAllEntries();
  Future<void> deleteEntry(String id);
  Future<void> seedDemoData();
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
      final entries = box.values.where((e) => e.date.isAfter(cutoff)).toList()
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

  @override
  Future<void> seedDemoData() async {
    try {
      const uuid = Uuid();
      final now = DateTime.now();
      final demoEntries = <JournalEntryModel>[
        // Day 1 - 6 days ago: mild symptoms
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 6),
          positiveSymptom: 2.0,
          negativeSymptom: 3.0,
          sleepQuality: 7.0,
          stressLevel: 4.0,
          socialEnergy: 6.0,
          note: 'Feeling okay overall.',
        ),
        // Day 2 - 5 days ago: improving
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 5),
          positiveSymptom: 2.0,
          negativeSymptom: 2.0,
          sleepQuality: 8.0,
          stressLevel: 3.0,
          socialEnergy: 7.0,
          note: 'Slept well, good day.',
        ),
        // Day 3 - 4 days ago: stable
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 4),
          positiveSymptom: 1.0,
          negativeSymptom: 2.0,
          sleepQuality: 7.0,
          stressLevel: 3.0,
          socialEnergy: 7.0,
          note: 'Pretty stable.',
        ),
        // Day 4 - 3 days ago: slight decline
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 3),
          positiveSymptom: 3.0,
          negativeSymptom: 4.0,
          sleepQuality: 5.0,
          stressLevel: 5.0,
          socialEnergy: 5.0,
          note: 'Not great sleep, feeling off.',
        ),
        // Day 5 - 2 days ago: worsening
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 2),
          positiveSymptom: 5.0,
          negativeSymptom: 6.0,
          sleepQuality: 4.0,
          stressLevel: 6.0,
          socialEnergy: 3.0,
          note: 'Rough day, withdrawing.',
        ),
        // Day 6 - yesterday: challenging
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 1),
          positiveSymptom: 6.0,
          negativeSymptom: 7.0,
          sleepQuality: 3.0,
          stressLevel: 7.0,
          socialEnergy: 2.0,
          note: 'Very hard day.',
        ),
        // Day 7 - today: slight improvement
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day),
          positiveSymptom: 4.0,
          negativeSymptom: 5.0,
          sleepQuality: 5.0,
          stressLevel: 5.0,
          socialEnergy: 4.0,
          note: 'A bit better than yesterday.',
        ),
      ];

      for (final entry in demoEntries) {
        await box.put(entry.id, entry);
      }
    } catch (e) {
      throw CacheFailure('Failed to seed demo data: $e');
    }
  }
}
