import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/journal_entry.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';
import 'widgets/home/home_greeting_header.dart';
import 'widgets/home/home_log_today_button.dart';
import 'widgets/home/home_quick_action_cards.dart';
import 'widgets/home/home_seed_demo_data_button.dart';
import 'widgets/home/home_week_strip.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JournalBloc>()..add(const LoadWeeklyEntries()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<JournalBloc, JournalState>(
        builder: (context, state) {
          final entries =
              state is JournalLoaded ? state.weeklyEntries : <JournalEntry>[];
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeGreetingHeader(),
                  const SizedBox(height: 24),
                  HomeWeekStrip(entries: entries),
                  const SizedBox(height: 28),
                  HomeLogTodayButton(entries: entries),
                  const SizedBox(height: 28),
                  HomeQuickActionCards(loggedDaysCount: entries.length),
                  const SizedBox(height: 24),
                  const HomeSeedDemoDataButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
