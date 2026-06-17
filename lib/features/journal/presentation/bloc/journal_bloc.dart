import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/journal_entry.dart';
import '../../domain/usecases/get_weekly_entries.dart';
import '../../domain/usecases/save_journal_entry.dart';
import '../../domain/usecases/seed_demo_data.dart' as usecases;
import '../../../../core/error/failures.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final SaveJournalEntry saveJournalEntry;
  final GetWeeklyEntries getWeeklyEntries;
  final usecases.SeedDemoData seedDemoData;

  static const _uuid = Uuid();

  JournalBloc({
    required this.saveJournalEntry,
    required this.getWeeklyEntries,
    required this.seedDemoData,
  }) : super(const JournalInitial()) {
    on<LoadWeeklyEntries>(_onLoadWeeklyEntries);
    on<SaveEntry>(_onSaveEntry);
    on<UpdateDraftField>(_onUpdateDraftField);
    on<ResetDraft>(_onResetDraft);
    on<SeedDemoData>(_onSeedDemoData);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onLoadWeeklyEntries(
    LoadWeeklyEntries event,
    Emitter<JournalState> emit,
  ) async {
    emit(const JournalLoading());
    try {
      final entries = await getWeeklyEntries();
      emit(JournalLoaded(weeklyEntries: entries));
    } on CacheFailure catch (f) {
      emit(JournalError(f));
    } catch (e) {
      emit(JournalError(CacheFailure(e.toString())));
    }
  }

  Future<void> _onSaveEntry(
    SaveEntry event,
    Emitter<JournalState> emit,
  ) async {
    final current = state;
    if (current is! JournalLoaded) return;

    emit(const JournalLoading());
    try {
      await saveJournalEntry(event.entry);
      final updated = await getWeeklyEntries();
      emit(JournalLoaded(
        weeklyEntries: updated,
        draft: const JournalDraft(),
        entrySaved: true,
      ));
    } on CacheFailure catch (f) {
      emit(JournalError(f));
    } catch (e) {
      emit(JournalError(CacheFailure(e.toString())));
    }
  }

  void _onUpdateDraftField(
    UpdateDraftField event,
    Emitter<JournalState> emit,
  ) {
    final current = state;
    if (current is! JournalLoaded) return;

    final updated = current.draft.copyWith(
      positiveSymptom: event.positiveSymptom,
      negativeSymptom: event.negativeSymptom,
      sleepQuality: event.sleepQuality,
      stressLevel: event.stressLevel,
      socialEnergy: event.socialEnergy,
      note: event.note,
    );
    emit(current.copyWith(draft: updated, entrySaved: false));
  }

  void _onResetDraft(ResetDraft event, Emitter<JournalState> emit) {
    final current = state;
    if (current is! JournalLoaded) return;
    emit(current.copyWith(draft: const JournalDraft(), entrySaved: false));
  }

  Future<void> _onSeedDemoData(
    SeedDemoData event,
    Emitter<JournalState> emit,
  ) async {
    final current = state;
    if (current is! JournalLoaded) return;

    emit(const JournalLoading());
    try {
      await seedDemoData();
      final updated = await getWeeklyEntries();
      emit(JournalLoaded(weeklyEntries: updated));
    } on CacheFailure catch (f) {
      emit(JournalError(f));
    } catch (e) {
      emit(JournalError(CacheFailure(e.toString())));
    }
  }

  /// Convenience method to build a [JournalEntry] from the current draft.
  JournalEntry buildEntryFromDraft(JournalDraft draft) {
    final current = state;
    final today = DateTime.now();
    JournalEntry? existingTodayEntry;

    if (current is JournalLoaded) {
      for (final entry in current.weeklyEntries) {
        if (_isSameDate(entry.date, today)) {
          existingTodayEntry = entry;
          break;
        }
      }
    }

    return JournalEntry(
      id: existingTodayEntry?.id ?? _uuid.v4(),
      date: existingTodayEntry?.date ?? today,
      positiveSymptom: draft.positiveSymptom,
      negativeSymptom: draft.negativeSymptom,
      sleepQuality: draft.sleepQuality,
      stressLevel: draft.stressLevel,
      socialEnergy: draft.socialEnergy,
      note: draft.note.trim(),
    );
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
