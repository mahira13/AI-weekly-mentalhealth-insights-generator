import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/journal_entry.dart';

class TimelineEntryList extends StatelessWidget {
  const TimelineEntryList({
    super.key,
    required this.entries,
  });

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final sortedEntries = [...entries]..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily entries',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 6),
        const Text(
          'A quick recap of each logged day, with your note if you added one.',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...sortedEntries.map((entry) => _TimelineEntryCard(entry: entry)),
      ],
    );
  }
}

class _TimelineEntryCard extends StatelessWidget {
  const _TimelineEntryCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMM d').format(entry.date),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricPill(
                label: 'Positive',
                value: entry.positiveSymptom.toStringAsFixed(1),
                color: AppTheme.positiveSymptom,
              ),
              _MetricPill(
                label: 'Negative',
                value: entry.negativeSymptom.toStringAsFixed(1),
                color: AppTheme.negativeSymptom,
              ),
              _MetricPill(
                label: 'Sleep',
                value: entry.sleepQuality.toStringAsFixed(1),
                color: AppTheme.sleepColor,
              ),
              _MetricPill(
                label: 'Stress',
                value: entry.stressLevel.toStringAsFixed(1),
                color: AppTheme.stressColor,
              ),
              _MetricPill(
                label: 'Social',
                value: entry.socialEnergy.toStringAsFixed(1),
                color: AppTheme.socialColor,
              ),
            ],
          ),
          if (entry.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              entry.note,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}