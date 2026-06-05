import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/journal_entry.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JournalBloc>()..add(const LoadWeeklyEntries()),
      child: const _TimelineView(),
    );
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('7-Day Timeline')),
      body: BlocBuilder<JournalBloc, JournalState>(
        builder: (context, state) {
          if (state is JournalLoading || state is JournalInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is JournalLoaded) {
            if (state.weeklyEntries.isEmpty) {
              return const Center(
                child: Text(
                  'No entries yet.\nStart journaling to see your timeline.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              );
            }
            return _TimelineChart(entries: state.weeklyEntries);
          }
          if (state is JournalError) {
            return Center(
              child: Text(
                state.failure.message,
                style: const TextStyle(color: AppTheme.danger),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TimelineChart extends StatelessWidget {
  final List<JournalEntry> entries;

  const _TimelineChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegendRow(),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: _LineChartWidget(entries: entries),
          ),
          const SizedBox(height: 24),
          _EntryList(entries: entries),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      _LegendItem('Racing Thoughts', AppTheme.positiveSymptom),
      _LegendItem('Suspicion', AppTheme.danger),
      _LegendItem('Low Motivation', AppTheme.negativeSymptom),
      _LegendItem('Social Withdrawal', AppTheme.socialColor),
      _LegendItem('Sleep (h)', AppTheme.sleepColor),
      _LegendItem('Stress', AppTheme.stressColor),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _LegendItem {
  final String label;
  final Color color;

  const _LegendItem(this.label, this.color);
}

// ─────────────────────────────────────────────────────────────────────────────

class _LineChartWidget extends StatelessWidget {
  final List<JournalEntry> entries;

  const _LineChartWidget({required this.entries});

  LineChartBarData _line(
    List<FlSpot> spots,
    Color color, {
    bool dashed = false,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: true),
      dashArray: dashed ? [4, 4] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

    List<FlSpot> toSpots(double Function(JournalEntry) fn) {
      return sorted
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), fn(e.value)))
          .toList();
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 12,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppTheme.border, strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              const FlLine(color: AppTheme.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
              reservedSize: 28,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= sorted.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('EEE').format(sorted[idx].date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: AppTheme.border),
            bottom: BorderSide(color: AppTheme.border),
          ),
        ),
        lineBarsData: [
          _line(
            toSpots((e) => e.racingThoughts),
            AppTheme.positiveSymptom,
          ),
          _line(toSpots((e) => e.suspicion), AppTheme.danger),
          _line(
            toSpots((e) => e.lowMotivation),
            AppTheme.negativeSymptom,
          ),
          _line(
            toSpots((e) => e.socialWithdrawal),
            AppTheme.socialColor,
            dashed: true,
          ),
          _line(toSpots((e) => e.sleepHours), AppTheme.sleepColor),
          _line(toSpots((e) => e.stressLevel), AppTheme.stressColor),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EntryList extends StatelessWidget {
  final List<JournalEntry> entries;

  const _EntryList({required this.entries});

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Entries',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        ...sorted.map((e) => _EntryCard(entry: e)),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  final JournalEntry entry;

  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(entry.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _Chip(
                  'RT: ${entry.racingThoughts.toStringAsFixed(1)}',
                  AppTheme.positiveSymptom,
                ),
                _Chip(
                  'Sus: ${entry.suspicion.toStringAsFixed(1)}',
                  AppTheme.danger,
                ),
                _Chip(
                  'Mot: ${entry.lowMotivation.toStringAsFixed(1)}',
                  AppTheme.negativeSymptom,
                ),
                _Chip(
                  'SW: ${entry.socialWithdrawal.toStringAsFixed(1)}',
                  AppTheme.socialColor,
                ),
                _Chip(
                  'Sleep: ${entry.sleepHours.toStringAsFixed(1)}h',
                  AppTheme.sleepColor,
                ),
                _Chip(
                  'Stress: ${entry.stressLevel.toStringAsFixed(1)}',
                  AppTheme.stressColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
