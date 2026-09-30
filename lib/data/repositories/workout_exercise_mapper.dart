import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/exercise_name.dart';
import '../../domain/models/prescriptions.dart';
import '../../domain/models/workout_template.dart';
import '../database/app_database.dart';

Result<TemplateExercise> mapWorkoutExercise(WorkoutExerciseData row) {
  if (normalizeExerciseName(row.name) != row.normalizedName) {
    return const Err(ValidationFailure('Exercise normalized name is invalid.'));
  }
  final repType = RepType.fromWire(row.repType);
  if (repType case Err(:final failure)) return Err(failure);
  final reps = switch ((repType as Ok<RepType>).value) {
    RepType.fixed
        when row.targetReps != null &&
            row.minReps == null &&
            row.maxReps == null =>
      RepPrescription.fixed(row.targetReps!),
    RepType.range
        when row.targetReps == null &&
            row.minReps != null &&
            row.maxReps != null =>
      RepPrescription.range(row.minReps!, row.maxReps!),
    RepType.amrap
        when row.targetReps == null &&
            row.minReps == null &&
            row.maxReps == null =>
      const Ok<RepPrescription>(Amrap()),
    _ => const Err<RepPrescription>(
      ValidationFailure('Rep fields are incompatible.'),
    ),
  };
  if (reps case Err(:final failure)) return Err(failure);
  final loadType = LoadType.fromWire(row.loadType);
  if (loadType case Err(:final failure)) return Err(failure);
  final load = switch ((loadType as Ok<LoadType>).value) {
    LoadType.none
        when row.weightCanonicalMg == null &&
            row.percentage == null &&
            row.targetRpe == null &&
            row.freeformText == null =>
      const Ok<LoadPrescription>(NoLoad()),
    LoadType.bodyweight
        when row.weightCanonicalMg == null &&
            row.percentage == null &&
            row.targetRpe == null &&
            row.freeformText == null =>
      const Ok<LoadPrescription>(BodyweightLoad()),
    LoadType.absolute
        when row.weightCanonicalMg != null &&
            row.percentage == null &&
            row.targetRpe == null &&
            row.freeformText == null =>
      LoadPrescription.absolute(row.weightCanonicalMg!),
    LoadType.percentage
        when row.percentage != null &&
            row.weightCanonicalMg == null &&
            row.targetRpe == null &&
            row.freeformText == null =>
      LoadPrescription.percentage(row.percentage!),
    LoadType.targetRpe
        when row.targetRpe != null &&
            row.weightCanonicalMg == null &&
            row.percentage == null &&
            row.freeformText == null =>
      LoadPrescription.targetRpe(row.targetRpe!),
    LoadType.text
        when row.freeformText != null &&
            row.weightCanonicalMg == null &&
            row.percentage == null &&
            row.targetRpe == null =>
      LoadPrescription.text(row.freeformText!),
    _ => const Err<LoadPrescription>(
      ValidationFailure('Load fields are incompatible.'),
    ),
  };
  if (load case Err(:final failure)) return Err(failure);
  return TemplateExercise.create(
    name: row.name,
    plannedSets: row.plannedSets,
    reps: (reps as Ok<RepPrescription>).value,
    load: (load as Ok<LoadPrescription>).value,
    restSeconds: row.restSeconds,
    supersetGroup: row.supersetGroup,
  );
}
