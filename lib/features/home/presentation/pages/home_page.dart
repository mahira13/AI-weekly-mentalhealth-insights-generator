import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../journal/domain/entities/journal_entry.dart';
import '../../../journal/presentation/bloc/journal_bloc.dart';
import '../../../journal/presentation/bloc/journal_event.dart';
import '../../../journal/presentation/bloc/journal_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JournalBloc>()..add(const LoadWeeklyEntries()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<JournalBloc, JournalState>(
        builder: (context, state) {
          final entries = state is JournalLoaded ? state.weeklyEntries : <JournalEntry>[];
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GreetingHeader(),
                  const SizedBox(height: 24),
                  _WeekStrip(entries: entries),
                  const SizedBox(height: 28),
                  _LogTodayButton(),
                  const SizedBox(height: 28),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionCards(loggedDaysCount: entries.length),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMMM d').format(now),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  final List<JournalEntry> entries;

  const _WeekStrip({required this.entries});

  bool _hasEntryForDate(DateTime date) {
    return entries.any(
      (e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

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
              final isToday =
                  day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              final hasEntry = _hasEntryForDate(day);
              return _DayCell(
                day: day,
                isToday: isToday,
                hasEntry: hasEntry,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final bool hasEntry;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.hasEntry,
  });

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

// ─────────────────────────────────────────────────────────────────────────────

class _LogTodayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Log Today'),
        onPressed: () => context.push(AppRoutes.journal),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionCards extends StatelessWidget {
  final int loggedDaysCount;

  const _QuickActionCards({required this.loggedDaysCount});

  static const int _insightsMinDays = 3;

  @override
  Widget build(BuildContext context) {
    final insightsUnlocked = loggedDaysCount >= _insightsMinDays;

    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Weekly Insights',
            subtitle: insightsUnlocked
                ? 'View AI-powered patterns'
                : 'Log ${_insightsMinDays - loggedDaysCount} more '
                    '${(_insightsMinDays - loggedDaysCount) == 1 ? 'day' : 'days'} to unlock',
            color: AppTheme.primary,
            locked: !insightsUnlocked,
            onTap: insightsUnlocked
                ? () => context.push(AppRoutes.insights)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.bar_chart_rounded,
            title: '7-Day Chart',
            subtitle: 'View symptom trends',
            color: AppTheme.accent,
            locked: false,
            onTap: () => context.push(AppRoutes.timeline),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool locked;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: locked ? AppTheme.border : color.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (locked ? AppTheme.textSecondary : color)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: locked ? AppTheme.textSecondary : color,
                    size: 22,
                  ),
                ),
                if (locked)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.cardBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: locked ? AppTheme.textSecondary : AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
