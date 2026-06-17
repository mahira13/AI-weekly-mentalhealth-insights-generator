import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/journal_entry.dart';

class HomeWeekStrip extends StatelessWidget {
  const HomeWeekStrip({super.key, required this.entries});

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7-Day Overview',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              return _HomeDayCell(
                day: day,
                isToday: _isSameDate(day, today),
                hasEntry: _hasEntryForDate(day),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _hasEntryForDate(DateTime date) {
    return entries.any((entry) => _isSameDate(entry.date, date));
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class _HomeDayCell extends StatelessWidget {
  const _HomeDayCell({
    required this.day,
    required this.isToday,
    required this.hasEntry,
  });

  final DateTime day;
  final bool isToday;
  final bool hasEntry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('EEE').format(day),
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? AppTheme.primary : Colors.transparent,
            border: isToday
                ? null
                : Border.all(
                    color: hasEntry ? AppTheme.accent : AppTheme.border,
                    width: 1.5,
                  ),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isToday ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasEntry ? AppTheme.accent : AppTheme.border,
          ),
        ),
      ],
    );
  }
}
