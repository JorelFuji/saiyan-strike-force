import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/result.dart';
import '../../domain/models/mass.dart';
import '../../domain/models/workout_template.dart';
import '../../domain/repositories/exercise_name_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/workout_repository.dart';
import 'workout_builder_state.dart';

final class WorkoutBuilderCubit extends Cubit<WorkoutBuilderState> {
  WorkoutBuilderCubit({
    required WorkoutRepository workoutRepository,
    required ExerciseNameRepository exerciseNameRepository,
    required SettingsRepository settingsRepository,
    this.workoutId,
  }) : _workouts = workoutRepository,
       _exerciseNames = exerciseNameRepository,
       _settings = settingsRepository,
       super(WorkoutBuilderState());

  final int? workoutId;
  final WorkoutRepository _workouts;
  final ExerciseNameRepository _exerciseNames;
  final SettingsRepository _settings;
  int _nextExerciseKey = 1;

  Future<void> initialize() async {
    emit(
      state.copyWith(
        phase: WorkoutBuilderPhase.loading,
        clearSavedTemplate: true,
      ),
    );
    final unitResult = await _settings.readOrCreateDisplayMassUnit();
    if (isClosed) return;
    if (unitResult case Err(:final failure)) {
      emit(
        state.copyWith(
          phase: WorkoutBuilderPhase.loadFailure,
          loadFailureMessage: failure.message,
        ),
      );
      return;
    }
    final massUnit = (unitResult as Ok<MassUnit>).value;

    WorkoutTemplate? original;
    var name = '';
    var notes = '';
    List<DraftExerciseRow> exercises = const [];
    if (workoutId != null) {
      final templateResult = await _workouts.getById(workoutId!);
      if (isClosed) return;
      switch (templateResult) {
        case Err(:final failure):
          emit(
            state.copyWith(
              phase: WorkoutBuilderPhase.loadFailure,
              massUnit: massUnit,
              loadFailureMessage: failure.message,
            ),
          );
          return;
        case Ok(value: null):
          emit(
            state.copyWith(
              phase: WorkoutBuilderPhase.loadFailure,
              massUnit: massUnit,
              loadFailureMessage: 'Workout template was not found.',
            ),
          );
          return;
        case Ok(value: final template?):
          original = template;
          name = template.name;
          notes = template.notes ?? '';
          exercises = _rowsFromExercises(template.exercises);
      }
    }

    emit(
      WorkoutBuilderState(
        phase: WorkoutBuilderPhase.ready,
        massUnit: massUnit,
        name: name,
        notes: notes,
        exercises: exercises,
        original: original,
      ),
    );
    await _loadSuggestions();
  }

  Future<void> retryLoad() => initialize();

  Future<void> retrySuggestions() => _loadSuggestions();

