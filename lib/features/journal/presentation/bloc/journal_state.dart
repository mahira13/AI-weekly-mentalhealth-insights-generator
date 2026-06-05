import 'package:equatable/equatable.dart';
import '../../domain/entities/journal_entry.dart';
import '../../../../core/error/failures.dart';

/// Encapsulates the mutable draft being edited before saving.
class JournalDraft extends Equatable {
  final double racingThoughts;
  final double suspicion;
  final double lowMotivation;
  final double socialWithdrawal;
  final double sleepHours;
  final double stressLevel;

  const JournalDraft({
    this.racingThoughts = 0,
    this.suspicion = 0,
    this.lowMotivation = 0,
    this.socialWithdrawal = 0,
    this.sleepHours = 7,
    this.stressLevel = 0,
  });

  JournalDraft copyWith({
    double? racingThoughts,
    double? suspicion,
    double? lowMotivation,
    double? socialWithdrawal,
    double? sleepHours,
    double? stressLevel,
  }) {
    return JournalDraft(
      racingThoughts: racingThoughts ?? this.racingThoughts,
      suspicion: suspicion ?? this.suspicion,
      lowMotivation: lowMotivation ?? this.lowMotivation,
      socialWithdrawal: socialWithdrawal ?? this.socialWithdrawal,
      sleepHours: sleepHours ?? this.sleepHours,
      stressLevel: stressLevel ?? this.stressLevel,
    );
  }

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
