import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../journal/domain/entities/journal_entry.dart';
import '../../../journal/domain/usecases/get_weekly_entries.dart';
import '../../domain/entities/weekly_insights.dart';
import '../bloc/insights_bloc.dart';
import '../bloc/insights_event.dart';
import '../bloc/insights_state.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Weekly Insights'),
        actions: [
          BlocBuilder<InsightsBloc, InsightsState>(
            builder: (context, state) {
              if (state is InsightsLoaded) {
                return IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Re-generate',
                  onPressed: () => _generateInsights(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<InsightsBloc, InsightsState>(
        builder: (context, state) {
          return switch (state) {
            InsightsInitial() => _InitialPrompt(
                onGenerate: () => _generateInsights(context),
              ),
            InsightsLoading() => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Analysing your week…',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            InsightsLoaded(insights: final insights) =>
              _InsightsResult(insights: insights),
            InsightsError(failure: final failure) => _ErrorView(
                message: failure.message,
                onRetry: () => _generateInsights(context),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Future<void> _generateInsights(BuildContext context) async {
    final getWeeklyEntries = sl<GetWeeklyEntries>();
    List<JournalEntry> entries;
    try {
      entries = await getWeeklyEntries();
    } catch (_) {
      entries = [];
    }
    if (context.mounted) {
      context.read<InsightsBloc>().add(GenerateInsights(entries));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InitialPrompt extends StatelessWidget {
  final VoidCallback onGenerate;

  const _InitialPrompt({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 64,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Weekly AI Insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap below to send your last 7 days of journal data '
              'to the AI and receive personalised patterns, an early '
              'warning flag, and a CBT-aligned self-care suggestion.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded),
              label: const Text('Generate Insights'),
              onPressed: onGenerate,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InsightsResult extends StatelessWidget {
  final WeeklyInsights insights;

  const _InsightsResult({required this.insights});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InsightCard(
            icon: Icons.insights_rounded,
            color: AppTheme.primary,
            title: 'Patterns This Week',
            body: insights.patterns,
          ),
          const SizedBox(height: 12),
          if (insights.hasEarlyWarning)
            _InsightCard(
              icon: Icons.warning_amber_rounded,
              color: AppTheme.warning,
              title: 'Early Warning Flag',
              body: insights.earlyWarning,
            ),
          if (insights.hasEarlyWarning) const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.self_improvement_rounded,
            color: AppTheme.accent,
            title: 'Self-Care Suggestion',
            body: insights.selfCareSuggestion,
          ),
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.summarize_rounded,
            color: AppTheme.textSecondary,
            title: 'Weekly Summary',
            body: insights.summary,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _InsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.danger,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
