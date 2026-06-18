import '../../../journal/domain/entities/journal_entry.dart';
import '../models/weekly_insights_model.dart';

class WeeklyInsightsRefiner {
  const WeeklyInsightsRefiner._();

  static WeeklyInsightsModel refine({
    required WeeklyInsightsModel draft,
    required List<JournalEntry> entries,
  }) {
    if (entries.isEmpty) {
      return draft;
    }

    final snapshot = _WeekSnapshot(entries);
    final fallback = _FallbackInsights.fromSnapshot(snapshot);
    final chosen = <String, String>{};

    String pick({
      required String key,
      required String candidate,
      required String fallbackValue,
      required int minWords,
      bool allowEmpty = false,
    }) {
      final normalized = _normalize(candidate);
      if (allowEmpty && normalized.isEmpty) {
        return '';
      }

      final shouldReplace = normalized.isEmpty ||
          _looksEchoed(normalized) ||
          _wordCount(normalized) < minWords ||
          chosen.values
              .any((existing) => _similarity(normalized, existing) >= 0.62);

      final value = shouldReplace ? fallbackValue : normalized;
      chosen[key] = value;
      return value;
    }

    return WeeklyInsightsModel(
      summary: pick(
        key: 'summary',
        candidate: draft.summary,
        fallbackValue: fallback.summary,
        minWords: 18,
      ),
      positives: pick(
        key: 'positives',
        candidate: draft.positives,
        fallbackValue: fallback.positives,
        minWords: 14,
      ),
      patterns: pick(
        key: 'patterns',
        candidate: draft.patterns,
        fallbackValue: fallback.patterns,
        minWords: 16,
      ),
      concerns: pick(
        key: 'concerns',
        candidate: draft.concerns,
        fallbackValue: fallback.concerns,
        minWords: 12,
      ),
      noteObservations: pick(
        key: 'note_observations',
        candidate: draft.noteObservations,
        fallbackValue: fallback.noteObservations,
        minWords: 14,
      ),
      earlyWarning: pick(
        key: 'early_warning',
        candidate: draft.earlyWarning,
        fallbackValue: fallback.earlyWarning,
        minWords: 8,
        allowEmpty: true,
      ),
      selfCareSuggestion: pick(
        key: 'self_care_suggestion',
        candidate: draft.selfCareSuggestion,
        fallbackValue: fallback.selfCareSuggestion,
        minWords: 10,
      ),
      clinicianSummary: pick(
        key: 'clinician_summary',
        candidate: draft.clinicianSummary,
        fallbackValue: fallback.clinicianSummary,
        minWords: 16,
      ),
    );
  }

  static bool _looksEchoed(String text) {
    const echoedFragments = [
      'positive symptoms',
      'negative symptoms',
      'social energy',
      'two weeks of tracking',
      'reading about someone else',
      'note:',
    ];

    final mixedCount = RegExp(r'\bmixed\b').allMatches(text).length;
    return mixedCount >= 2 || echoedFragments.where(text.contains).length >= 2;
  }

  static int _wordCount(String text) {
    return text
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .length;
  }

  static double _similarity(String left, String right) {
    final leftTokens = _keywords(left);
    final rightTokens = _keywords(right);
    if (leftTokens.isEmpty || rightTokens.isEmpty) {
      return 0;
    }

    final overlap = leftTokens.intersection(rightTokens).length;
    final union = leftTokens.union(rightTokens).length;
    if (union == 0) {
      return 0;
    }

    return overlap / union;
  }

  static Set<String> _keywords(String text) {
    const stopWords = {
      'about',
      'across',
      'after',
      'also',
      'and',
      'felt',
      'from',
      'have',
      'into',
      'more',
      'some',
      'than',
      'that',
      'the',
      'their',
      'there',
      'these',
      'this',
      'what',
      'when',
      'with',
      'week',
      'were',
      'your',
    };

    return text
        .split(RegExp(r'[^a-z0-9]+'))
        .where((word) => word.length > 3 && !stopWords.contains(word))
        .toSet();
  }

