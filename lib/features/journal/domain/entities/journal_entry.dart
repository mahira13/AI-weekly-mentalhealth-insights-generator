import 'package:equatable/equatable.dart';

/// Core domain entity representing a single daily journal entry.
///
/// Positive symptoms (elevated = clinically concerning):
///   - [racingThoughts]  0–10
///   - [suspicion]       0–10
///
/// Negative symptoms (elevated = reduced functioning):
///   - [lowMotivation]      0–10
///   - [socialWithdrawal]   0–10
///
/// General wellbeing:
///   - [sleepHours]   0–12 (hours of sleep last night)
///   - [stressLevel]  0–10
class JournalEntry extends Equatable {
  final String id;
  final DateTime date;

  // Positive symptoms
  final double racingThoughts;
  final double suspicion;

  // Negative symptoms
  final double lowMotivation;
  final double socialWithdrawal;

  // General wellbeing
  final double sleepHours;
  final double stressLevel;

  const JournalEntry({
    required this.id,
    required this.date,
    required this.racingThoughts,
    required this.suspicion,
    required this.lowMotivation,
    required this.socialWithdrawal,
    required this.sleepHours,
    required this.stressLevel,
  });

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    double? racingThoughts,
    double? suspicion,
    double? lowMotivation,
    double? socialWithdrawal,
    double? sleepHours,
    double? stressLevel,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
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
        id,
        date,
        racingThoughts,
        suspicion,
        lowMotivation,
        socialWithdrawal,
        sleepHours,
        stressLevel,
      ];
}
