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
  const JournalLocalDataSourceImpl({required this.box});

  final Box<JournalEntryModel> box;

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
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day),
          positiveSymptom: 9.0,
          negativeSymptom: 2.0,
          sleepQuality: 1.0,
          stressLevel: 10.0,
          socialEnergy: 1.0,
          note:
              'Terrible night. Heard knocking sounds that weren\'t there and at one point clearly heard someone say my name right next to my ear. Shot up out of bed, checked every room. Nothing. Smoked half a pack between midnight and 4am just sitting in the kitchen with the lights on. Called in sick to work.',
        ),
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 1),
          positiveSymptom: 3.0,
          negativeSymptom: 7.0,
          sleepQuality: 7.0,
          stressLevel: 4.0,
          socialEnergy: 5.0,
          note:
              'Slept better than usual which made a real difference. Met Lena for coffee in the afternoon, first time seeing her in weeks. Didn\'t tell her what\'s been going on but it was good to just sit with someone. Came home tired but in a quieter way, not the anxious kind.',
        ),
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 2),
          positiveSymptom: 9.0,
          negativeSymptom: 3.0,
          sleepQuality: 2.0,
          stressLevel: 9.0,
          socialEnergy: 2.0,
          note:
              'Strong feeling all day that my phone is being monitored. Deleted some apps and then felt stupid about it but couldn\'t shake the feeling. Went outside for groceries and had to turn back twice because it felt like someone was following me. Ended up ordering delivery instead. Smoked a lot.',
        ),
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 3),
          positiveSymptom: 5.0,
          negativeSymptom: 4.0,
          sleepQuality: 6.0,
          stressLevel: 5.0,
          socialEnergy: 6.0,
          note:
              'Went for a longer walk today, almost 30 minutes. Put headphones in which helped block out the noise and made me feel less exposed. Bumped into my neighbor and had a short conversation, actually felt okay during it. Small things but they added up to a decent day overall.',
        ),
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 4),
          positiveSymptom: 2.0,
          negativeSymptom: 8.0,
          sleepQuality: 7.0,
          stressLevel: 3.0,
          socialEnergy: 2.0,
          note:
              'Quiet day. No hallucinations, no paranoia, which should feel good but I mostly just felt empty. Didn\'t respond to any messages. Made tea, sat by the window for a long time not thinking about anything in particular. Some days the absence of symptoms just feels like a different kind of nothing.',
        ),
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 5),
          positiveSymptom: 9.0,
          negativeSymptom: 3.0,
          sleepQuality: 2.0,
          stressLevel: 10.0,
          socialEnergy: 1.0,
          note:
              'One of the worst nights in a while. Voices were clearer than usual, two of them, felt like they were commenting on everything I did. Turned the TV on loud to drown them out. Smoked constantly. Didn\'t sleep until 6am. Can\'t tell my family how bad it gets sometimes, they\'d panic.',
        ),
        JournalEntryModel(
          id: uuid.v4(),
          date: DateTime(now.year, now.month, now.day - 6),
          positiveSymptom: 5.0,
          negativeSymptom: 5.0,
          sleepQuality: 5.0,
          stressLevel: 6.0,
          socialEnergy: 5.0,
          note:
              'Two weeks of tracking now. Looking back at these entries is strange, like reading about someone else even though it was all me. Some patterns I can already see — bad nights lead to bad mornings, getting outside helps even when it\'s hard, talking to someone always makes it a little more bearable. Trying to hold onto that.',
        ),
      ];

      await box.clear();

      for (final entry in demoEntries) {
        await box.put(entry.id, entry);
      }
    } catch (e) {
      throw CacheFailure('Failed to seed demo data: $e');
    }
  }
}