  static String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class _FallbackInsights {
  const _FallbackInsights({
    required this.summary,
    required this.positives,
    required this.patterns,
    required this.concerns,
    required this.noteObservations,
    required this.earlyWarning,
    required this.selfCareSuggestion,
    required this.clinicianSummary,
  });

  factory _FallbackInsights.fromSnapshot(_WeekSnapshot snapshot) {
    final summary = [
      snapshot.overallTone,
      'The steadiest point came ${snapshot.dayPhrase(snapshot.bestEntry.date)} '
          'when ${snapshot.bestDayDrivers}.',
      'The harder stretch showed up ${snapshot.dayPhrase(snapshot.hardestEntry.date)} '
          'when ${snapshot.hardDayDrivers}.',
    ].join(' ');

    final positives = [
      'Better days tended to line up with ${snapshot.supportPattern}.',
      if (snapshot.bestNoteSnippet.isNotEmpty)
        'The steadier note about ${snapshot.bestNoteSnippet} points in the '
            'same direction.',
    ].join(' ');

    final patterns = [
      snapshot.sleepTrend,
      snapshot.stressTrend,
      snapshot.socialTrend,
      snapshot.symptomTrend,
    ].join(' ');

    final concerns = [
      'The tougher part of the week centered on ${snapshot.strainPattern}.',
      if (snapshot.hardestNoteSnippet.isNotEmpty)
        'The note about ${snapshot.hardestNoteSnippet} adds context to why '
            'that stretch may have felt heavier.',
    ].join(' ');

    final noteObservations = snapshot.noteObservations;

    final selfCareSuggestion = [
      'A useful next step may be to ${snapshot.selfCareFocus}.',
      if (snapshot.secondaryCareFocus.isNotEmpty) snapshot.secondaryCareFocus,
    ].join(' ');

    final clinicianSummary = [
      'Across the week, functioning shifted most clearly with '
          '${snapshot.clinicianPattern}.',
      'Better days aligned with ${snapshot.supportPattern}, while harder '
          'days aligned with ${snapshot.strainPattern}.',
      if (snapshot.noteContext.isNotEmpty)
        'Notes added context around ${snapshot.noteContext}.',
    ].join(' ');

    return _FallbackInsights(
      summary: summary,
      positives: positives,
      patterns: patterns,
      concerns: concerns,
      noteObservations: noteObservations,
      earlyWarning: snapshot.earlyWarning,
      selfCareSuggestion: selfCareSuggestion,
      clinicianSummary: clinicianSummary,
    );
  }

  final String summary;
  final String positives;
  final String patterns;
  final String concerns;
  final String noteObservations;
  final String earlyWarning;
  final String selfCareSuggestion;
  final String clinicianSummary;
}

class _WeekSnapshot {
  _WeekSnapshot(List<JournalEntry> source)
      : entries = [...source]
          ..sort((left, right) => left.date.compareTo(right.date));

  final List<JournalEntry> entries;

  JournalEntry get bestEntry => entries.reduce(
        (left, right) => _dayScore(left) >= _dayScore(right) ? left : right,
      );

  JournalEntry get hardestEntry => entries.reduce(
        (left, right) => _dayScore(left) <= _dayScore(right) ? left : right,
      );

  String get overallTone {
    final avgStress = _average((entry) => entry.stressLevel);
    final avgSleep = _average((entry) => entry.sleepQuality);
    if (avgStress >= 6.5 || avgSleep <= 4.5) {
      return 'The week looked heavy overall, with strain showing up often enough to shape the tone of the week.';
    }
    if (avgStress <= 4.5 && avgSleep >= 6) {
      return 'The week looked relatively steady, with a few clear signs of stability to build on.';
    }
    return 'The week was mixed, but the harder and steadier moments followed patterns rather than feeling random.';
  }

  String get bestDayDrivers => _joinParts([
        if (bestEntry.sleepQuality >= 6) 'sleep felt more restorative',
        if (bestEntry.stressLevel <= 4.5) 'stress eased',
        if (bestEntry.socialEnergy >= 6) 'social energy was easier to access',
        if (bestNoteSnippet.isNotEmpty) 'the note mentioned $bestNoteSnippet',
      ], fallback: 'the overall load looked lighter');

  String get hardDayDrivers => _joinParts([
        if (hardestEntry.sleepQuality <= 4.5) 'sleep looked reduced',
        if (hardestEntry.stressLevel >= 6) 'stress was more elevated',
        if (hardestEntry.socialEnergy <= 4.5)
          'connection looked harder to reach',
        if (hardestNoteSnippet.isNotEmpty)
          'the note mentioned $hardestNoteSnippet',
      ], fallback: 'several strain signals landed together');

