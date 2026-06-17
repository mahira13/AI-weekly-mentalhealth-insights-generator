import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_theme.dart';
import 'timeline_models.dart';

class TimelineSummaryCard extends StatelessWidget {
  const TimelineSummaryCard({
    super.key,
    required this.summary,
  });

  final TimelineSummaryData summary;

  @override
  Widget build(BuildContext context) {
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
            'A gentle look at your week',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Missing days stay visible as gaps so the chart stays honest and easy to understand. This is about noticing patterns, not aiming for perfection.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SummaryChip(
                label: 'Days logged',
                value: '${summary.loggedDaysCount}/7',
                color: AppTheme.primary,
              ),
              _SummaryChip(
                label: 'Latest check-in',
                value: DateFormat('EEE').format(summary.latestCheckInDate),
                color: AppTheme.accent,
              ),
              _SummaryChip(
                label: 'Latest stress',
                value: summary.latestStressLevel.toStringAsFixed(1),
                color: AppTheme.stressColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
