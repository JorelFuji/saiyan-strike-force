import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/active_session.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/exercise_history.dart';
import 'session_history_mapper.dart';
import 'session_snapshot_mapper.dart';

/// Maps one exercise-history SQL row into a partial set value.
Result<ExerciseHistoryCompletedSet> mapExerciseHistorySetRow({
  required int setIndex,
  required String? actualRepTypeWire,
  int? actualTargetReps,
  int? actualMinReps,
  int? actualMaxReps,
  required String? actualLoadTypeWire,
  int? actualWeightCanonicalMg,
  int? actualPercentage,
  double? actualTargetRpe,
  String? actualFreeformText,
  double? rpe,
}) {
  final actual = mapOptionalActualPrescription(
    repTypeWire: actualRepTypeWire,
    targetReps: actualTargetReps,
    minReps: actualMinReps,
    maxReps: actualMaxReps,
    loadTypeWire: actualLoadTypeWire,
    weightCanonicalMg: actualWeightCanonicalMg,
    percentage: actualPercentage,
    targetRpe: actualTargetRpe,
    freeformText: actualFreeformText,
  );
  if (actual case Err(:final failure)) {
    return Err(failure);
  }
  final prescription = (actual as Ok<ActualPrescription?>).value;
  if (prescription == null) {
    return const Err(
      ValidationFailure('Completed sets require logged actual values.'),
    );
  }
  return ExerciseHistoryCompletedSet.create(
    setIndex: setIndex,
    actual: prescription,
    rpe: rpe,
  );
}

/// Groups flat query rows (already ordered) into exercise-history entries.
Result<List<ExerciseHistoryEntry>> groupExerciseHistoryRows(
  List<ExerciseHistoryRowGroup> groups,
) {
  final entries = <ExerciseHistoryEntry>[];
  for (final group in groups) {
    final sets = <ExerciseHistoryCompletedSet>[];
    for (final setRow in group.sets) {
      final mapped = mapExerciseHistorySetRow(
        setIndex: setRow.setIndex,
        actualRepTypeWire: setRow.actualRepTypeWire,
        actualTargetReps: setRow.actualTargetReps,
        actualMinReps: setRow.actualMinReps,
        actualMaxReps: setRow.actualMaxReps,
        actualLoadTypeWire: setRow.actualLoadTypeWire,
        actualWeightCanonicalMg: setRow.actualWeightCanonicalMg,
        actualPercentage: setRow.actualPercentage,
        actualTargetRpe: setRow.actualTargetRpe,
        actualFreeformText: setRow.actualFreeformText,
        rpe: setRow.rpe,
      );
      if (mapped case Err(:final failure)) {
        return Err(failure);
      }
      sets.add((mapped as Ok<ExerciseHistoryCompletedSet>).value);
    }
    final startedOn = calendarDateInSessionZone(
      startedAtUtc: group.startedAt,
      ianaTimezone: group.timezone,
    );
    if (startedOn case Err(:final failure)) {
      return Err(failure);
    }
    final entry = ExerciseHistoryEntry.create(
      sessionExerciseId: group.sessionExerciseId,
      sessionId: group.sessionId,
      nameSnapshot: group.nameSnapshot,
      normalizedName: group.normalizedName,
      startedAt: group.startedAt,
      sessionOn: (startedOn as Ok<CalendarDate>).value,
      completedSets: sets,
    );
    if (entry case Err(:final failure)) {
      return Err(failure);
    }
    entries.add((entry as Ok<ExerciseHistoryEntry>).value);
  }
  return Ok(entries);
}

/// Intermediate grouping container for one session-exercise instance.
final class ExerciseHistoryRowGroup {
  const ExerciseHistoryRowGroup({
    required this.sessionExerciseId,
    required this.sessionId,
    required this.nameSnapshot,
    required this.normalizedName,
    required this.startedAt,
    required this.timezone,
    required this.sets,
  });

  final int sessionExerciseId;
  final int sessionId;
  final String nameSnapshot;
  final String normalizedName;
  final DateTime startedAt;
  final String timezone;
  final List<ExerciseHistorySetRow> sets;
}

final class ExerciseHistorySetRow {
  const ExerciseHistorySetRow({
    required this.setIndex,
    required this.actualRepTypeWire,
    this.actualTargetReps,
    this.actualMinReps,
    this.actualMaxReps,
    required this.actualLoadTypeWire,
    this.actualWeightCanonicalMg,
    this.actualPercentage,
    this.actualTargetRpe,
    this.actualFreeformText,
    this.rpe,
  });

  final int setIndex;
  final String? actualRepTypeWire;
  final int? actualTargetReps;
  final int? actualMinReps;
  final int? actualMaxReps;
  final String? actualLoadTypeWire;
  final int? actualWeightCanonicalMg;
  final int? actualPercentage;
  final double? actualTargetRpe;
  final String? actualFreeformText;
  final double? rpe;
}
