import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/journal_entry.dart';
import 'timeline_models.dart';

class TimelineChartSection extends StatefulWidget {
  const TimelineChartSection({
    super.key,
    required this.weekSlots,
  });

  final List<TimelineDaySlot> weekSlots;

  @override
  State<TimelineChartSection> createState() => _TimelineChartSectionState();
}

class _TimelineChartSectionState extends State<TimelineChartSection> {
  int _selectedMetricIndex = 0;

  static final List<_TimelineMetric> _metrics = [
    const _TimelineMetric(
      label: 'All',
      description:
          'See the full week at once. Choose a single metric below if you want a calmer, simpler view.',
      color: AppTheme.primary,
    ),
    _TimelineMetric(
      label: 'Positive',
      description:
          'Higher values can point to a more difficult day for racing thoughts or unusual perceptions.',
      color: AppTheme.positiveSymptom,
      valueOf: (entry) => entry.positiveSymptom,
    ),
    _TimelineMetric(
      label: 'Negative',
      description:
          'Higher values can reflect lower motivation, more withdrawal, or a flatter mood.',
      color: AppTheme.negativeSymptom,
      valueOf: (entry) => entry.negativeSymptom,
    ),
    _TimelineMetric(
      label: 'Sleep',
      description:
          'Higher values mean a harder sleep-related day. Sleep quality is inverted here so the chart reads in one direction.',
      color: AppTheme.sleepColor,
      valueOf: (entry) => 10 - entry.sleepQuality,
    ),
    _TimelineMetric(
      label: 'Stress',
      description: 'Higher values mean more stress or pressure during the day.',
      color: AppTheme.stressColor,
      valueOf: (entry) => entry.stressLevel,
    ),
    _TimelineMetric(
      label: 'Social',
      description:
          'Higher values mean a harder social-energy day. Social energy is inverted here so dips are easier to notice.',
      color: AppTheme.socialColor,
      valueOf: (entry) => 10 - entry.socialEnergy,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedMetric = _metrics[_selectedMetricIndex];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How your logs changed across the week',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedMetric.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _MetricFilterRow(
            metrics: _metrics,
            selectedMetricIndex: _selectedMetricIndex,
            onSelected: (index) {
              setState(() => _selectedMetricIndex = index);
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 230,
            child: LineChart(
                _buildChartData(selectedMetricIndex: _selectedMetricIndex)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Higher lines mean a harder day. Blank spaces simply mean no log for that day.',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          if (_selectedMetricIndex == 0) _AllMetricsLegend(metrics: _metrics),
        ],
      ),
    );
  }

  LineChartData _buildChartData({required int selectedMetricIndex}) {
    return LineChartData(
      minY: 0,
      maxY: 10,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: AppTheme.border, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
            reservedSize: 28,
            getTitlesWidget: (value, _) => Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final index = value.toInt();
              if (index < 0 || index >= widget.weekSlots.length) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  DateFormat('EEE').format(widget.weekSlots[index].date),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppTheme.textPrimary,
        ),
      ),
      lineBarsData: _lineBarsFor(selectedMetricIndex),
    );
  }

  List<LineChartBarData> _lineBarsFor(int selectedMetricIndex) {
    if (selectedMetricIndex == 0) {
      return [
        _buildLine(
          color: AppTheme.positiveSymptom,
          valueOf: (entry) => entry.positiveSymptom,
        ),
        _buildLine(
          color: AppTheme.negativeSymptom,
          valueOf: (entry) => entry.negativeSymptom,
        ),
        _buildLine(
          color: AppTheme.sleepColor,
          valueOf: (entry) => entry.sleepQuality,
        ),
        _buildLine(
          color: AppTheme.stressColor,
          valueOf: (entry) => entry.stressLevel,
        ),
        _buildLine(
          color: AppTheme.socialColor,
          valueOf: (entry) => entry.socialEnergy,
        ),
      ];
    }

    final selectedMetric = _metrics[selectedMetricIndex];
    return [
      _buildLine(
        color: selectedMetric.color,
        valueOf: selectedMetric.valueOf!,
        emphasize: true,
      ),
    ];
  }

  LineChartBarData _buildLine({
    required Color color,
    required double Function(JournalEntry entry) valueOf,
    bool emphasize = false,
  }) {
    final spots = widget.weekSlots.asMap().entries.map((entry) {
      final journalEntry = entry.value.entry;
      if (journalEntry == null) {
        return FlSpot.nullSpot;
      }

      return FlSpot(entry.key.toDouble(), valueOf(journalEntry));
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.32,
      color: color,
      barWidth: emphasize ? 3.5 : 2.4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
          radius: emphasize ? 4.5 : 3.5,
          color: color,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
        show: emphasize,
        color: color.withValues(alpha: 0.10),
      ),
    );
  }
}

class _MetricFilterRow extends StatelessWidget {
  const _MetricFilterRow({
    required this.metrics,
    required this.selectedMetricIndex,
    required this.onSelected,
  });

  final List<_TimelineMetric> metrics;
  final int selectedMetricIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(metrics.length, (index) {
          final metric = metrics[index];
          final isSelected = selectedMetricIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(metric.label),
              selected: isSelected,
              onSelected: (_) => onSelected(index),
              backgroundColor: Colors.transparent,
              selectedColor: metric.color.withValues(alpha: 0.14),
              side: BorderSide(
                color: isSelected ? metric.color : AppTheme.border,
              ),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? metric.color : AppTheme.textSecondary,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AllMetricsLegend extends StatelessWidget {
  const _AllMetricsLegend({required this.metrics});

  final List<_TimelineMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final visibleMetrics = metrics.skip(1).toList();

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: visibleMetrics.map((metric) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: metric.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              metric.label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _TimelineMetric {
  const _TimelineMetric({
    required this.label,
    required this.description,
    required this.color,
    this.valueOf,
  });

  final String label;
  final String description;
  final Color color;
  final double Function(JournalEntry entry)? valueOf;
}
