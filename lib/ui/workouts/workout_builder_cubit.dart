import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/result.dart';
import '../../domain/models/mass.dart';
import '../../domain/models/workout_template.dart';
import '../../domain/repositories/exercise_name_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/workout_repository.dart';
import 'workout_builder_state.dart';
import 'superset_grouping.dart' as grouping;
import 'widgets/template_exercise_editor_sheet.dart';

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
  int _nextSetKey = 1;

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
        exercises: grouping.normalizeSupersetRows([
          ...state.exercises,
          _row(key, exercise),
        ]),
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
    final row = updated[index];
    updated[index] = row.copyWith(
      exercise: exercise,
      setKeys: row.setKeys.length == exercise.plannedSets
          ? row.setKeys
          : _freshSetKeys(exercise.plannedSets),
    );
    emit(
      state.copyWith(
        exercises: grouping.normalizeSupersetRows(updated),
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
        exercises: grouping.normalizeSupersetRows(
          state.exercises.where((row) => row.key != key).toList(),
        ),
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }

  void updateSet(int rowKey, int setKey, TemplateSet value) {
    if (!state.phase.isEditable) return;
    final rowIndex = state.exercises.indexWhere((row) => row.key == rowKey);
    if (rowIndex < 0) return;
    final row = state.exercises[rowIndex];
    final setIndex = row.setKeys.indexOf(setKey);
    if (setIndex < 0) return;
    final sets = List<TemplateSet>.of(row.exercise.sets)..[setIndex] = value;
    final exercise = TemplateExercise.create(
      name: row.exercise.name,
      sets: sets,
      supersetGroup: row.exercise.supersetGroup,
    );
    if (exercise case Err()) {
      return;
    }
    final errors = Map<DraftCellId, String>.of(state.cellErrors)
      ..remove(
        DraftCellId(
          rowKey: rowKey,
          setKey: setKey,
          column: DraftCellColumn.load,
        ),
      )
      ..remove(
        DraftCellId(
          rowKey: rowKey,
          setKey: setKey,
          column: DraftCellColumn.reps,
        ),
      );
    final rows = List<DraftExerciseRow>.of(state.exercises)
      ..[rowIndex] = row.copyWith(
        exercise: (exercise as Ok<TemplateExercise>).value,
      );
    _emitDraft(rows, errors: errors);
  }

  void reportCellError(DraftCellId id, String? message) {
    if (!state.phase.isEditable) return;
    final errors = Map<DraftCellId, String>.of(state.cellErrors);
    if (message == null || message.isEmpty) {
      errors.remove(id);
    } else {
      errors[id] = message;
    }
    emit(state.copyWith(cellErrors: errors));
  }

  void updateSetRest(int rowKey, int setKey, int seconds) {
    _updateSetValue(
      rowKey,
      setKey,
      (set) => TemplateSet.create(
        reps: set.reps,
        load: set.load,
        restSeconds: seconds,
      ),
    );
  }

  void applyRestToAll(int rowKey, int seconds) {
    if (!state.phase.isEditable) return;
    final index = state.exercises.indexWhere((row) => row.key == rowKey);
    if (index < 0) return;
    final row = state.exercises[index];
    final sets = <TemplateSet>[];
    for (final set in row.exercise.sets) {
      final result = TemplateSet.create(
        reps: set.reps,
        load: set.load,
        restSeconds: seconds,
      );
      if (result case Err()) {
        return;
      }
      sets.add((result as Ok<TemplateSet>).value);
    }
    final exercise = TemplateExercise.create(
      name: row.exercise.name,
      sets: sets,
      supersetGroup: row.exercise.supersetGroup,
    );
    if (exercise case Err()) {
      return;
    }
    final rows = List<DraftExerciseRow>.of(state.exercises)
      ..[index] = row.copyWith(
        exercise: (exercise as Ok<TemplateExercise>).value,
      );
    _emitDraft(rows);
  }

  void addSet(int rowKey) {
    if (!state.phase.isEditable) return;
    final index = state.exercises.indexWhere((row) => row.key == rowKey);
    if (index < 0) return;
    final row = state.exercises[index];
    final sets = [...row.exercise.sets, row.exercise.lastSet];
    final exercise = TemplateExercise.create(
      name: row.exercise.name,
      sets: sets,
      supersetGroup: row.exercise.supersetGroup,
    );
    if (exercise case Err()) return;
    final rows = List<DraftExerciseRow>.of(state.exercises)
      ..[index] = row.copyWith(
        exercise: (exercise as Ok<TemplateExercise>).value,
        setKeys: [...row.setKeys, _nextSetKey++],
      );
    _emitDraft(rows);
  }

  RemovedTemplateSet? removeSet(int rowKey, int setKey) {
    if (!state.phase.isEditable) return null;
    final index = state.exercises.indexWhere((row) => row.key == rowKey);
    if (index < 0) return null;
    final row = state.exercises[index];
    if (row.exercise.plannedSets == 1) return null;
    final setIndex = row.setKeys.indexOf(setKey);
    if (setIndex < 0) return null;
    final removed = RemovedTemplateSet(
      rowKey: rowKey,
      setKey: setKey,
      index: setIndex,
      value: row.exercise.sets[setIndex],
    );
    final sets = List<TemplateSet>.of(row.exercise.sets)..removeAt(setIndex);
    final keys = List<int>.of(row.setKeys)..removeAt(setIndex);
    final exercise = TemplateExercise.create(
      name: row.exercise.name,
      sets: sets,
      supersetGroup: row.exercise.supersetGroup,
    );
    if (exercise case Err()) return null;
    final rows = List<DraftExerciseRow>.of(state.exercises)
      ..[index] = row.copyWith(
        exercise: (exercise as Ok<TemplateExercise>).value,
        setKeys: keys,
      );
    final errors = Map<DraftCellId, String>.of(state.cellErrors)
      ..removeWhere((id, _) => id.rowKey == rowKey && id.setKey == setKey);
    _emitDraft(rows, errors: errors);
    return removed;
  }

  void restoreSet(RemovedTemplateSet removed) {
    if (!state.phase.isEditable) return;
    final index = state.exercises.indexWhere(
      (row) => row.key == removed.rowKey,
    );
    if (index < 0) return;
    final row = state.exercises[index];
    if (row.exercise.sets.any(
      (set) =>
          set.reps.type != removed.value.reps.type ||
          set.load.type != removed.value.load.type,
    )) {
      return;
    }
    final at = removed.index.clamp(0, row.exercise.plannedSets);
    final sets = List<TemplateSet>.of(row.exercise.sets)
      ..insert(at, removed.value);
    final keys = List<int>.of(row.setKeys)..insert(at, removed.setKey);
    final exercise = TemplateExercise.create(
      name: row.exercise.name,
      sets: sets,
      supersetGroup: row.exercise.supersetGroup,
    );
    if (exercise case Err()) {
      return;
    }
    final rows = List<DraftExerciseRow>.of(state.exercises)
      ..[index] = row.copyWith(
        exercise: (exercise as Ok<TemplateExercise>).value,
        setKeys: keys,
      );
    _emitDraft(rows);
  }

  void applyExerciseDetails(int rowKey, TemplateExerciseDetailsEdit edit) {
    if (!state.phase.isEditable) return;
    final index = state.exercises.indexWhere((row) => row.key == rowKey);
    if (index < 0) return;
    final row = state.exercises[index];
    final sets = row.exercise.sets
        .map(
          (set) => TemplateSet.create(
            reps: edit.reps ?? set.reps,
            load: edit.load ?? set.load,
            restSeconds: set.restSeconds,
          ),
        )
        .map((result) => (result as Ok<TemplateSet>).value)
        .toList();
    final exercise = TemplateExercise.create(
      name: edit.name,
      sets: sets,
      supersetGroup: row.exercise.supersetGroup,
    );
    if (exercise case Err()) return;
    final errors = Map<DraftCellId, String>.of(state.cellErrors);
    if (edit.reps != null) {
      errors.removeWhere(
        (id, _) => id.rowKey == rowKey && id.column == DraftCellColumn.reps,
      );
    }
    if (edit.load != null) {
      errors.removeWhere(
        (id, _) => id.rowKey == rowKey && id.column == DraftCellColumn.load,
      );
    }
    final rows = List<DraftExerciseRow>.of(state.exercises)
      ..[index] = row.copyWith(
        exercise: (exercise as Ok<TemplateExercise>).value,
      );
    _emitDraft(rows, errors: errors);
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
        exercises: grouping.normalizeSupersetRows(rows),
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }

  Future<void> save() async {
    if (state.phase == WorkoutBuilderPhase.saving) return;
    if (state.phase != WorkoutBuilderPhase.ready) return;
    if (state.hasCellErrors) {
      emit(
        state.copyWith(
          validationFailureMessage:
              'Fix the highlighted set values before saving.',
          clearSaveFailure: true,
        ),
      );
      return;
    }

    final trimmedName = state.name.trim();
    final trimmedNotes = state.notes.trim();
    final normalizedRows = grouping.normalizeSupersetRows(state.exercises);
    final draftResult = WorkoutTemplateDraft.create(
      name: trimmedName,
      notes: trimmedNotes.isEmpty ? null : trimmedNotes,
      exercises: normalizedRows.map((row) => row.exercise).toList(),
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

  void groupWithPrevious(int key) {
    if (!state.phase.isEditable) return;
    final index = state.exercises.indexWhere((row) => row.key == key);
    if (index <= 0) return;
    _setExercises(grouping.groupWithPrevious(state.exercises, index));
  }

  void removeFromSuperset(int key) {
    if (!state.phase.isEditable) return;
    final index = state.exercises.indexWhere((row) => row.key == key);
    if (index < 0) return;
    _setExercises(grouping.removeFromSuperset(state.exercises, index));
  }

  List<DraftExerciseRow> _rowsFromExercises(List<TemplateExercise> exercises) {
    return [
      for (final exercise in exercises) _row(_nextExerciseKey++, exercise),
    ];
  }

  void _swap(int first, int second) {
    final rows = List<DraftExerciseRow>.of(state.exercises);
    final temp = rows[first];
    rows[first] = rows[second];
    rows[second] = temp;
    emit(
      state.copyWith(
        exercises: grouping.normalizeSupersetRows(rows),
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }

  void _setExercises(List<DraftExerciseRow> exercises) {
    emit(
      state.copyWith(
        exercises: grouping.normalizeSupersetRows(exercises),
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }

  DraftExerciseRow _row(int key, TemplateExercise exercise) => DraftExerciseRow(
    key: key,
    exercise: exercise,
    setKeys: _freshSetKeys(exercise.plannedSets),
  );

  List<int> _freshSetKeys(int count) => [
    for (var index = 0; index < count; index++) _nextSetKey++,
  ];

  void _updateSetValue(
    int rowKey,
    int setKey,
    Result<TemplateSet> Function(TemplateSet) update,
  ) {
    if (!state.phase.isEditable) return;
    final rowIndex = state.exercises.indexWhere(
      (candidate) => candidate.key == rowKey,
    );
    if (rowIndex < 0) return;
    final row = state.exercises[rowIndex];
    final index = row.setKeys.indexOf(setKey);
    if (index < 0) return;
    final result = update(row.exercise.sets[index]);
    if (result case Err()) return;
    final sets = List<TemplateSet>.of(row.exercise.sets)
      ..[index] = (result as Ok<TemplateSet>).value;
    final exercise = TemplateExercise.create(
      name: row.exercise.name,
      sets: sets,
      supersetGroup: row.exercise.supersetGroup,
    );
    if (exercise case Err()) return;
    final rows = List<DraftExerciseRow>.of(state.exercises)
      ..[rowIndex] = row.copyWith(
        exercise: (exercise as Ok<TemplateExercise>).value,
      );
    _emitDraft(rows);
  }

  void _emitDraft(
    List<DraftExerciseRow> rows, {
    Map<DraftCellId, String>? errors,
  }) {
    emit(
      state.copyWith(
        exercises: grouping.normalizeSupersetRows(rows),
        cellErrors: errors ?? state.cellErrors,
        isDirty: true,
        clearValidationFailure: true,
        clearSaveFailure: true,
      ),
    );
  }
}

final class RemovedTemplateSet {
  const RemovedTemplateSet({
    required this.rowKey,
    required this.setKey,
    required this.index,
    required this.value,
  });
  final int rowKey;
  final int setKey;
  final int index;
  final TemplateSet value;
}

extension on WorkoutBuilderPhase {
  bool get isEditable => this == WorkoutBuilderPhase.ready;
}
