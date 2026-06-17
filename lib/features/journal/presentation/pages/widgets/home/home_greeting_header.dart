import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_theme.dart';

class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greetingFor(now),
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

  String _greetingFor(DateTime now) {
    if (now.hour < 12) {
      return 'Good morning';
    }
    if (now.hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }
}
