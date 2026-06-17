import 'package:equatable/equatable.dart';
import '../../domain/entities/journal_entry.dart';
import '../../../../core/error/failures.dart';

/// Encapsulates the mutable draft being edited before saving.
class JournalDraft extends Equatable {
  final double positiveSymptom;
  final double negativeSymptom;
  final double sleepQuality;
  final double stressLevel;
  final double socialEnergy;
  final String note;

  const JournalDraft({
    this.positiveSymptom = 0,
    this.negativeSymptom = 0,
    this.sleepQuality = 5,
    this.stressLevel = 0,
    this.socialEnergy = 5,
    this.note = '',
  });

  JournalDraft copyWith({
    double? positiveSymptom,
    double? negativeSymptom,
    double? sleepQuality,
    double? stressLevel,
    double? socialEnergy,
    String? note,
  }) {
    return JournalDraft(
      positiveSymptom: positiveSymptom ?? this.positiveSymptom,
      negativeSymptom: negativeSymptom ?? this.negativeSymptom,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stressLevel: stressLevel ?? this.stressLevel,
      socialEnergy: socialEnergy ?? this.socialEnergy,
      note: note ?? this.note,
    );
  }

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

// ─────────────────────────────────────────────────────────────────────────────

abstract class JournalState extends Equatable {
  const JournalState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data has been loaded.
class JournalInitial extends JournalState {
  const JournalInitial();
}

/// Weekly entries are being fetched / an entry is being saved.
class JournalLoading extends JournalState {
  const JournalLoading();
}

/// Weekly entries loaded successfully; draft holds the in-progress form.
class JournalLoaded extends JournalState {
  final List<JournalEntry> weeklyEntries;
  final JournalDraft draft;
  final bool entrySaved;

  const JournalLoaded({
    required this.weeklyEntries,
    this.draft = const JournalDraft(),
    this.entrySaved = false,
  });

  JournalLoaded copyWith({
    List<JournalEntry>? weeklyEntries,
    JournalDraft? draft,
    bool? entrySaved,
  }) {
    return JournalLoaded(
      weeklyEntries: weeklyEntries ?? this.weeklyEntries,
      draft: draft ?? this.draft,
      entrySaved: entrySaved ?? this.entrySaved,
    );
  }

  @override
  List<Object?> get props => [weeklyEntries, draft, entrySaved];
}

/// An error occurred during a storage operation.
class JournalError extends JournalState {
  final Failure failure;

  const JournalError(this.failure);

  @override
  List<Object?> get props => [failure];
}
