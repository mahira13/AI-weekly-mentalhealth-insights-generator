import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../journal/domain/entities/journal_entry.dart';
import '../../../journal/presentation/bloc/journal_bloc.dart';
import '../../../journal/presentation/bloc/journal_event.dart';
import '../../../journal/presentation/bloc/journal_state.dart';
import '../../data/services/pdf_export_service.dart';
import '../../domain/entities/weekly_insights.dart';
import '../bloc/insights_bloc.dart';
import '../bloc/insights_event.dart';
import '../bloc/insights_state.dart';
import 'widgets/insights/insights_error_view.dart';
import 'widgets/insights/insights_initial_prompt.dart';
import 'widgets/insights/insights_loading_view.dart';
import 'widgets/insights/insights_result_view.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InsightsBloc>(),
      child: const _InsightsView(),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView();

  @override
  Widget build(BuildContext context) {
    final journalState = context.watch<JournalBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Weekly Insights'),
        actions: [
          if (journalState is JournalLoaded)
            BlocBuilder<InsightsBloc, InsightsState>(
              builder: (context, state) {
                if (state is InsightsLoaded) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.ios_share_rounded),
                        tooltip: 'Share PDF',
                        onPressed: () => _shareInsights(
                          context,
                          insights: state.insights,
                          entries: journalState.weeklyEntries,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'Re-generate',
                        onPressed: () => _generateInsights(
                          context,
                          journalState.weeklyEntries,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      body: switch (journalState) {
        JournalInitial() || JournalLoading() => const InsightsLoadingView(
            message: 'Preparing your journal data…',
          ),
        JournalError(failure: final failure) => InsightsErrorView(
            message: failure.message,
            onRetry: () =>
                context.read<JournalBloc>().add(const LoadWeeklyEntries()),
          ),
        JournalLoaded(weeklyEntries: final weeklyEntries) =>
          BlocBuilder<InsightsBloc, InsightsState>(
            builder: (context, state) {
              return switch (state) {
                InsightsInitial() => InsightsInitialPrompt(
                    entryCount: weeklyEntries.length,
                    onGenerate: () => _generateInsights(context, weeklyEntries),
                  ),
                InsightsLoading() => const InsightsLoadingView(
                    message: 'Analysing your week privately on this device…',
                  ),
                InsightsLoaded(insights: final insights) =>
                  InsightsResultView(insights: insights),
                InsightsError(failure: final failure) => InsightsErrorView(
                    message: failure.message,
                    onRetry: () => _generateInsights(context, weeklyEntries),
                  ),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  void _generateInsights(BuildContext context, List<JournalEntry> entries) {
    context.read<InsightsBloc>().add(GenerateInsights(entries));
  }

  Future<void> _shareInsights(
    BuildContext context, {
    required WeeklyInsights insights,
    required List<JournalEntry> entries,
  }) async {
    await sl<PdfExportService>().generateAndShare(
      dateRange: _dateRange(entries),
      narrative: insights.summary,
      anchors: _anchorsFor(insights),
      timelineEntries: entries,
    );
  }

  List<String> _anchorsFor(WeeklyInsights insights) {
    return [
      insights.positives,
      insights.patterns,
      insights.noteObservations,
      insights.concerns,
      if (insights.hasEarlyWarning) insights.earlyWarning,
      insights.selfCareSuggestion,
    ];
  }

  String _dateRange(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return 'Weekly Insights';
    }

    final sortedEntries = [...entries]
      ..sort((left, right) => left.date.compareTo(right.date));
    final formatter = DateFormat('MMM d, yyyy');
    final start = formatter.format(sortedEntries.first.date);
    final end = formatter.format(sortedEntries.last.date);
    return '$start - $end';
  }
}
