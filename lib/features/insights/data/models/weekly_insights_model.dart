import 'dart:convert';

import '../../../journal/domain/entities/journal_entry.dart';
import '../../domain/entities/weekly_insights.dart';

/// Plain data model for AI-response deserialization.
class WeeklyInsightsModel {
  const WeeklyInsightsModel({
    required this.patterns,
    required this.positives,
    required this.concerns,
    required this.noteObservations,
    required this.earlyWarning,
    required this.selfCareSuggestion,
    required this.clinicianSummary,
    required this.summary,
  });

  const WeeklyInsightsModel.empty()
      : patterns = '',
        positives = '',
        concerns = '',
        noteObservations = '',
        earlyWarning = '',
        selfCareSuggestion = '',
        clinicianSummary = '',
        summary = '';

  /// Parses the structured JSON returned by the AI model.
  ///
  /// Expected shape:
  /// ```json
  /// {
  ///   "patterns": "...",
  ///   "positives": "...",
  ///   "concerns": "...",
  ///   "note_observations": "...",
  ///   "early_warning": "...",
  ///   "self_care_suggestion": "...",
  ///   "clinician_summary": "...",
  ///   "summary": "..."
  /// }
  /// ```
  factory WeeklyInsightsModel.fromJson(Map<String, dynamic> json) {
    return WeeklyInsightsModel(
      patterns: _coerceText(json['patterns']),
      positives: _coerceText(json['positives']),
      concerns: _coerceText(json['concerns']),
      noteObservations: _coerceText(json['note_observations']),
      earlyWarning: _coerceText(json['early_warning']),
      selfCareSuggestion: _coerceText(json['self_care_suggestion']),
      clinicianSummary: _coerceText(json['clinician_summary']),
      summary: _coerceText(json['summary']),
    );
  }

  factory WeeklyInsightsModel.fromRawResponse(String content) {
    final normalized = content
        .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\bcall\b', caseSensitive: false), ' ')
        .trim();

    final decoded = _decodeJsonPayload(normalized);

    return WeeklyInsightsModel.fromJson(_extractInsightMap(decoded));
  }

  final String patterns;
  final String positives;
  final String concerns;
  final String noteObservations;
  final String earlyWarning;
  final String selfCareSuggestion;
  final String clinicianSummary;
  final String summary;

  static Object? _decodeJsonPayload(String content) {
    for (final candidate in _payloadCandidates(content)) {
      try {
        return jsonDecode(candidate);
      } on FormatException {
        continue;
      }
    }

    throw const FormatException('Could not locate valid JSON in model output.');
  }

  static Iterable<String> _payloadCandidates(String content) sync* {
    if (content.isNotEmpty) {
      yield content;
    }

    final arrayStart = content.indexOf('[');
    final arrayEnd = content.lastIndexOf(']');
    if (arrayStart >= 0 && arrayEnd > arrayStart) {
      yield content.substring(arrayStart, arrayEnd + 1);
    }

    final objectStart = content.indexOf('{');
    final objectEnd = content.lastIndexOf('}');
    if (objectStart >= 0 && objectEnd > objectStart) {
      yield content.substring(objectStart, objectEnd + 1);
    }
  }

  static Map<String, dynamic> _extractInsightMap(Object? decoded) {
    if (decoded is Map<String, dynamic>) {
      if (_hasExpectedInsightKeys(decoded)) {
        return decoded;
      }

      for (final key in const [
        'arguments',
        'args',
        'input',
        'payload',
        'data'
      ]) {
        final nested = decoded[key];
        if (nested != null) {
          return _extractInsightMap(nested);
        }
      }
    }

    if (decoded is List) {
      for (final item in decoded) {
        try {
          return _extractInsightMap(item);
        } on FormatException {
          continue;
        }
      }
    }

    throw const FormatException(
      'Model output did not contain the expected weekly insights JSON object.',
    );
  }

  static bool _hasExpectedInsightKeys(Map<String, dynamic> json) {
    return json.containsKey('patterns') ||
        json.containsKey('positives') ||
        json.containsKey('concerns') ||
        json.containsKey('note_observations') ||
        json.containsKey('early_warning') ||
        json.containsKey('self_care_suggestion') ||
        json.containsKey('clinician_summary') ||
        json.containsKey('summary');
  }

  static String _coerceText(Object? value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    if (value is num || value is bool) {
      return value.toString();
    }

    if (value is List) {
      final parts = value
          .map(_coerceText)
          .where((part) => part.isNotEmpty)
          .toList(growable: false);
      return parts.join(' ');
    }

    if (value is Map) {
      final content = [
        value['text'],
        value['content'],
        value['summary'],
        value['value'],
        value['message'],
      ]
          .map(_coerceText)
          .where((part) => part.isNotEmpty)
          .toList(growable: false);

      if (content.isNotEmpty) {
        return content.join(' ');
      }

      return value.values
          .map(_coerceText)
          .where((part) => part.isNotEmpty)
          .join(' ');
    }

    return value.toString().trim();
  }

