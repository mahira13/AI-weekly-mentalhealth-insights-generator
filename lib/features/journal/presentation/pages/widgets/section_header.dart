import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 2),
        Text(subtitle,
            style:
                const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
      ],
    );
  }
}
