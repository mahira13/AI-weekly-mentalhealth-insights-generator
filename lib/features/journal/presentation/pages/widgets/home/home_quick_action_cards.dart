import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/router/app_router.dart';
import '../../../../../../core/theme/app_theme.dart';

const _insightsMinDays = 3;

class HomeQuickActionCards extends StatelessWidget {
  const HomeQuickActionCards({
    super.key,
    required this.loggedDaysCount,
  });

  final int loggedDaysCount;

  @override
  Widget build(BuildContext context) {
    final insightsUnlocked = loggedDaysCount >= _insightsMinDays;
    final remainingDays = _insightsMinDays - loggedDaysCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _HomeActionCard(
                icon: Icons.auto_awesome_rounded,
                title: 'Weekly Insights',
                subtitle: insightsUnlocked
                    ? 'View AI-powered patterns'
                    : 'Log $remainingDays more '
                        '${remainingDays == 1 ? 'day' : 'days'} to unlock',
                color: AppTheme.primary,
                locked: !insightsUnlocked,
                onTap: insightsUnlocked
                    ? () => context.push(AppRoutes.insights)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HomeActionCard(
                icon: Icons.bar_chart_rounded,
                title: '7-Day Chart',
                subtitle: 'View symptom trends',
                color: AppTheme.accent,
                locked: false,
                onTap: () => context.push(AppRoutes.timeline),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.locked,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool locked;
  final VoidCallback? onTap;

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
            color: locked ? AppTheme.border : color.withValues(alpha: 0.3),
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
                        .withValues(alpha: 0.12),
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
                    color:
                        locked ? AppTheme.textSecondary : AppTheme.textPrimary,
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