  String get supportPattern => _joinParts([
        if (_average((entry) => entry.sleepQuality) >= 5.5) 'better sleep',
        if (_average((entry) => entry.stressLevel) <= 5.3) 'lower stress',
        if (_average((entry) => entry.socialEnergy) >= 5.5)
          'more available social energy',
        if (bestNoteSnippet.isNotEmpty)
          'days that looked more like $bestNoteSnippet',
      ], fallback: 'lighter days with fewer competing demands');

  String get strainPattern => _joinParts([
        if (_average((entry) => entry.sleepQuality) <= 5) 'poorer sleep',
        if (_average((entry) => entry.stressLevel) >= 5.8) 'higher stress',
        if (_average((entry) => entry.socialEnergy) <= 5) 'lower social energy',
        if (hardestNoteSnippet.isNotEmpty)
          'days that looked more like $hardestNoteSnippet',
      ], fallback: 'several stress signals arriving together');

  String get sleepTrend => _trendSentence(
        label: 'Sleep',
        earlier: _segmentAverage((entry) => entry.sleepQuality, true),
        later: _segmentAverage((entry) => entry.sleepQuality, false),
        betterWhenHigher: true,
        stableText: 'Sleep stayed in a similar range across the week.',
      );

  String get stressTrend => _trendSentence(
        label: 'Stress',
        earlier: _segmentAverage((entry) => entry.stressLevel, true),
        later: _segmentAverage((entry) => entry.stressLevel, false),
        betterWhenHigher: false,
        stableText: 'Stress stayed in a similar range across the week.',
      );

  String get socialTrend => _trendSentence(
        label: 'Social energy',
        earlier: _segmentAverage((entry) => entry.socialEnergy, true),
        later: _segmentAverage((entry) => entry.socialEnergy, false),
        betterWhenHigher: true,
        stableText:
            'Social energy did not shift sharply, but it still mattered when it dipped.',
      );

  String get symptomTrend {
    final avgPositive = _average((entry) => entry.positiveSymptom);
    final avgNegative = _average((entry) => entry.negativeSymptom);
    if (avgPositive >= 6 && avgNegative >= 6) {
      return 'Both activation-type symptoms and low-energy symptoms were active enough to make the week feel uneven.';
    }
    if (avgNegative >= 6) {
      return 'Low-energy and withdrawal-type symptoms carried more of the weekly load than the activated symptoms.';
    }
    if (avgPositive >= 6) {
      return 'The more activated symptoms were louder than the low-energy symptoms this week.';
    }
    return 'Neither symptom cluster completely dominated, but both looked sensitive to sleep and stress changes.';
  }

  String get noteObservations {
    final notes = _noteSnippets;
    if (notes.isEmpty) {
      return 'There were few written notes this week, so the clearest story came from the body-signal patterns rather than extra context.';
    }

    final parts = <String>[
      'The notes added lived context beyond the numeric check-ins.',
      'One note mentioned ${notes.first}, and that helps explain how the week was being experienced from the inside.',
    ];

    if (notes.length > 1) {
      parts.add(
          'Later in the week, another note mentioned ${notes[1]}, which fits with the shift in strain.');
    }

    parts.add(
        'Taken together, the writing suggests ${noteContext.isEmpty ? 'meaningful day-to-day context' : noteContext}.');
    return parts.join(' ');
  }

  String get earlyWarning {
    final poorSleepCluster =
        entries.where((entry) => entry.sleepQuality <= 4.5).length >= 2;
    final highStressCluster =
        entries.where((entry) => entry.stressLevel >= 6.5).length >= 2;
    final lateWeekDrop = entries.length >= 2 &&
        entries.skip(entries.length - 2).every(
              (entry) => entry.sleepQuality <= 5 || entry.stressLevel >= 6,
            );

    if (poorSleepCluster && highStressCluster || lateWeekDrop) {
      return 'It may be worth noticing early if poorer sleep starts to line up with rising stress or more withdrawal again, because that combination matched the tougher stretch this week.';
    }

    return '';
  }

