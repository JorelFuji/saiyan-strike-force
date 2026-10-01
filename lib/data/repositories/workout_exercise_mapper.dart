import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/exercise_name.dart';
import '../../domain/models/workout_template.dart';
import '../database/app_database.dart';
import 'session_snapshot_mapper.dart';

Result<TemplateSet> mapWorkoutSet(WorkoutSetData row) {
  final reps = mapRepPrescriptionFields(
    repTypeWire: row.repType,
    targetReps: row.targetReps,
    minReps: row.minReps,
    maxReps: row.maxReps,
  );
  if (reps case Err(:final failure)) return Err(failure);
  final load = mapLoadPrescriptionFields(
    loadTypeWire: row.loadType,
    weightCanonicalMg: row.weightCanonicalMg,
    percentage: row.percentage,
    targetRpe: row.targetRpe,
    freeformText: row.freeformText,
  );
  if (load case Err(:final failure)) return Err(failure);
  return TemplateSet.create(
    reps: (reps as Ok).value,
    load: (load as Ok).value,
    restSeconds: row.restSeconds,
  );
}

Result<TemplateExercise> mapWorkoutExercise(
  WorkoutExerciseData row,
  List<WorkoutSetData> sets,
) {
  if (normalizeExerciseName(row.name) != row.normalizedName) {
    return const Err(ValidationFailure('Exercise normalized name is invalid.'));
  }
  if (sets.length != row.plannedSets) {
    return const Err(
      ValidationFailure('Workout set count does not match exercise.'),
    );
  }
  for (var index = 0; index < sets.length; index++) {
    if (sets[index].setIndex != index) {
      return const Err(
        ValidationFailure('Workout set indices are not contiguous.'),
      );
    }
  }
  final mappedSets = <TemplateSet>[];
  for (final set in sets) {
    final mapped = mapWorkoutSet(set);
    if (mapped case Err(:final failure)) return Err(failure);
    mappedSets.add((mapped as Ok<TemplateSet>).value);
  }
  return TemplateExercise.create(
    name: row.name,
    sets: mappedSets,
    supersetGroup: row.supersetGroup,
  );
}
