import 'package:equatable/equatable.dart';
import '../../domain/entities/weekly_insights.dart';
import '../../../../core/error/failures.dart';

abstract class InsightsState extends Equatable {
  const InsightsState();

  @override
  List<Object?> get props => [];
}

/// No insights generated yet.
class InsightsInitial extends InsightsState {
  const InsightsInitial();
}

/// AI request is in progress.
class InsightsLoading extends InsightsState {
  const InsightsLoading();
}

/// Insights successfully received from the AI provider.
class InsightsLoaded extends InsightsState {
  final WeeklyInsights insights;

  const InsightsLoaded(this.insights);

  @override
  List<Object?> get props => [insights];
}

/// An error occurred during AI generation.
class InsightsError extends InsightsState {
  final Failure failure;

  const InsightsError(this.failure);

  @override
  List<Object?> get props => [failure];
}
