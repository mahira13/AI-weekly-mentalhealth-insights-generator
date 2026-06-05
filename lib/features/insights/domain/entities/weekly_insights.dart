import 'package:equatable/equatable.dart';

/// Domain entity holding the AI-generated weekly insights.
class WeeklyInsights extends Equatable {
  /// Patterns identified across the week's data.
  final String patterns;

  /// Early warning flag (empty string if no flag raised).
  final String earlyWarning;

  /// CBT-aligned self-care suggestion.
  final String selfCareSuggestion;

  /// Overall narrative weekly summary.
  final String summary;

  const WeeklyInsights({
    required this.patterns,
    required this.earlyWarning,
    required this.selfCareSuggestion,
    required this.summary,
  });

  bool get hasEarlyWarning => earlyWarning.trim().isNotEmpty;

  @override
  List<Object?> get props =>
      [patterns, earlyWarning, selfCareSuggestion, summary];
}
