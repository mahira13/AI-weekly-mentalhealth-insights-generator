import 'package:hive/hive.dart';

import '../../domain/entities/journal_entry.dart';
import '../../../../core/utils/constants.dart';

part 'journal_entry_model.g.dart';

/// Hive-backed data model for [JournalEntry].
///
/// Run `dart run build_runner build --delete-conflicting-outputs` to generate
/// `journal_entry_model.g.dart` containing the type adapter.
@HiveType(typeId: AppConstants.journalEntryTypeId)
class JournalEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double positiveSymptom;

  @HiveField(3)
  final double negativeSymptom;

  @HiveField(4)
  final double sleepQuality;

  @HiveField(5)
  final double stressLevel;

  @HiveField(6)
  final double socialEnergy;

  @HiveField(7)
  final String note;

  JournalEntryModel({
    required this.id,
    required this.date,
    required this.positiveSymptom,
    required this.negativeSymptom,
    required this.sleepQuality,
    required this.stressLevel,
    required this.socialEnergy,
    this.note = '',
  });

  /// Converts a domain [JournalEntry] to its Hive model counterpart.
  factory JournalEntryModel.fromEntity(JournalEntry entry) {
    return JournalEntryModel(
      id: entry.id,
      date: entry.date,
      positiveSymptom: entry.positiveSymptom,
      negativeSymptom: entry.negativeSymptom,
      sleepQuality: entry.sleepQuality,
      stressLevel: entry.stressLevel,
      socialEnergy: entry.socialEnergy,
      note: entry.note,
    );
  }

  /// Converts this model to the pure domain [JournalEntry] entity.
  JournalEntry toEntity() {
    return JournalEntry(
      id: id,
      date: date,
      positiveSymptom: positiveSymptom,
      negativeSymptom: negativeSymptom,
      sleepQuality: sleepQuality,
      stressLevel: stressLevel,
      socialEnergy: socialEnergy,
      note: note,
    );
  }
}
