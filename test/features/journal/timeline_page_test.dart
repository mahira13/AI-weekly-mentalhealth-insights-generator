import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_mental_health_insights/core/theme/app_theme.dart';
import 'package:ai_mental_health_insights/features/journal/domain/entities/journal_entry.dart';
import 'package:ai_mental_health_insights/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:ai_mental_health_insights/features/journal/presentation/bloc/journal_event.dart';
import 'package:ai_mental_health_insights/features/journal/presentation/bloc/journal_state.dart';
import 'package:ai_mental_health_insights/features/journal/presentation/pages/timeline_page.dart';
import 'package:ai_mental_health_insights/core/error/failures.dart';

class _MockJournalBloc extends MockBloc<JournalEvent, JournalState>
    implements JournalBloc {}

void main() {
  late _MockJournalBloc journalBloc;

  JournalEntry buildEntry(String id, DateTime date) {
    return JournalEntry(
      id: id,
      date: date,
      positiveSymptom: 2,
      negativeSymptom: 3,
      sleepQuality: 7,
      stressLevel: 4,
      socialEnergy: 6,
      note: 'sample note',
    );
  }

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,
      home: BlocProvider<JournalBloc>.value(
        value: journalBloc,
        child: const TimelinePage(),
      ),
    );
  }

  setUp(() {
    journalBloc = _MockJournalBloc();
  });

  testWidgets('shows empty state when no weekly entries exist', (tester) async {
    when(() => journalBloc.state).thenReturn(
      const JournalLoaded(weeklyEntries: []),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('Your timeline will appear here once you start logging.'),
        findsOneWidget);
  });

  testWidgets('shows timeline content when entries exist', (tester) async {
    when(() => journalBloc.state).thenReturn(
      JournalLoaded(
        weeklyEntries: [buildEntry('1', DateTime(2026, 6, 18))],
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('A gentle look at your week'), findsOneWidget);
    expect(find.text('How your logs changed across the week'), findsOneWidget);
  });

  testWidgets('shows error message when bloc fails', (tester) async {
    when(() => journalBloc.state).thenReturn(
      const JournalError(CacheFailure('load failed')),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('load failed'), findsOneWidget);
  });
}
