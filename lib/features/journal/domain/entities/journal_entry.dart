import 'package:equatable/equatable.dart';

/// Core domain entity representing a single daily journal entry.
///
/// Fields (0–10 scale):
///   - [positiveSymptom]  racing thoughts, paranoia, unusual perceptions
///   - [negativeSymptom]  low motivation, social withdrawal, flat mood
///   - [sleepQuality]     sleep quality from terrible to excellent
///   - [stressLevel]      overall tension and pressure
///   - [socialEnergy]     desire and ability to connect socially
///   - [note]             optional free-text note
class JournalEntry extends Equatable {
  final String id;
  final DateTime date;
  final double positiveSymptom;
  final double negativeSymptom;
  final double sleepQuality;
  final double stressLevel;
  final double socialEnergy;
  final String note;

  const JournalEntry({
    required this.id,
    required this.date,
    required this.positiveSymptom,
    required this.negativeSymptom,
    required this.sleepQuality,
    required this.stressLevel,
    required this.socialEnergy,
    this.note = '',
  });

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    double? positiveSymptom,
    double? negativeSymptom,
    double? sleepQuality,
    double? stressLevel,
    double? socialEnergy,
    String? note,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
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
        id,
        date,
        positiveSymptom,
        negativeSymptom,
        sleepQuality,
        stressLevel,
        socialEnergy,
        note,
      ];
}
