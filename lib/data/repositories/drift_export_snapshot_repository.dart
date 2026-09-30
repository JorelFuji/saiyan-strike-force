import 'package:drift/drift.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/export_document.dart';
import '../../domain/models/prescriptions.dart';
import '../../domain/models/schedule_status.dart';
import '../../domain/models/session_status.dart';
import '../../domain/repositories/export_snapshot_repository.dart';
import '../database/app_database.dart';

final class DriftExportSnapshotRepository implements ExportSnapshotRepository {
  DriftExportSnapshotRepository(this.database);
  final AppDatabase database;

  @override
  Future<Result<ExportCollections>> readSnapshot() async {
    try {
      return await database.transaction(() async {
        // All reads use the transaction's executor to provide one SQLite view.
        final settings = await (database.select(
          database.settings,
        )..orderBy([(t) => OrderingTerm.asc(t.key)])).get();
        final workouts = await (database.select(
          database.workout,
        )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
        final workoutExercises =
            await (database.select(database.workoutExercise)..orderBy([
                  (t) => OrderingTerm.asc(t.workoutId),
                  (t) => OrderingTerm.asc(t.orderIndex),
                  (t) => OrderingTerm.asc(t.id),
                ]))
                .get();
        final schedules = await (database.select(
          database.scheduleEntry,
        )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
        final sessions = await (database.select(
          database.session,
        )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
        final sessionExercises =
            await (database.select(database.sessionExercise)..orderBy([
                  (t) => OrderingTerm.asc(t.sessionId),
                  (t) => OrderingTerm.asc(t.orderIndex),
                  (t) => OrderingTerm.asc(t.id),
                ]))
                .get();
        final sessionSets =
            await (database.select(database.sessionSet)..orderBy([
                  (t) => OrderingTerm.asc(t.sessionExerciseId),
                  (t) => OrderingTerm.asc(t.setIndex),
                  (t) => OrderingTerm.asc(t.id),
                ]))
                .get();
        for (final row in workoutExercises) {
          _valid(RepType.fromWire(row.repType));
          _valid(LoadType.fromWire(row.loadType));
        }
        for (final row in sessionExercises) {
          _valid(RepType.fromWire(row.plannedRepType));
          _valid(LoadType.fromWire(row.plannedLoadType));
        }
        for (final row in sessionSets) {
          _valid(RepType.fromWire(row.plannedRepType));
          _valid(LoadType.fromWire(row.plannedLoadType));
          if (row.actualRepType case final value?) {
            _valid(RepType.fromWire(value));
          }
          if (row.actualLoadType case final value?) {
            _valid(LoadType.fromWire(value));
          }
        }
        for (final row in sessions) {
          _valid(SessionStatus.fromWire(row.status));
        }
        for (final row in schedules) {
          _valid(ScheduleStatus.fromWire(row.status));
        }
        return Ok(
          ExportCollections(
            settings: settings
                .map((r) => {'key': r.key, 'value': r.value})
                .toList(),
            workouts: workouts
                .map(
                  (r) => {
                    'id': r.id,
                    'name': r.name,
                    'notes': r.notes,
                    'createdAt': _instant(r.createdAt),
                    'archivedAt': _instant(r.archivedAt),
                  },
                )
                .toList(),
            workoutExercises: workoutExercises
                .map(
                  (r) => {
                    'id': r.id,
                    'workoutId': r.workoutId,
                    'name': r.name,
                    'normalizedName': r.normalizedName,
                    'orderIndex': r.orderIndex,
                    'plannedSets': r.plannedSets,
                    'repType': r.repType,
                    'targetReps': r.targetReps,
                    'minReps': r.minReps,
                    'maxReps': r.maxReps,
                    'loadType': r.loadType,
                    'weightCanonicalMg': r.weightCanonicalMg,
                    'percentage': r.percentage,
                    'targetRpe': r.targetRpe,
                    'freeformText': r.freeformText,
                    'restSeconds': r.restSeconds,
                    'supersetGroup': r.supersetGroup,
                  },
                )
                .toList(),
            scheduleEntries: schedules
                .map(
                  (r) => {
                    'id': r.id,
                    'workoutId': r.workoutId,
                    'date': r.date,
                    'startTime': r.startTime,
                    'label': r.label,
                    'status': r.status,
                    'sessionId': r.sessionId,
                  },
                )
                .toList(),
            sessions: sessions
                .map(
                  (r) => {
                    'id': r.id,
                    'workoutId': r.workoutId,
                    'scheduleEntryId': r.scheduleEntryId,
                    'workoutNameSnapshot': r.workoutNameSnapshot,
                    'startedAt': _instant(r.startedAt),
                    'endedAt': _instant(r.endedAt),
                    'timezone': r.timezone,
                    'status': r.status,
                    'notes': r.notes,
                    'restStartedAt': _instant(r.restStartedAt),
                    'restDurationSeconds': r.restDurationSeconds,
                    'restTargetAt': _instant(r.restTargetAt),
                  },
                )
                .toList(),
            sessionExercises: sessionExercises
                .map(
                  (r) => {
                    'id': r.id,
                    'sessionId': r.sessionId,
                    'nameSnapshot': r.nameSnapshot,
                    'normalizedName': r.normalizedName,
                    'orderIndex': r.orderIndex,
                    'plannedSets': r.plannedSets,
                    'plannedRepType': r.plannedRepType,
                    'plannedTargetReps': r.plannedTargetReps,
                    'plannedMinReps': r.plannedMinReps,
                    'plannedMaxReps': r.plannedMaxReps,
                    'plannedLoadType': r.plannedLoadType,
                    'plannedWeightCanonicalMg': r.plannedWeightCanonicalMg,
                    'plannedPercentage': r.plannedPercentage,
                    'plannedTargetRpe': r.plannedTargetRpe,
                    'plannedFreeformText': r.plannedFreeformText,
                    'plannedRestSeconds': r.plannedRestSeconds,
                    'supersetGroup': r.supersetGroup,
                  },
                )
                .toList(),
            sessionSets: sessionSets
                .map(
                  (r) => {
                    'id': r.id,
                    'sessionExerciseId': r.sessionExerciseId,
                    'setIndex': r.setIndex,
                    'plannedRepType': r.plannedRepType,
                    'plannedTargetReps': r.plannedTargetReps,
                    'plannedMinReps': r.plannedMinReps,
                    'plannedMaxReps': r.plannedMaxReps,
                    'plannedLoadType': r.plannedLoadType,
                    'plannedWeightCanonicalMg': r.plannedWeightCanonicalMg,
                    'plannedPercentage': r.plannedPercentage,
                    'plannedTargetRpe': r.plannedTargetRpe,
                    'plannedFreeformText': r.plannedFreeformText,
                    'actualRepType': r.actualRepType,
                    'actualTargetReps': r.actualTargetReps,
                    'actualMinReps': r.actualMinReps,
                    'actualMaxReps': r.actualMaxReps,
                    'actualLoadType': r.actualLoadType,
                    'actualWeightCanonicalMg': r.actualWeightCanonicalMg,
                    'actualPercentage': r.actualPercentage,
                    'actualTargetRpe': r.actualTargetRpe,
                    'actualFreeformText': r.actualFreeformText,
                    'rpe': r.rpe,
                    'completed': r.completed,
                    'completedAt': _instant(r.completedAt),
                  },
                )
                .toList(),
          ),
        );
      });
    } on FormatException catch (error, stackTrace) {
      return Err(
        ValidationFailure(
          'Stored data cannot be exported.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } catch (error, stackTrace) {
      return Err(
        StorageFailure(
          'Unable to read data for export.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  void _valid<T>(Result<T> result) {
    if (result case Err(:final failure)) {
      throw FormatException(failure.message);
    }
  }

  String? _instant(DateTime? value) => value?.toUtc().toIso8601String();
}
