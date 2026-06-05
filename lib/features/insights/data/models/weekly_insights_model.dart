import '../../../journal/domain/entities/journal_entry.dart';
import '../../domain/entities/weekly_insights.dart';

/// Plain data model for AI-response deserialization.
class WeeklyInsightsModel {
  final String patterns;
  final String earlyWarning;
  final String selfCareSuggestion;
  final String summary;

  const WeeklyInsightsModel({
    required this.patterns,
    required this.earlyWarning,
    required this.selfCareSuggestion,
    required this.summary,
  });

  /// Parses the structured JSON returned by the AI model.
  ///
  /// Expected shape:
  /// ```json
  /// {
  ///   "patterns": "...",
  ///   "early_warning": "...",
  ///   "self_care_suggestion": "...",
  ///   "summary": "..."
  /// }
  /// ```
  factory WeeklyInsightsModel.fromJson(Map<String, dynamic> json) {
    return WeeklyInsightsModel(
      patterns: json['patterns'] as String? ?? '',
      earlyWarning: json['early_warning'] as String? ?? '',
      selfCareSuggestion: json['self_care_suggestion'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
    );
  }

  WeeklyInsights toEntity() {
    return WeeklyInsights(
      patterns: patterns,
      earlyWarning: earlyWarning,
      selfCareSuggestion: selfCareSuggestion,
      summary: summary,
    );
  }

  /// Builds the prompt payload sent to the AI.
  static String buildPrompt(List<JournalEntry> entries) {
    final buffer = StringBuffer()
      ..writeln(
        'You are a compassionate mental health support assistant. '
        'Analyse the following 7-day symptom journal data and return '
        'a JSON object with exactly these four keys:\n'
        '  "patterns"             – a concise bullet describing recurring patterns\n'
        '  "early_warning"        – one early-warning flag if concerning trends are '
        'present, or an empty string if none\n'
        '  "self_care_suggestion" – one CBT-aligned self-care recommendation\n'
        '  "summary"              – a 2–3 sentence warm weekly narrative\n\n'
        'Respond ONLY with valid JSON. No markdown fences.\n\n'
        'Journal data (scale 0–10 unless noted):\n',
      );

    for (final e in entries) {
      buffer.writeln(
        '- ${e.date.toIso8601String().substring(0, 10)}: '
        'racingThoughts=${e.racingThoughts}, '
        'suspicion=${e.suspicion}, '
        'lowMotivation=${e.lowMotivation}, '
        'socialWithdrawal=${e.socialWithdrawal}, '
        'sleepHours=${e.sleepHours}, '
        'stressLevel=${e.stressLevel}',
      );
    }

    return buffer.toString();
  }
}