  String get selfCareFocus {
    if (_average((entry) => entry.sleepQuality) <= 5) {
      return 'protect one calmer wind-down routine before the nights that already look vulnerable';
    }
    if (_average((entry) => entry.socialEnergy) <= 5) {
      return 'plan one low-pressure point of contact before the week gets too heavy';
    }
    return 'repeat the conditions that made the steadier day feel more manageable';
  }

  String get secondaryCareFocus {
    if (_average((entry) => entry.stressLevel) >= 6) {
      return 'A short decompression break before the most stressful part of the day may help keep strain from stacking up.';
    }
    return '';
  }

  String get clinicianPattern => _joinParts([
        if (_average((entry) => entry.sleepQuality) <= 5) 'reduced sleep',
        if (_average((entry) => entry.stressLevel) >= 5.8) 'elevated stress',
        if (_average((entry) => entry.socialEnergy) <= 5)
          'reduced social energy',
      ], fallback: 'changes in sleep, stress, and social energy together');

  String get noteContext {
    final text = entries.map((entry) => entry.note.toLowerCase()).join(' ');
    if (_containsAny(text, ['friend', 'family', 'talk', 'called', 'coffee'])) {
      return 'how connection and contact shaped the week';
    }
    if (_containsAny(text, ['work', 'deadline', 'busy', 'study', 'exam'])) {
      return 'how pressure and daily demands spilled into the harder days';
    }
    if (_containsAny(text, ['alone', 'avoid', 'isolat', 'message'])) {
      return 'how withdrawal and reduced engagement showed up in the difficult stretch';
    }
    return '';
  }

  String get bestNoteSnippet => _quote(_cleanNote(bestEntry.note));

  String get hardestNoteSnippet => _quote(_cleanNote(hardestEntry.note));

  List<String> get _noteSnippets => entries
      .map((entry) => _quote(_cleanNote(entry.note)))
      .where((note) => note.isNotEmpty)
      .take(2)
      .toList(growable: false);

  String dayPhrase(DateTime date) {
    const labels = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return 'on ${labels[date.weekday - 1]}';
  }

  double _average(double Function(JournalEntry entry) selector) {
    final values = entries.map(selector).toList(growable: false);
    return values.reduce((left, right) => left + right) / values.length;
  }

  double _segmentAverage(
      double Function(JournalEntry entry) selector, bool firstHalf) {
    final split = (entries.length / 2).ceil();
    final segment = firstHalf ? entries.take(split) : entries.skip(split);
    final values = segment.map(selector).toList(growable: false);
    if (values.isEmpty) {
      return _average(selector);
    }
    return values.reduce((left, right) => left + right) / values.length;
  }

  String _trendSentence({
    required String label,
    required double earlier,
    required double later,
    required bool betterWhenHigher,
    required String stableText,
  }) {
    final delta = later - earlier;
    if (delta.abs() < 0.8) {
      return stableText;
    }

    final movedTowardHarderStretch = betterWhenHigher ? delta < 0 : delta > 0;
    final direction = delta > 0 ? 'rose' : 'fell';
    if (movedTowardHarderStretch) {
      return '$label $direction later in the week, which matched the harder stretch.';
    }
    return '$label $direction later in the week, which matched the steadier stretch.';
  }

  static double _dayScore(JournalEntry entry) {
    return entry.sleepQuality +
        entry.socialEnergy -
        entry.stressLevel -
        entry.positiveSymptom -
        entry.negativeSymptom;
  }

  static String _quote(String text) {
    if (text.isEmpty) {
      return '';
    }

    const maxLength = 56;
    final value = text.length <= maxLength
        ? text
        : '${text.substring(0, maxLength - 1).trim()}…';
    return '"$value"';
  }

  static String _cleanNote(String note) {
    return note.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _containsAny(String text, List<String> fragments) {
    return fragments.any(text.contains);
  }

  static String _joinParts(List<String> parts, {required String fallback}) {
    final filtered =
        parts.where((part) => part.isNotEmpty).toList(growable: false);
    if (filtered.isEmpty) {
      return fallback;
    }
    if (filtered.length == 1) {
      return filtered.first;
    }
    if (filtered.length == 2) {
      return '${filtered.first} and ${filtered.last}';
    }
    return '${filtered.sublist(0, filtered.length - 1).join(', ')}, and ${filtered.last}';
  }
}
