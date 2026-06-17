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
  final double? positiveSymptom;
  final double? negativeSymptom;
  final double? sleepQuality;
  final double? stressLevel;
  final double? socialEnergy;
  final String? note;

  const UpdateDraftField({
    this.positiveSymptom,
    this.negativeSymptom,
    this.sleepQuality,
    this.stressLevel,
    this.socialEnergy,
    this.note,
  });

  @override
  List<Object?> get props => [
        positiveSymptom,
        negativeSymptom,
        sleepQuality,
        stressLevel,
        socialEnergy,
        note,
      ];
}

/// Fired to reset the draft form to default values.
class ResetDraft extends JournalEvent {
  const ResetDraft();
}
