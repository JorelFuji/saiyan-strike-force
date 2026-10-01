import '../../core/result.dart';
import '../../domain/models/workout_template.dart';
import 'superset_grouping.dart' as grouping;
import 'workout_builder_state.dart';

/// Deterministic allocation and row transformations for the template draft.
final class WorkoutDraftEditor {
  int _nextExerciseKey = 1;
  int _nextSetKey = 1;

  List<DraftExerciseRow> rowsFromExercises(
    Iterable<TemplateExercise> exercises,
  ) => [for (final exercise in exercises) row(exercise)];

  DraftExerciseRow row(TemplateExercise exercise) => DraftExerciseRow(
    key: _nextExerciseKey++,
    exercise: exercise,
    setKeys: freshSetKeys(exercise.plannedSets),
  );

  List<int> freshSetKeys(int count) => [
    for (var index = 0; index < count; index++) _nextSetKey++,
  ];

  List<DraftExerciseRow> add(
    List<DraftExerciseRow> rows,
    TemplateExercise exercise,
  ) => grouping.normalizeSupersetRows([...rows, row(exercise)]);

  List<DraftExerciseRow> normalize(List<DraftExerciseRow> rows) =>
      grouping.normalizeSupersetRows(rows);

  Result<DraftExerciseRow> replace(
    DraftExerciseRow row,
    TemplateExercise exercise,
  ) => Ok(
    row.copyWith(
      exercise: exercise,
      setKeys: row.setKeys.length == exercise.plannedSets
          ? row.setKeys
          : freshSetKeys(exercise.plannedSets),
    ),
  );
}
