import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/constants.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JournalBloc>()..add(const LoadWeeklyEntries()),
      child: const _JournalView(),
    );
  }
}

class _JournalView extends StatelessWidget {
  const _JournalView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Journal'),
        actions: [
          IconButton(
            tooltip: 'Timeline',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push(AppRoutes.timeline),
          ),
          IconButton(
            tooltip: 'AI Insights',
            icon: const Icon(Icons.auto_awesome_rounded),
            onPressed: () => context.push(AppRoutes.insights),
          ),
        ],
      ),
      body: BlocConsumer<JournalBloc, JournalState>(
        listener: (context, state) {
          if (state is JournalLoaded && state.entrySaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Entry saved ✓'),
                backgroundColor: AppTheme.accent,
              ),
            );
          }
          if (state is JournalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: AppTheme.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is JournalLoading || state is JournalInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is JournalLoaded) {
            return _JournalForm(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _JournalForm extends StatelessWidget {
  final JournalLoaded state;

  const _JournalForm({required this.state});

  @override
  Widget build(BuildContext context) {
    final draft = state.draft;
    final bloc = context.read<JournalBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            label: 'Positive Symptoms',
            color: AppTheme.positiveSymptom,
          ),
          const SizedBox(height: 8),
          _SliderTile(
            label: 'Racing Thoughts',
            value: draft.racingThoughts,
            color: AppTheme.positiveSymptom,
            onChanged: (v) =>
                bloc.add(UpdateDraftField(racingThoughts: v)),
          ),
          _SliderTile(
            label: 'Suspicion / Paranoia',
            value: draft.suspicion,
            color: AppTheme.positiveSymptom,
            onChanged: (v) => bloc.add(UpdateDraftField(suspicion: v)),
          ),
          const SizedBox(height: 16),
          _SectionHeader(
            label: 'Negative Symptoms',
            color: AppTheme.negativeSymptom,
          ),
          const SizedBox(height: 8),
          _SliderTile(
            label: 'Low Motivation',
            value: draft.lowMotivation,
            color: AppTheme.negativeSymptom,
            onChanged: (v) =>
                bloc.add(UpdateDraftField(lowMotivation: v)),
          ),
          _SliderTile(
            label: 'Social Withdrawal',
            value: draft.socialWithdrawal,
            color: AppTheme.negativeSymptom,
            onChanged: (v) =>
                bloc.add(UpdateDraftField(socialWithdrawal: v)),
          ),
          const SizedBox(height: 16),
          _SectionHeader(label: 'Sleep & Stress', color: AppTheme.sleepColor),
          const SizedBox(height: 8),
          _SliderTile(
            label: 'Sleep (hours)',
            value: draft.sleepHours,
            color: AppTheme.sleepColor,
            min: 0,
            max: 12,
            onChanged: (v) => bloc.add(UpdateDraftField(sleepHours: v)),
          ),
          _SliderTile(
            label: 'Stress Level',
            value: draft.stressLevel,
            color: AppTheme.stressColor,
            onChanged: (v) => bloc.add(UpdateDraftField(stressLevel: v)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Today\'s Entry'),
              onPressed: () {
                final entry = bloc.buildEntryFromDraft(draft);
                bloc.add(SaveEntry(entry));
              },
            ),
          ),
          const SizedBox(height: 12),
          if (state.weeklyEntries.isNotEmpty) ...[
            const Divider(height: 32),
            Text(
              'This week — ${state.weeklyEntries.length} '
              '${state.weeklyEntries.length == 1 ? 'entry' : 'entries'} logged',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
    this.min = AppConstants.sliderMin,
    this.max = AppConstants.sliderMax,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                thumbColor: color,
                overlayColor: color.withOpacity(0.12),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).toInt() * 2,
                onChanged: onChanged,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  min.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                Text(
                  max.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
