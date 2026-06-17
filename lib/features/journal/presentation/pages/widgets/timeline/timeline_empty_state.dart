import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';

class TimelineEmptyState extends StatelessWidget {
  const TimelineEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 44,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Your timeline will appear here once you start logging.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'There is no pressure to fill every day. This view is here to help you notice patterns gently over time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
