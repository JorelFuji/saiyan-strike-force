// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:drift/drift.dart';

import '../../core/result.dart';
import '../../core/failure.dart';
import '../../domain/models/completed_session_summary.dart';
import '../../domain/models/exercise_history.dart';
import '../../domain/models/exercise_name.dart';
import '../database/app_database.dart';
import 'exercise_history_mapper.dart';
import 'session_history_mapper.dart';

/// Read-only completed-session and exercise-history SQL/mapping boundary.
final class SessionHistoryReader {
  SessionHistoryReader(this.database);
  final AppDatabase database;

  Stream<Result<List<CompletedSessionSummary>>> watchCompletedSummaries() {
    final query = database.customSelect(
      '''SELECT s.id AS id, s.workout_name_snapshot AS workout_name_snapshot, s.started_at AS started_at, s.ended_at AS ended_at, s.timezone AS timezone, COUNT(ss.id) AS total_set_count, COALESCE(SUM(CASE WHEN ss.completed = 1 THEN 1 ELSE 0 END), 0) AS completed_set_count, COALESCE(SUM(CASE WHEN ss.completed = 1 AND ss.actual_load_type = 'absolute' AND ss.actual_rep_type = 'fixed' AND ss.actual_weight_canonical_mg IS NOT NULL AND ss.actual_target_reps IS NOT NULL THEN ss.actual_weight_canonical_mg * ss.actual_target_reps ELSE 0 END), 0) AS absolute_volume_milligram_reps FROM session s LEFT JOIN session_exercise se ON se.session_id = s.id LEFT JOIN session_set ss ON ss.session_exercise_id = se.id WHERE s.status = 'finished' GROUP BY s.id, s.workout_name_snapshot, s.started_at, s.ended_at, s.timezone ORDER BY s.started_at DESC, s.id DESC''',
      readsFrom: {
        database.session,
        database.sessionExercise,
        database.sessionSet,
      },
    );
    return query.watch().asyncMap((rows) {
      try {
        final values = <CompletedSessionSummary>[];
        for (final row in rows) {
          final value = mapCompletedSessionSummaryRow(
            id: row.read('id'),
            workoutNameSnapshot: row.read('workout_name_snapshot'),
            startedAt: row.read('started_at'),
            endedAt: row.readNullable('ended_at'),
            timezone: row.read('timezone'),
            completedSetCount: row.read('completed_set_count'),
            totalSetCount: row.read('total_set_count'),
            absoluteVolumeMilligramReps: row.read(
              'absolute_volume_milligram_reps',
            ),
          );
          if (value case Err(:final failure)) {
            return Err<List<CompletedSessionSummary>>(failure);
          }
          values.add((value as Ok).value);
        }
        return Ok<List<CompletedSessionSummary>>(values);
      } on Exception catch (error, stack) {
        return Err<List<CompletedSessionSummary>>(
          StorageFailure(
            'Session storage operation failed.',
            cause: error,
            stackTrace: stack,
          ),
        );
      }
    });
  }

  Stream<Result<List<ExerciseHistoryEntry>>> watchExerciseHistory(
    ExerciseName name,
  ) {
    final query = database.customSelect(
      '''SELECT se.id AS session_exercise_id, se.session_id AS session_id, se.name_snapshot AS name_snapshot, se.normalized_name AS normalized_name, se.order_index AS order_index, s.started_at AS started_at, s.timezone AS timezone, ss.set_index AS set_index, ss.rpe AS rpe, ss.actual_rep_type AS actual_rep_type, ss.actual_target_reps AS actual_target_reps, ss.actual_min_reps AS actual_min_reps, ss.actual_max_reps AS actual_max_reps, ss.actual_load_type AS actual_load_type, ss.actual_weight_canonical_mg AS actual_weight_canonical_mg, ss.actual_percentage AS actual_percentage, ss.actual_target_rpe AS actual_target_rpe, ss.actual_freeform_text AS actual_freeform_text FROM session s INNER JOIN session_exercise se ON se.session_id = s.id INNER JOIN session_set ss ON ss.session_exercise_id = se.id WHERE s.status = 'finished' AND se.normalized_name = ? AND ss.completed = 1 ORDER BY s.started_at DESC, s.id DESC, se.order_index ASC, ss.set_index ASC''',
      variables: [Variable.withString(name.normalized)],
      readsFrom: {
        database.session,
        database.sessionExercise,
        database.sessionSet,
      },
    );
    return query.watch().asyncMap((rows) {
      try {
        final groups = <ExerciseHistoryRowGroup>[];
        ExerciseHistoryRowGroup? current;
        for (final row in rows) {
          final id = row.read<int>('session_exercise_id');
          if (current == null || current.sessionExerciseId != id) {
            current = ExerciseHistoryRowGroup(
              sessionExerciseId: id,
              sessionId: row.read('session_id'),
              nameSnapshot: row.read('name_snapshot'),
              normalizedName: row.read('normalized_name'),
              startedAt: row.read('started_at'),
              timezone: row.read('timezone'),
              sets: [],
            );
            groups.add(current);
          }
          current.sets.add(
            ExerciseHistorySetRow(
              setIndex: row.read('set_index'),
              actualRepTypeWire: row.readNullable('actual_rep_type'),
              actualTargetReps: row.readNullable('actual_target_reps'),
              actualMinReps: row.readNullable('actual_min_reps'),
              actualMaxReps: row.readNullable('actual_max_reps'),
              actualLoadTypeWire: row.readNullable('actual_load_type'),
              actualWeightCanonicalMg: row.readNullable(
                'actual_weight_canonical_mg',
              ),
              actualPercentage: row.readNullable('actual_percentage'),
              actualTargetRpe: row.readNullable('actual_target_rpe'),
              actualFreeformText: row.readNullable('actual_freeform_text'),
              rpe: row.readNullable('rpe'),
            ),
          );
        }
        return groupExerciseHistoryRows(groups);
      } on Exception catch (error, stack) {
        return Err<List<ExerciseHistoryEntry>>(
          StorageFailure(
            'Session storage operation failed.',
            cause: error,
            stackTrace: stack,
          ),
        );
      }
    });
  }
}
