import 'package:equatable/equatable.dart';
import '../../domain/entities/journal_entry.dart';

abstract class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the weekly entries should be (re)loaded.
class LoadWeeklyEntries extends JournalEvent {
  const LoadWeeklyEntries();
}

/// Fired when a new or updated [entry] should be saved.
class SaveEntry extends JournalEvent {
  final JournalEntry entry;

  const SaveEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Fired when the user changes slider values in the journal form.
class UpdateDraftField extends JournalEvent {
  final double? racingThoughts;
  final double? suspicion;
  final double? lowMotivation;
  final double? socialWithdrawal;
  final double? sleepHours;
  final double? stressLevel;

  const UpdateDraftField({
    this.racingThoughts,
    this.suspicion,
    this.lowMotivation,
    this.socialWithdrawal,
    this.sleepHours,
    this.stressLevel,
  });

  @override
  List<Object?> get props => [
        racingThoughts,
        suspicion,
        lowMotivation,
        socialWithdrawal,
        sleepHours,
        stressLevel,
      ];
}

/// Fired to reset the draft form to default values.
class ResetDraft extends JournalEvent {
  const ResetDraft();
}
