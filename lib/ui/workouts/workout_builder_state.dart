import '../../domain/models/exercise_name.dart';
import '../../domain/models/mass.dart';
import '../../domain/models/workout_template.dart';

enum WorkoutBuilderPhase { initial, loading, ready, loadFailure, saving }

/// One draft exercise row with a stable key for reorder and edit targeting.
final class DraftExerciseRow {
  const DraftExerciseRow({required this.key, required this.exercise});

  final int key;
  final TemplateExercise exercise;
}

final class WorkoutBuilderState {
  WorkoutBuilderState({
    this.phase = WorkoutBuilderPhase.initial,
    this.massUnit = MassUnit.kg,
    this.name = '',
    this.notes = '',
    List<DraftExerciseRow> exercises = const [],
    List<ExerciseNameSuggestion> suggestions = const [],
    this.suggestionFailureMessage,
    this.original,
    this.isDirty = false,
    this.loadFailureMessage,
    this.validationFailureMessage,
    this.saveFailureMessage,
    this.savedTemplate,
  }) : exercises = List.unmodifiable(exercises),
       suggestions = List.unmodifiable(suggestions);

  final WorkoutBuilderPhase phase;
  final MassUnit massUnit;
  final String name;
  final String notes;
  final List<DraftExerciseRow> exercises;
  final List<ExerciseNameSuggestion> suggestions;
  final String? suggestionFailureMessage;
  final WorkoutTemplate? original;
  final bool isDirty;
  final String? loadFailureMessage;
  final String? validationFailureMessage;
  final String? saveFailureMessage;
  final WorkoutTemplate? savedTemplate;

  bool get isCreate => original == null;
  bool get isSaving => phase == WorkoutBuilderPhase.saving;

  List<TemplateExercise> get exerciseValues =>
      exercises.map((row) => row.exercise).toList(growable: false);

  WorkoutBuilderState copyWith({
    WorkoutBuilderPhase? phase,
    MassUnit? massUnit,
    String? name,
    String? notes,
    List<DraftExerciseRow>? exercises,
    List<ExerciseNameSuggestion>? suggestions,
    String? suggestionFailureMessage,
    bool clearSuggestionFailure = false,
    WorkoutTemplate? original,
    bool? isDirty,
    String? loadFailureMessage,
    bool clearLoadFailure = false,
    String? validationFailureMessage,
    bool clearValidationFailure = false,
    String? saveFailureMessage,
    bool clearSaveFailure = false,
    WorkoutTemplate? savedTemplate,
    bool clearSavedTemplate = false,
  }) => WorkoutBuilderState(
    phase: phase ?? this.phase,
    massUnit: massUnit ?? this.massUnit,
    name: name ?? this.name,
    notes: notes ?? this.notes,
    exercises: exercises ?? this.exercises,
    suggestions: suggestions ?? this.suggestions,
    suggestionFailureMessage: clearSuggestionFailure
        ? null
        : (suggestionFailureMessage ?? this.suggestionFailureMessage),
    original: original ?? this.original,
    isDirty: isDirty ?? this.isDirty,
    loadFailureMessage: clearLoadFailure
        ? null
        : (loadFailureMessage ?? this.loadFailureMessage),
    validationFailureMessage: clearValidationFailure
        ? null
        : (validationFailureMessage ?? this.validationFailureMessage),
    saveFailureMessage: clearSaveFailure
        ? null
        : (saveFailureMessage ?? this.saveFailureMessage),
    savedTemplate: clearSavedTemplate
        ? null
        : (savedTemplate ?? this.savedTemplate),
  );
}
