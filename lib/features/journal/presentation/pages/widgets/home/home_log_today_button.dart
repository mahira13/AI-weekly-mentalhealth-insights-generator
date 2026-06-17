import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/router/app_router.dart';

class HomeLogTodayButton extends StatelessWidget {
  const HomeLogTodayButton({super.key});

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