  void updateName(String value) {
    if (!state.phase.isEditable) return;
    emit(
      state.copyWith(
        name: value,
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }

  void updateNotes(String value) {
    if (!state.phase.isEditable) return;
    emit(
      state.copyWith(
        notes: value,
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }

  void addExercise(TemplateExercise exercise) {
    if (!state.phase.isEditable) return;
    final key = _nextExerciseKey++;
    emit(
      state.copyWith(
        exercises: [
          ...state.exercises,
          DraftExerciseRow(key: key, exercise: exercise),
        ],
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }

  void replaceExercise(int key, TemplateExercise exercise) {
    if (!state.phase.isEditable) return;
    final index = state.exercises.indexWhere((row) => row.key == key);
    if (index < 0) return;
    final updated = List<DraftExerciseRow>.of(state.exercises);
    updated[index] = DraftExerciseRow(key: key, exercise: exercise);
    emit(
      state.copyWith(
        exercises: updated,
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }

  void removeExercise(int key) {
    if (!state.phase.isEditable) return;
    emit(
      state.copyWith(
        exercises: state.exercises.where((row) => row.key != key).toList(),
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }

  void moveEarlier(int key) {
    if (!state.phase.isEditable) return;
    final index = state.exercises.indexWhere((row) => row.key == key);
    if (index <= 0) return;
    _swap(index, index - 1);
  }

  void moveLater(int key) {
    if (!state.phase.isEditable) return;
    final index = state.exercises.indexWhere((row) => row.key == key);
    if (index < 0 || index >= state.exercises.length - 1) return;
    _swap(index, index + 1);
  }

  void reorder(int oldIndex, int newIndex) {
    if (!state.phase.isEditable) return;
    if (oldIndex < 0 ||
        oldIndex >= state.exercises.length ||
        newIndex < 0 ||
        newIndex > state.exercises.length) {
      return;
    }
    // ReorderableListView reports the insertion location before removal.
    if (oldIndex < newIndex) newIndex--;
    if (oldIndex == newIndex) return;
    final rows = List<DraftExerciseRow>.of(state.exercises);
    final row = rows.removeAt(oldIndex);
    rows.insert(newIndex, row);
    emit(
      state.copyWith(
        exercises: rows,
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }

  Future<void> save() async {
    if (state.phase == WorkoutBuilderPhase.saving) return;
    if (state.phase != WorkoutBuilderPhase.ready) return;

    final trimmedName = state.name.trim();
    final trimmedNotes = state.notes.trim();
    final draftResult = WorkoutTemplateDraft.create(
      name: trimmedName,
      notes: trimmedNotes.isEmpty ? null : trimmedNotes,
      exercises: state.exerciseValues,
    );
    if (draftResult case Err(:final failure)) {
      emit(
        state.copyWith(
          name: state.name,
          notes: state.notes,
          validationFailureMessage: failure.message,
          clearSaveFailure: true,
        ),
      );
      return;
    }
    final draft = (draftResult as Ok<WorkoutTemplateDraft>).value;
    emit(
      state.copyWith(
        phase: WorkoutBuilderPhase.saving,
        name: state.name,
        notes: state.notes,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );

    final Result<WorkoutTemplate> result;
    final original = state.original;
    if (original == null) {
      result = await _workouts.create(draft);
    } else {
      final updated = WorkoutTemplate.create(
        id: original.id,
        name: draft.name,
        notes: draft.notes,
        createdAt: original.createdAt,
        archivedAt: original.archivedAt,
        exercises: draft.exercises,
      );
      if (updated case Err(:final failure)) {
        if (isClosed) return;
        emit(
          state.copyWith(
            phase: WorkoutBuilderPhase.ready,
            validationFailureMessage: failure.message,
          ),
        );
        return;
      }
      result = await _workouts.update((updated as Ok<WorkoutTemplate>).value);
    }
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          WorkoutBuilderState(
            phase: WorkoutBuilderPhase.ready,
            massUnit: state.massUnit,
            name: value.name,
            notes: value.notes ?? '',
            exercises: _rowsFromExercises(value.exercises),
            suggestions: state.suggestions,
            original: value,
            savedTemplate: value,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            phase: WorkoutBuilderPhase.ready,
            saveFailureMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _loadSuggestions() async {
    if (state.phase != WorkoutBuilderPhase.ready &&
        state.phase != WorkoutBuilderPhase.saving) {
      return;
    }
    final result = await _exerciseNames.listSuggestions();
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(suggestions: value, clearSuggestionFailure: true));
      case Err(:final failure):
        emit(state.copyWith(suggestionFailureMessage: failure.message));
    }
  }

  List<DraftExerciseRow> _rowsFromExercises(List<TemplateExercise> exercises) {
    return [
      for (final exercise in exercises)
        DraftExerciseRow(key: _nextExerciseKey++, exercise: exercise),
    ];
  }

  void _swap(int first, int second) {
    final rows = List<DraftExerciseRow>.of(state.exercises);
    final temp = rows[first];
    rows[first] = rows[second];
    rows[second] = temp;
    emit(
      state.copyWith(
        exercises: rows,
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }
}

extension on WorkoutBuilderPhase {
  bool get isEditable => this == WorkoutBuilderPhase.ready;
}