  WeeklyInsights toEntity() {
    return WeeklyInsights(
      patterns: patterns,
      positives: positives,
      concerns: concerns,
      noteObservations: noteObservations,
      earlyWarning: earlyWarning,
      selfCareSuggestion: selfCareSuggestion,
      clinicianSummary: clinicianSummary,
      summary: summary,
    );
  }

  /// Builds the prompt payload sent to the AI.
  static String buildPrompt(List<JournalEntry> entries) {
    final buffer = StringBuffer()
      ..writeln(
        'Analyze this 7-day mental health journal and write the response in '
        'warm, human, natural language. Ground the analysis in the body '
        'signals the user logged - especially sleep, stress, and social '
        'energy - and connect those signals to the note text. Be specific '
        'about what seemed to support better days, what made days harder, and '
        'what stands out across the week. Do not diagnose. Do not sound '
        'alarmist. Do not quote raw numeric scores in the response.\n\n'
        'Return JSON only with exactly these keys:\n'
        '{\n'
        '  "summary": "A short personal narrative of 3-4 sentences written like a compassionate observer summarizing the user\'s week",\n'
        '  "positives": "2-3 short sentences naming what consistently correlated with better days in a personal, non-generic way",\n'
        '  "patterns": "2-4 sentences connecting body signals such as sleep, stress, and social energy to the flow of the week",\n'
        '  "note_observations": "2-4 sentences using the note text to describe behaviour, coping, context, avoidance, connection, or lived experience",\n'
        '  "concerns": "2-3 sentences on what felt heavier, more fragile, or more difficult this week",\n'
        '  "early_warning": "1-2 gentle sentences on anything worth noticing next week, or an empty string if nothing specific stands out",\n'
        '  "self_care_suggestion": "1-2 personalized supportive sentences based on what seemed to help on better days",\n'
        '  "clinician_summary": "2-4 sentences a doctor could read quickly to understand the overall week and behaviour without raw scores"\n'
        '}\n\n'
        'Section rules:\n'
        '- summary: give the overall story only.\n'
        '- positives: focus only on what supported steadier days.\n'
        '- patterns: focus only on links between sleep, stress, social energy, and symptoms.\n'
        '- note_observations: focus only on what the written notes reveal that the scores alone would miss.\n'
        '- concerns: focus only on what made the week harder or more fragile.\n'
        '- clinician_summary: write a factual handoff, not a duplicate of summary.\n'
        '- Never reuse the same sentence or phrasing across two keys.\n'
        '- Never echo raw input labels like positive symptoms, negative symptoms, sleep, stress, social energy, or Note.\n\n'
        'Requirements:\n'
        '- Use all available fields, including note text.\n'
        '- Distinguish what was good, what was difficult, and what may need attention.\n'
        '- Write in short compassionate paragraphs, not bullets.\n'
        '- Do not quote raw numbers or copy the input values into the output.\n'
        '- Do not diagnose or claim certainty.\n'
        '- Do not use generic advice unless it clearly fits the week\'s data.\n'
        '- If no clear early warning sign is present, set "early_warning" to an empty string.\n\n'
        'Daily entries:\n',
      );

    for (final e in entries) {
      final note = _compactNote(e.note);
      buffer.writeln(
        '${e.date.toIso8601String().substring(0, 10)}: '
        'positive symptoms ${_symptomLevel(e.positiveSymptom)}, '
        'negative symptoms ${_symptomLevel(e.negativeSymptom)}, '
        'sleep ${_wellbeingLevel(e.sleepQuality)}, '
        'stress ${_stressLevel(e.stressLevel)}, '
        'social energy ${_wellbeingLevel(e.socialEnergy)}. '
        'Note: $note',
      );
    }

    return buffer.toString();
  }

  static String _symptomLevel(double value) {
    if (value <= 2) {
      return 'low';
    }
    if (value <= 4) {
      return 'mild';
    }
    if (value <= 6) {
      return 'moderate';
    }
    if (value <= 8) {
      return 'high';
    }
    return 'very high';
  }

  static String _stressLevel(double value) {
    if (value <= 2) {
      return 'low';
    }
    if (value <= 4) {
      return 'fairly settled';
    }
    if (value <= 6) {
      return 'elevated';
    }
    if (value <= 8) {
      return 'high';
    }
    return 'very high';
  }

  static String _wellbeingLevel(double value) {
    if (value <= 2) {
      return 'very low';
    }
    if (value <= 4) {
      return 'low';
    }
    if (value <= 6) {
      return 'mixed';
    }
    if (value <= 8) {
      return 'fairly steady';
    }
    return 'strong';
  }

  static String _compactNote(String note) {
    final normalized = note.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return 'none';
    }

    const maxLength = 120;
    if (normalized.length <= maxLength) {
      return normalized;
    }

    return '${normalized.substring(0, maxLength - 1)}…';
  }
}
