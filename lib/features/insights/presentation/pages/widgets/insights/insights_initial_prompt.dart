import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';

class InsightsInitialPrompt extends StatelessWidget {
  const InsightsInitialPrompt({
    required this.entryCount,
    required this.onGenerate,
    super.key,
  });

  final int entryCount;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final hasEntries = entryCount > 0;

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
              'Private Weekly Insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              hasEntries
                  ? 'Generate a calm weekly reflection from your last 7 days of journal data. The analysis stays on this device using a local Gemma model for privacy and offline use.'
                  : 'Add at least one journal entry this week, then generate a private on-device reflection with the local Gemma model.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'First-time model download: about 284 MB',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '$entryCount of 7 recent entries available',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.psychology_alt_rounded),
              label: const Text('Generate Offline Insights'),
              onPressed: hasEntries ? onGenerate : null,
            ),
          ],
        ),
      ),
    );
  }
}
