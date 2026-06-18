import 'package:flutter/material.dart';

import '../../../../domain/entities/weekly_insights.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'insight_card.dart';

class InsightsResultView extends StatelessWidget {
  const InsightsResultView({required this.insights, super.key});

  final WeeklyInsights insights;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InsightCard(
            icon: Icons.auto_stories_rounded,
            color: AppTheme.primary,
            title: 'Your Week In Words',
            body: insights.summary,
          ),
          const SizedBox(height: 12),
          InsightCard(
            icon: Icons.thumb_up_alt_rounded,
            color: AppTheme.accent,
            title: 'What Helped On Better Days',
            body: insights.positives,
          ),
          const SizedBox(height: 12),
          InsightCard(
            icon: Icons.favorite_outline_rounded,
            color: AppTheme.primary,
            title: 'Body Signals Through The Week',
            body: insights.patterns,
          ),
          const SizedBox(height: 12),
          InsightCard(
            icon: Icons.menu_book_rounded,
            color: AppTheme.primary,
            title: 'What The Notes Added',
            body: insights.noteObservations,
          ),
          const SizedBox(height: 12),
          InsightCard(
            icon: Icons.trending_down_rounded,
            color: AppTheme.warning,
            title: 'What Felt Harder',
            body: insights.concerns,
          ),
          const SizedBox(height: 12),
          if (insights.hasEarlyWarning)
            InsightCard(
              icon: Icons.warning_amber_rounded,
              color: AppTheme.warning,
              title: 'What To Notice Next',
              body: insights.earlyWarning,
            ),
          if (insights.hasEarlyWarning) const SizedBox(height: 12),
          InsightCard(
            icon: Icons.self_improvement_rounded,
            color: AppTheme.accent,
            title: 'A Gentle Next Step',
            body: insights.selfCareSuggestion,
          ),
          const SizedBox(height: 12),
          InsightCard(
            icon: Icons.local_hospital_rounded,
            color: AppTheme.textPrimary,
            title: 'Clinician Glance',
            body: insights.clinicianSummary,
          ),
        ],
      ),
    );
  }
}
