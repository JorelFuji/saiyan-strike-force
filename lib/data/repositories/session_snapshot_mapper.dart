import 'package:drift/drift.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/active_session.dart';
import '../../domain/models/exercise_name.dart';
import '../../domain/models/prescriptions.dart';
import '../../domain/models/session_status.dart';
import '../database/app_database.dart';

Result<RepPrescription> mapRepPrescriptionFields({
  required String repTypeWire,
  int? targetReps,
  int? minReps,
  int? maxReps,
}) {
  final repType = RepType.fromWire(repTypeWire);
  if (repType case Err(:final failure)) return Err(failure);
  return switch ((repType as Ok<RepType>).value) {
    RepType.fixed
        when targetReps != null && minReps == null && maxReps == null =>
      RepPrescription.fixed(targetReps),
    RepType.range
        when targetReps == null && minReps != null && maxReps != null =>
      RepPrescription.range(minReps, maxReps),
    RepType.amrap
        when targetReps == null && minReps == null && maxReps == null =>
      const Ok<RepPrescription>(Amrap()),
    _ => const Err<RepPrescription>(
      ValidationFailure('Rep fields are incompatible.'),
    ),
  };
}

Result<LoadPrescription> mapLoadPrescriptionFields({
  required String loadTypeWire,
  int? weightCanonicalMg,
  int? percentage,
  double? targetRpe,
  String? freeformText,
}) {
  final loadType = LoadType.fromWire(loadTypeWire);
  if (loadType case Err(:final failure)) return Err(failure);
  return switch ((loadType as Ok<LoadType>).value) {
    LoadType.none
        when weightCanonicalMg == null &&
            percentage == null &&
            targetRpe == null &&
            freeformText == null =>
      const Ok<LoadPrescription>(NoLoad()),
    LoadType.bodyweight
        when weightCanonicalMg == null &&
            percentage == null &&
            targetRpe == null &&
            freeformText == null =>
      const Ok<LoadPrescription>(BodyweightLoad()),
    LoadType.absolute
        when weightCanonicalMg != null &&
            percentage == null &&
            targetRpe == null &&
            freeformText == null =>
      LoadPrescription.absolute(weightCanonicalMg),
    LoadType.percentage
        when percentage != null &&
            weightCanonicalMg == null &&
            targetRpe == null &&
            freeformText == null =>
      LoadPrescription.percentage(percentage),
    LoadType.targetRpe
        when targetRpe != null &&
            weightCanonicalMg == null &&
            percentage == null &&
            freeformText == null =>
      LoadPrescription.targetRpe(targetRpe),
    LoadType.text
        when freeformText != null &&
            weightCanonicalMg == null &&
            percentage == null &&
            targetRpe == null =>
      LoadPrescription.text(freeformText),
    _ => const Err<LoadPrescription>(
      ValidationFailure('Load fields are incompatible.'),
    ),
  };
}

Result<ActualPrescription?> mapOptionalActualPrescription({
  String? repTypeWire,
  int? targetReps,
  int? minReps,
  int? maxReps,
  String? loadTypeWire,
  int? weightCanonicalMg,
  int? percentage,
  double? targetRpe,
  String? freeformText,
}) {
  final hasRep = repTypeWire != null;
  final hasLoad = loadTypeWire != null;
  if (!hasRep && !hasLoad) {
    return const Ok(null);
  }
  if (!hasRep || !hasLoad) {
    return const Err(
      ValidationFailure('Actual prescription fields are incomplete.'),
    );
  }
  final reps = mapRepPrescriptionFields(
    repTypeWire: repTypeWire,
    targetReps: targetReps,
    minReps: minReps,
    maxReps: maxReps,
  );
  if (reps case Err(:final failure)) return Err(failure);
  final load = mapLoadPrescriptionFields(
    loadTypeWire: loadTypeWire,
    weightCanonicalMg: weightCanonicalMg,
    percentage: percentage,
    targetRpe: targetRpe,
    freeformText: freeformText,
  );
  if (load case Err(:final failure)) return Err(failure);
  return ActualPrescription.create(
    reps: (reps as Ok<RepPrescription>).value,
    load: (load as Ok<LoadPrescription>).value,
  );
}

Result<SessionSetSnapshot> mapSessionSetRow(SessionSetData row) {
  final plannedReps = mapRepPrescriptionFields(
    repTypeWire: row.plannedRepType,
    targetReps: row.plannedTargetReps,
    minReps: row.plannedMinReps,
    maxReps: row.plannedMaxReps,
  );
  if (plannedReps case Err(:final failure)) return Err(failure);
  final plannedLoad = mapLoadPrescriptionFields(
    loadTypeWire: row.plannedLoadType,
    weightCanonicalMg: row.plannedWeightCanonicalMg,
    percentage: row.plannedPercentage,
    targetRpe: row.plannedTargetRpe,
    freeformText: row.plannedFreeformText,
  );
  if (plannedLoad case Err(:final failure)) return Err(failure);
  final actual = mapOptionalActualPrescription(
    repTypeWire: row.actualRepType,
    targetReps: row.actualTargetReps,
    minReps: row.actualMinReps,
    maxReps: row.actualMaxReps,
    loadTypeWire: row.actualLoadType,
    weightCanonicalMg: row.actualWeightCanonicalMg,
    percentage: row.actualPercentage,
    targetRpe: row.actualTargetRpe,
    freeformText: row.actualFreeformText,
  );
  if (actual case Err(:final failure)) return Err(failure);
  return SessionSetSnapshot.create(
    id: row.id,
    sessionExerciseId: row.sessionExerciseId,
    setIndex: row.setIndex,
    plannedReps: (plannedReps as Ok<RepPrescription>).value,
    plannedLoad: (plannedLoad as Ok<LoadPrescription>).value,
    plannedRestSeconds: row.plannedRestSeconds,
    actual: (actual as Ok<ActualPrescription?>).value,
    rpe: row.rpe,
    completed: row.completed,
    completedAt: row.completedAt,
  );
}

