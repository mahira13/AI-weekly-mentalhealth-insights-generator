import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';
import 'widgets/journal_form.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JournalBloc>()..add(const LoadWeeklyEntries()),
      child: const _JournalView(),
    );
  }
}

class _JournalView extends StatelessWidget {
  const _JournalView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Journal'),
      ),
      body: BlocBuilder<JournalBloc, JournalState>(
        builder: (context, state) {
          if (state is JournalLoading || state is JournalInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is JournalLoaded) {
            return JournalForm(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocConsumer<JournalBloc, JournalState>(
        listener: (context, state) {
          if (state is JournalLoaded && state.entrySaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Entry saved ✓'),
                backgroundColor: AppTheme.accent,
                duration: Duration(seconds: 2),
              ),
            );
            // Navigate to home after saving
            context.go(AppRoutes.home);
          }
          if (state is JournalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: AppTheme.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! JournalLoaded) {
            return const SizedBox.shrink();
          }

          final bloc = context.read<JournalBloc>();
          final draft = state.draft;

          return 
                  Container(
                    width: double.infinity,
                 margin: const EdgeInsets.all(24),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Today\'s Entry'),
                      onPressed: state is JournalLoading
                          ? null
                          : () {
                              final entry = bloc.buildEntryFromDraft(draft);
                              bloc.add(SaveEntry(entry));
                            },
                    ),
                  
             
          );
        },
      ),
    );
  }
}
