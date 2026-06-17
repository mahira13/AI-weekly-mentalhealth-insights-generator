import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_state.dart';
import 'widgets/timeline/timeline_content.dart';
import 'widgets/timeline/timeline_empty_state.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TimelineView();
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('7-Day Timeline')),
      body: BlocBuilder<JournalBloc, JournalState>(
        builder: (context, state) {
          if (state is JournalLoading || state is JournalInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is JournalLoaded) {
            if (state.weeklyEntries.isEmpty) {
              return const TimelineEmptyState();
            }
            return TimelineContent(entries: state.weeklyEntries);
          }
          if (state is JournalError) {
            return Center(
              child: Text(
                state.failure.message,
                style: const TextStyle(color: AppTheme.danger),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
