import '../../domain/models/exercise_history.dart';
import '../../domain/models/mass.dart';

enum ExerciseHistoryLoadPhase { loading, ready, empty, failure }

final class ExerciseHistoryState {
  const ExerciseHistoryState({
    this.loadPhase = ExerciseHistoryLoadPhase.loading,
    this.displayName = '',
    this.normalizedName = '',
    this.massUnit = MassUnit.kg,
    this.entries = const [],
    this.failureMessage,
  });

  final ExerciseHistoryLoadPhase loadPhase;
  final String displayName;
  final String normalizedName;
  final MassUnit massUnit;
  final List<ExerciseHistoryEntry> entries;
  final String? failureMessage;

  /// Most recent snapshot display name for the AppBar title.
  String? get titleName => entries.isEmpty
      ? (displayName.isEmpty ? null : displayName)
      : entries.first.nameSnapshot;

  ExerciseHistoryState copyWith({
    ExerciseHistoryLoadPhase? loadPhase,
    String? displayName,
    String? normalizedName,
    MassUnit? massUnit,
    List<ExerciseHistoryEntry>? entries,
    String? failureMessage,
    bool clearFailureMessage = false,
  }) {
    return ExerciseHistoryState(
      loadPhase: loadPhase ?? this.loadPhase,
      displayName: displayName ?? this.displayName,
      normalizedName: normalizedName ?? this.normalizedName,
      massUnit: massUnit ?? this.massUnit,
      entries: entries ?? this.entries,
      failureMessage: clearFailureMessage
          ? null
          : (failureMessage ?? this.failureMessage),
    );
  }
}
