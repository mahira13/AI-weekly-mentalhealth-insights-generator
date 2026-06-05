import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/generate_weekly_insights.dart';
import '../../../../core/error/failures.dart';
import 'insights_event.dart';
import 'insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final GenerateWeeklyInsights generateWeeklyInsights;

  InsightsBloc({required this.generateWeeklyInsights})
      : super(const InsightsInitial()) {
    on<GenerateInsights>(_onGenerateInsights);
    on<ResetInsights>(_onResetInsights);
  }

  Future<void> _onGenerateInsights(
    GenerateInsights event,
    Emitter<InsightsState> emit,
  ) async {
    emit(const InsightsLoading());
    try {
      final insights = await generateWeeklyInsights(event.entries);
      emit(InsightsLoaded(insights));
    } on AuthFailure catch (f) {
      emit(InsightsError(f));
    } on ServerFailure catch (f) {
      emit(InsightsError(f));
    } on ParseFailure catch (f) {
      emit(InsightsError(f));
    } catch (e) {
      emit(InsightsError(ServerFailure(e.toString())));
    }
  }

  void _onResetInsights(ResetInsights event, Emitter<InsightsState> emit) {
    emit(const InsightsInitial());
  }
}
