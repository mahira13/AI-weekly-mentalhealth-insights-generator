import 'package:equatable/equatable.dart';

/// Domain entity holding the AI-generated weekly insights.
class WeeklyInsights extends Equatable {
  const WeeklyInsights({
    required this.patterns,
    required this.positives,
    required this.concerns,
    required this.noteObservations,
    required this.earlyWarning,
    required this.selfCareSuggestion,
    required this.clinicianSummary,
    required this.summary,
  });

  /// Patterns identified across the week's data.
  final String patterns;

  /// Supportive or improving signs across the week.
  final String positives;

  /// Harder or worsening parts of the week.
  final String concerns;

  /// Observations grounded in the user's note text and behavior.
  final String noteObservations;

  /// Early warning flag (empty string if no flag raised).
  final String earlyWarning;

  /// CBT-aligned self-care suggestion.
  final String selfCareSuggestion;

  /// Factual, clinician-friendly summary of the week.
  final String clinicianSummary;

  /// Overall narrative weekly summary.
  final String summary;

  bool get hasEarlyWarning => earlyWarning.trim().isNotEmpty;

  @override
  List<Object?> get props => [
        patterns,
        positives,
        concerns,
        noteObservations,
        earlyWarning,
        selfCareSuggestion,
        clinicianSummary,
        summary,
      ];
}
