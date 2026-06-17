import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../bloc/journal_bloc.dart';
import '../../../bloc/journal_event.dart';

class HomeSeedDemoDataButton extends StatelessWidget {
  const HomeSeedDemoDataButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.science_outlined, size: 18),
        label: const Text('Seed 7 days of demo data'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textSecondary,
          side: const BorderSide(color: AppTheme.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onPressed: () {
          context.read<JournalBloc>().add(const SeedDemoData());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('7 days of demo data seeded - insights ready!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