Result<SessionExerciseSnapshot> mapSessionExerciseRow(
  SessionExerciseData row,
  List<SessionSetSnapshot> sets,
) {
  if (normalizeExerciseName(row.nameSnapshot) != row.normalizedName) {
    return const Err(ValidationFailure('Exercise normalized name is invalid.'));
  }
  final plannedReps = mapRepPrescriptionFields(
    repTypeWire: row.plannedRepType,
    targetReps: row.plannedTargetReps,
    minReps: row.plannedMinReps,
    maxReps: row.plannedMaxReps,
  );
  if (plannedReps case Err(:final failure)) return Err(failure);
  final plannedLoad = mapLoadPrescriptionFields(
    loadTypeWire: row.plannedLoadType,
    weightCanonicalMg: row.plannedWeightCanonicalMg,
    percentage: row.plannedPercentage,
    targetRpe: row.plannedTargetRpe,
    freeformText: row.plannedFreeformText,
  );
  if (plannedLoad case Err(:final failure)) return Err(failure);
  return SessionExerciseSnapshot.create(
    id: row.id,
    sessionId: row.sessionId,
    nameSnapshot: row.nameSnapshot,
    orderIndex: row.orderIndex,
    plannedSets: row.plannedSets,
    plannedReps: (plannedReps as Ok<RepPrescription>).value,
    plannedLoad: (plannedLoad as Ok<LoadPrescription>).value,
    plannedRestSeconds: row.plannedRestSeconds,
    supersetGroup: row.supersetGroup,
    sets: sets,
  );
}

Result<AbsoluteRestState?> mapSessionRestState(SessionData row) {
  final started = row.restStartedAt;
  final duration = row.restDurationSeconds;
  final target = row.restTargetAt;
  if (started == null && duration == null && target == null) {
    return const Ok(null);
  }
  if (started == null || duration == null || target == null) {
    return const Err(
      ValidationFailure('Rest fields must be present together or all absent.'),
    );
  }
  final expectedTarget = started.toUtc().add(Duration(seconds: duration));
  if (target.toUtc() != expectedTarget) {
    return const Err(
      ValidationFailure('Rest target does not match start and duration.'),
    );
  }
  return AbsoluteRestState.create(
    startedAt: started,
    durationSeconds: duration,
  );
}

Result<ActiveSession> mapSessionAggregate(
  SessionData row,
  List<SessionExerciseSnapshot> exercises,
) {
  final status = SessionStatus.fromWire(row.status);
  if (status case Err(:final failure)) return Err(failure);
  final rest = mapSessionRestState(row);
  if (rest case Err(:final failure)) return Err(failure);
  return ActiveSession.create(
    id: row.id,
    workoutId: row.workoutId,
    scheduleEntryId: row.scheduleEntryId,
    workoutNameSnapshot: row.workoutNameSnapshot,
    startedAt: row.startedAt,
    endedAt: row.endedAt,
    timezone: row.timezone,
    status: (status as Ok<SessionStatus>).value,
    notes: row.notes,
    rest: (rest as Ok<AbsoluteRestState?>).value,
    exercises: exercises,
  );
}

SessionSetCompanion actualPrescriptionCompanion(ActualPrescription actual) {
  final rep = actual.reps;
  final load = actual.load;
  return SessionSetCompanion(
    actualRepType: Value(rep.type.wireValue),
    actualTargetReps: Value(switch (rep) {
      FixedReps(:final reps) => reps,
      _ => null,
    }),
    actualMinReps: Value(switch (rep) {
      RepRange(:final min) => min,
      _ => null,
    }),
    actualMaxReps: Value(switch (rep) {
      RepRange(:final max) => max,
      _ => null,
    }),
    actualLoadType: Value(load.type.wireValue),
    actualWeightCanonicalMg: Value(switch (load) {
      AbsoluteLoad(:final milligrams) => milligrams,
      _ => null,
    }),
    actualPercentage: Value(switch (load) {
      PercentageLoad(:final percentage) => percentage,
      _ => null,
    }),
    actualTargetRpe: Value(switch (load) {
      TargetRpeLoad(:final rpe) => rpe,
      _ => null,
    }),
    actualFreeformText: Value(switch (load) {
      TextLoad(:final text) => text,
      _ => null,
    }),
  );
}

SessionCompanion clearRestCompanion() => const SessionCompanion(
  restStartedAt: Value(null),
  restDurationSeconds: Value(null),
  restTargetAt: Value(null),
);

SessionCompanion restStateCompanion(AbsoluteRestState rest) => SessionCompanion(
  restStartedAt: Value(rest.startedAt),
  restDurationSeconds: Value(rest.durationSeconds),
  restTargetAt: Value(rest.targetAt),
);
