import 'package:equatable/equatable.dart';
import '../../../journal/domain/entities/journal_entry.dart';

abstract class InsightsEvent extends Equatable {
  const InsightsEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers AI insight generation for [entries].
class GenerateInsights extends InsightsEvent {
  final List<JournalEntry> entries;

  const GenerateInsights(this.entries);

  @override
  List<Object?> get props => [entries];
}

/// Resets the insights screen back to the initial state.
class ResetInsights extends InsightsEvent {
  const ResetInsights();
}
