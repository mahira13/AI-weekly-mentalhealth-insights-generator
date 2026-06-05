import 'package:hive/hive.dart';

import '../../domain/entities/journal_entry.dart';
import '../../../../core/utils/constants.dart';

part 'journal_entry_model.g.dart';

/// Hive-backed data model for [JournalEntry].
///
/// Run `flutter pub run build_runner build` to generate
/// `journal_entry_model.g.dart` containing the type adapter.
@HiveType(typeId: AppConstants.journalEntryTypeId)
class JournalEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double racingThoughts;

  @HiveField(3)
  final double suspicion;

  @HiveField(4)
  final double lowMotivation;

  @HiveField(5)
  final double socialWithdrawal;

  @HiveField(6)
  final double sleepHours;

  @HiveField(7)
  final double stressLevel;

  JournalEntryModel({
    required this.id,
    required this.date,
    required this.racingThoughts,
    required this.suspicion,
    required this.lowMotivation,
    required this.socialWithdrawal,
    required this.sleepHours,
    required this.stressLevel,
  });

  /// Converts a domain [JournalEntry] to its Hive model counterpart.
  factory JournalEntryModel.fromEntity(JournalEntry entry) {
    return JournalEntryModel(
      id: entry.id,
      date: entry.date,
      racingThoughts: entry.racingThoughts,
      suspicion: entry.suspicion,
      lowMotivation: entry.lowMotivation,
      socialWithdrawal: entry.socialWithdrawal,
      sleepHours: entry.sleepHours,
      stressLevel: entry.stressLevel,
    );
  }

  /// Converts this model to the pure domain [JournalEntry] entity.
  JournalEntry toEntity() {
    return JournalEntry(
      id: id,
      date: date,
      racingThoughts: racingThoughts,
      suspicion: suspicion,
      lowMotivation: lowMotivation,
      socialWithdrawal: socialWithdrawal,
      sleepHours: sleepHours,
      stressLevel: stressLevel,
    );
  }
}
