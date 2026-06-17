import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/router/app_router.dart';
import '../../../../domain/entities/journal_entry.dart';
import '../../../bloc/journal_bloc.dart';
import '../../../bloc/journal_event.dart';

class HomeLogTodayButton extends StatelessWidget {
  const HomeLogTodayButton({
    super.key,
    required this.entries,
  });

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final todayEntry = _todayEntry();
    final hasLoggedToday = todayEntry != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(
          hasLoggedToday ? Icons.check : Icons.edit_note_rounded,
        ),
        label: Text(hasLoggedToday ? 'Edit Today\'s Log' : 'Log Today'),
        onPressed: () {
          final bloc = context.read<JournalBloc>();

          if (todayEntry == null) {
            bloc.add(const ResetDraft());
          } else {
            bloc.add(
              UpdateDraftField(
                positiveSymptom: todayEntry.positiveSymptom,
                negativeSymptom: todayEntry.negativeSymptom,
                sleepQuality: todayEntry.sleepQuality,
                stressLevel: todayEntry.stressLevel,
                socialEnergy: todayEntry.socialEnergy,
                note: todayEntry.note,
              ),
            );
          }

          context.push(AppRoutes.journal);
        },
      ),
    );
  }

  JournalEntry? _todayEntry() {
    final today = DateTime.now();
    for (final entry in entries) {
      if (_isSameDate(entry.date, today)) {
        return entry;
      }
    }
    return null;
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
