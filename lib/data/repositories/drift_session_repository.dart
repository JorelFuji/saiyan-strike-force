import 'package:drift/drift.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/active_session.dart';
import '../../domain/models/completed_session_summary.dart';
import '../../domain/models/exercise_history.dart';
import '../../domain/models/exercise_name.dart';
import '../../domain/models/prescriptions.dart';
import '../../domain/models/session_status.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/usecases/start_session.dart';
import '../database/app_database.dart';
import 'exercise_history_mapper.dart';
import 'session_history_mapper.dart';
import 'session_snapshot_mapper.dart';
import 'session_storage_retry.dart';
import 'workout_exercise_mapper.dart';

final class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository(this.database, {SessionStorageRetry? storageRetry})
    : _storageRetry = storageRetry ?? SessionStorageRetry();

  final AppDatabase database;
  final SessionStorageRetry _storageRetry;

  @override
  Future<Result<ActiveSession>> getById(int sessionId) async {
    try {
      return await _loadAggregate(sessionId);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Stream<Result<ActiveSession>> watchById(int sessionId) {
    final trigger = database.customSelect(
      '''
SELECT s.id
FROM session s
LEFT JOIN session_exercise se ON se.session_id = s.id
LEFT JOIN session_set ss ON ss.session_exercise_id = se.id
WHERE s.id = ?
''',
      variables: [Variable.withInt(sessionId)],
      readsFrom: {
        database.session,
        database.sessionExercise,
        database.sessionSet,
      },
    );
    return (() async* {
      yield await getById(sessionId);
      try {
        await for (final _ in trigger.watch()) {
          yield await getById(sessionId);
        }
      } on _RepositoryFailure catch (error) {
        yield Err<ActiveSession>(error.failure);
      } on Exception catch (error, stack) {
        yield Err<ActiveSession>(_storageFailure(error, stack));
      }
    })();
  }

  @override
  Stream<Result<List<CompletedSessionSummary>>> watchCompletedSummaries() {
    final query = database.customSelect(
      '''
SELECT
  s.id AS id,
  s.workout_name_snapshot AS workout_name_snapshot,
  s.started_at AS started_at,
  s.ended_at AS ended_at,
  s.timezone AS timezone,
  COUNT(ss.id) AS total_set_count,
  COALESCE(SUM(CASE WHEN ss.completed = 1 THEN 1 ELSE 0 END), 0)
    AS completed_set_count,
  COALESCE(SUM(
    CASE
      WHEN ss.completed = 1
        AND ss.actual_load_type = 'absolute'
        AND ss.actual_rep_type = 'fixed'
        AND ss.actual_weight_canonical_mg IS NOT NULL
        AND ss.actual_target_reps IS NOT NULL
      THEN ss.actual_weight_canonical_mg * ss.actual_target_reps
      ELSE 0
    END
  ), 0) AS absolute_volume_milligram_reps
FROM session s
LEFT JOIN session_exercise se ON se.session_id = s.id
LEFT JOIN session_set ss ON ss.session_exercise_id = se.id
WHERE s.status = 'finished'
GROUP BY s.id, s.workout_name_snapshot, s.started_at, s.ended_at, s.timezone
ORDER BY s.started_at DESC, s.id DESC
''',
      readsFrom: {
        database.session,
        database.sessionExercise,
        database.sessionSet,
      },
    );

    return query.watch().asyncMap((rows) async {
      try {
        final values = <CompletedSessionSummary>[];
        for (final row in rows) {
          final mapped = mapCompletedSessionSummaryRow(
            id: row.read<int>('id'),
            workoutNameSnapshot: row.read<String>('workout_name_snapshot'),
            startedAt: row.read<DateTime>('started_at'),
            endedAt: row.readNullable<DateTime>('ended_at'),
            timezone: row.read<String>('timezone'),
            completedSetCount: row.read<int>('completed_set_count'),
            totalSetCount: row.read<int>('total_set_count'),
            absoluteVolumeMilligramReps: row.read<int>(
              'absolute_volume_milligram_reps',
            ),
          );
          if (mapped case Err(:final failure)) {
            return Err<List<CompletedSessionSummary>>(failure);
          }
          values.add((mapped as Ok<CompletedSessionSummary>).value);
        }
        return Ok<List<CompletedSessionSummary>>(values);
      } on Exception catch (error, stack) {
        return Err<List<CompletedSessionSummary>>(
          _storageFailure(error, stack),
        );
      }
    });
  }

  @override
  Stream<Result<List<ExerciseHistoryEntry>>> watchExerciseHistory(
    ExerciseName exerciseName,
  ) {
    final normalized = exerciseName.normalized;
    final query = database.customSelect(
      '''
SELECT
  se.id AS session_exercise_id,
  se.session_id AS session_id,
  se.name_snapshot AS name_snapshot,
  se.normalized_name AS normalized_name,
  se.order_index AS order_index,
  s.started_at AS started_at,
  s.timezone AS timezone,
  ss.set_index AS set_index,
  ss.rpe AS rpe,
  ss.actual_rep_type AS actual_rep_type,
  ss.actual_target_reps AS actual_target_reps,
  ss.actual_min_reps AS actual_min_reps,
  ss.actual_max_reps AS actual_max_reps,
  ss.actual_load_type AS actual_load_type,
  ss.actual_weight_canonical_mg AS actual_weight_canonical_mg,
  ss.actual_percentage AS actual_percentage,
  ss.actual_target_rpe AS actual_target_rpe,
  ss.actual_freeform_text AS actual_freeform_text
FROM session s
INNER JOIN session_exercise se ON se.session_id = s.id
INNER JOIN session_set ss ON ss.session_exercise_id = se.id
WHERE s.status = 'finished'
  AND se.normalized_name = ?
  AND ss.completed = 1
ORDER BY s.started_at DESC, s.id DESC, se.order_index ASC, ss.set_index ASC
''',
      variables: [Variable.withString(normalized)],
      readsFrom: {
        database.session,
        database.sessionExercise,
        database.sessionSet,
      },
    );

    return query.watch().asyncMap((rows) async {
      try {
        final groups = <ExerciseHistoryRowGroup>[];
        ExerciseHistoryRowGroup? current;
        for (final row in rows) {
          final sessionExerciseId = row.read<int>('session_exercise_id');
          if (current == null ||
              current.sessionExerciseId != sessionExerciseId) {
            current = ExerciseHistoryRowGroup(
              sessionExerciseId: sessionExerciseId,
              sessionId: row.read<int>('session_id'),
              nameSnapshot: row.read<String>('name_snapshot'),
              normalizedName: row.read<String>('normalized_name'),
              startedAt: row.read<DateTime>('started_at'),
              timezone: row.read<String>('timezone'),
              sets: [],
            );
            groups.add(current);
          }
          current.sets.add(
            ExerciseHistorySetRow(
              setIndex: row.read<int>('set_index'),
              actualRepTypeWire: row.readNullable<String>('actual_rep_type'),
              actualTargetReps: row.readNullable<int>('actual_target_reps'),
              actualMinReps: row.readNullable<int>('actual_min_reps'),
              actualMaxReps: row.readNullable<int>('actual_max_reps'),
              actualLoadTypeWire: row.readNullable<String>('actual_load_type'),
              actualWeightCanonicalMg: row.readNullable<int>(
                'actual_weight_canonical_mg',
              ),
              actualPercentage: row.readNullable<int>('actual_percentage'),
              actualTargetRpe: row.readNullable<double>('actual_target_rpe'),
              actualFreeformText: row.readNullable<String>(
                'actual_freeform_text',
              ),
              rpe: row.readNullable<double>('rpe'),
            ),
          );
        }
        return groupExerciseHistoryRows(groups);
      } on Exception catch (error, stack) {
        return Err<List<ExerciseHistoryEntry>>(_storageFailure(error, stack));
      }
    });
  }

  @override
  Future<Result<int?>> findResumableSessionId() async {
    try {
      final rows =
          await (database.select(database.session)..where(
                (row) =>
                    row.status.equals('running') | row.status.equals('paused'),
              ))
              .get();
      if (rows.isEmpty) {
        return const Ok(null);
      }
      if (rows.length > 1) {
        return const Err(
          ValidationFailure('Multiple active sessions were found in storage.'),
        );
      }
      return Ok(rows.single.id);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> saveSetActualValues(
    SaveSetActualValuesCommand command,
  ) async {
    try {
      await _storageRetry.run(
        () => database.transaction(() async {
          final context = await _requireMutableSetContext(
            sessionId: command.sessionId,
            setId: command.setId,
          );
          await (database.update(
            database.sessionSet,
          )..where((row) => row.id.equals(context.set.id))).write(
            actualPrescriptionCompanion(command.actual)
                .copyWith(rpe: Value(command.rpe)),
          );
        }),
      );
      return const Ok(null);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> completeSet(CompleteSetCommand command) async {
    try {
      await _storageRetry.run(
        () => database.transaction(() async {
          final context = await _requireMutableSetContext(
            sessionId: command.sessionId,
            setId: command.setId,
            allowCompleted: true,
          );
          if (context.set.completed) {
            if (!_completionMatches(context.set, command)) {
              throw const _RepositoryFailure(
                ValidationFailure('Set completion conflicts with stored data.'),
              );
            }
            if (!_restMatches(context.session, command.rest)) {
              throw const _RepositoryFailure(
                ValidationFailure('Set completion conflicts with stored data.'),
              );
            }
            return;
          }
          await (database.update(
            database.sessionSet,
          )..where((row) => row.id.equals(context.set.id))).write(
            actualPrescriptionCompanion(command.actual).copyWith(
              rpe: Value(command.rpe),
              completed: const Value(true),
              completedAt: Value(command.completedAt),
            ),
          );
          final restCompanion = switch (command.rest) {
            final rest? => restStateCompanion(rest),
            null => clearRestCompanion(),
          };
          await (database.update(database.session)
                ..where((row) => row.id.equals(context.session.id)))
              .write(restCompanion);
        }),
      );
      return const Ok(null);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> updateSessionRest(
    UpdateSessionRestCommand command,
  ) async {
    try {
      await _storageRetry.run(
        () => database.transaction(() async {
          await _requireMutableSession(command.sessionId);
          await (database.update(database.session)
                ..where((row) => row.id.equals(command.sessionId)))
              .write(restStateCompanion(command.rest));
        }),
      );
      return const Ok(null);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> clearSessionRest(ClearSessionRestCommand command) async {
    try {
      await _storageRetry.run(
        () => database.transaction(() async {
          await _requireMutableSession(command.sessionId);
          await (database.update(database.session)
                ..where((row) => row.id.equals(command.sessionId)))
              .write(clearRestCompanion());
        }),
      );
      return const Ok(null);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> updateSessionNotes(
    UpdateSessionNotesCommand command,
  ) async {
    try {
      await _storageRetry.run(
        () => database.transaction(() async {
          await _requireMutableSession(command.sessionId);
          await (database.update(database.session)
                ..where((row) => row.id.equals(command.sessionId)))
              .write(SessionCompanion(notes: Value(command.notes)));
        }),
      );
      return const Ok(null);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> pauseSession(PauseSessionCommand command) async {
    try {
      await _storageRetry.run(
        () => database.transaction(() async {
          final session = await _requireMutableSession(
            command.sessionId,
            expectedStatus: command.currentStatus,
          );
          _requireTransition(_sessionStatus(session), SessionStatus.paused);
          await (database.update(
            database.session,
          )..where((row) => row.id.equals(session.id))).write(
            SessionCompanion(
              status: Value(SessionStatus.paused.wireValue),
              restStartedAt: const Value(null),
              restDurationSeconds: const Value(null),
              restTargetAt: const Value(null),
            ),
          );
        }),
      );
      return const Ok(null);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> continueSession(ContinueSessionCommand command) async {
    try {
      await _storageRetry.run(
        () => database.transaction(() async {
          final session = await _requireMutableSession(
            command.sessionId,
            expectedStatus: command.currentStatus,
          );
          _requireTransition(_sessionStatus(session), SessionStatus.running);
          await (database.update(
            database.session,
          )..where((row) => row.id.equals(session.id))).write(
            SessionCompanion(status: Value(SessionStatus.running.wireValue)),
          );
        }),
      );
      return const Ok(null);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> finishSession(FinishSessionCommand command) async {
    try {
      await _storageRetry.run(
        () => database.transaction(() async {
          final session = await _requireMutableSession(
            command.sessionId,
            expectedStatus: command.currentStatus,
          );
          _requireTransition(_sessionStatus(session), SessionStatus.finished);
          await (database.update(
            database.session,
          )..where((row) => row.id.equals(session.id))).write(
            SessionCompanion(
              status: Value(SessionStatus.finished.wireValue),
              endedAt: Value(command.endedAt),
              restStartedAt: const Value(null),
              restDurationSeconds: const Value(null),
              restTargetAt: const Value(null),
            ),
          );
          if (session.scheduleEntryId case final scheduleId?) {
            await (database.update(
              database.scheduleEntry,
            )..where((row) => row.id.equals(scheduleId))).write(
              ScheduleEntryCompanion(
                status: const Value('completed_by_session'),
                sessionId: Value(session.id),
              ),
            );
          }
        }),
      );
      return const Ok(null);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> abandonSession(AbandonSessionCommand command) async {
    try {
      await _storageRetry.run(
        () => database.transaction(() async {
          final session = await _requireMutableSession(
            command.sessionId,
            expectedStatus: command.currentStatus,
          );
          _requireTransition(_sessionStatus(session), SessionStatus.abandoned);
          await (database.update(
            database.session,
          )..where((row) => row.id.equals(session.id))).write(
            SessionCompanion(
              status: Value(SessionStatus.abandoned.wireValue),
              endedAt: Value(command.endedAt),
              restStartedAt: const Value(null),
              restDurationSeconds: const Value(null),
              restTargetAt: const Value(null),
            ),
          );
        }),
      );
      return const Ok(null);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<int>> startFreestyle(
    StartFreestyleSessionCommand command,
  ) async {
    try {
      final id = await _storageRetry.run(
        () => database.transaction(() async {
          await _requireNoActiveSession();
          return database
              .into(database.session)
              .insert(
                SessionCompanion.insert(
                  workoutId: const Value(null),
                  scheduleEntryId: const Value(null),
                  workoutNameSnapshot: 'Freestyle Workout',
                  startedAt: command.startedAt.toUtc(),
                  timezone: command.timezone,
                  status: SessionStatus.running.wireValue,
                ),
              );
        }),
      );
      return Ok(id);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<int>> addExercise(AddSessionExerciseCommand command) async {
    try {
      final id = await _storageRetry.run(
        () => database.transaction(() async {
          await _requireMutableSession(command.sessionId);
          final order = await _nextExerciseOrder(command.sessionId);
          final exerciseId = await database
              .into(database.sessionExercise)
              .insert(
                _exerciseCompanion(
                  sessionId: command.sessionId,
                  name: command.name,
                  orderIndex: order,
                  plannedSets: command.initialSetCount,
                  reps: command.reps,
                  load: command.load,
                  restSeconds: command.restSeconds,
                ),
              );
          await database.batch((batch) {
            batch.insertAll(database.sessionSet, [
              for (var index = 0; index < command.initialSetCount; index++)
                _setCompanion(
                  exerciseId: exerciseId,
                  setIndex: index,
                  reps: command.reps,
                  load: command.load,
                ),
            ]);
          });
          return exerciseId;
        }),
      );
      return Ok(id);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<int>> addSet(AddSessionSetCommand command) async {
    try {
      final id = await _storageRetry.run(
        () => database.transaction(() async {
          await _requireMutableSession(command.sessionId);
          final exercise =
              await (database.select(database.sessionExercise)
                    ..where((row) => row.id.equals(command.exerciseId)))
                  .getSingleOrNull();
          if (exercise == null) {
            throw const _RepositoryFailure(
              NotFoundFailure('Session exercise was not found.'),
            );
          }
          if (exercise.sessionId != command.sessionId) {
            throw const _RepositoryFailure(
              ValidationFailure('Exercise does not belong to this session.'),
            );
          }
          final reps = mapRepPrescriptionFields(
            repTypeWire: exercise.plannedRepType,
            targetReps: exercise.plannedTargetReps,
            minReps: exercise.plannedMinReps,
            maxReps: exercise.plannedMaxReps,
          );
          final load = mapLoadPrescriptionFields(
            loadTypeWire: exercise.plannedLoadType,
            weightCanonicalMg: exercise.plannedWeightCanonicalMg,
            percentage: exercise.plannedPercentage,
            targetRpe: exercise.plannedTargetRpe,
            freeformText: exercise.plannedFreeformText,
          );
          if (reps case Err(:final failure)) throw _RepositoryFailure(failure);
          if (load case Err(:final failure)) throw _RepositoryFailure(failure);
          final maxIndex = database.sessionSet.setIndex.max();
          final query = database.selectOnly(database.sessionSet)
            ..addColumns([maxIndex])
            ..where(database.sessionSet.sessionExerciseId.equals(exercise.id));
          final row = await query.getSingle();
          final nextIndex = (row.read(maxIndex) ?? -1) + 1;
          return database
              .into(database.sessionSet)
              .insert(
                _setCompanion(
                  exerciseId: exercise.id,
                  setIndex: nextIndex,
                  reps: (reps as Ok<RepPrescription>).value,
                  load: (load as Ok<LoadPrescription>).value,
                ),
              );
        }),
      );
      return Ok(id);
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<int>> startFromTemplate(StartSessionCommand command) async {
    try {
      return Ok(
        await _storageRetry.run(
          () => database.transaction(() async {
            await _requireNoActiveSession();
            final workout =
                await (database.select(database.workout)
                      ..where((row) => row.id.equals(command.workoutId)))
                    .getSingleOrNull();
            if (workout == null) {
              throw const _RepositoryFailure(
                NotFoundFailure('Workout template was not found.'),
              );
            }
            final sourceRows =
                await (database.select(database.workoutExercise)
                      ..where((row) => row.workoutId.equals(command.workoutId))
                      ..orderBy([(row) => OrderingTerm.asc(row.orderIndex)]))
                    .get();
            final sourceIds = sourceRows.map((row) => row.id).toList();
            final sourceSets = sourceIds.isEmpty
                ? <WorkoutSetData>[]
                : await (database.select(database.workoutSet)
                        ..where((set) => set.workoutExerciseId.isIn(sourceIds))
                        ..orderBy([
                          (set) => OrderingTerm.asc(set.workoutExerciseId),
                          (set) => OrderingTerm.asc(set.setIndex),
                        ]))
                      .get();
            final setsByExercise = <int, List<WorkoutSetData>>{};
            for (final set in sourceSets) {
              setsByExercise
                  .putIfAbsent(set.workoutExerciseId, () => [])
                  .add(set);
            }
            final exercises = <WorkoutExerciseData>[];
            for (final row in sourceRows) {
              final result = mapWorkoutExercise(
                row,
                setsByExercise[row.id] ?? [],
              );
              if (result case Err(:final failure)) {
                throw _RepositoryFailure(failure);
              }
              exercises.add(row);
            }
            if (command.scheduleEntryId case final scheduleId?) {
              final schedule = await (database.select(
                database.scheduleEntry,
              )..where((row) => row.id.equals(scheduleId))).getSingleOrNull();
              if (schedule == null) {
                throw const _RepositoryFailure(
                  NotFoundFailure('Schedule entry was not found.'),
                );
              }
              if (schedule.workoutId != command.workoutId ||
                  schedule.status != 'planned' ||
                  schedule.sessionId != null) {
                throw const _RepositoryFailure(
                  ValidationFailure(
                    'Schedule entry cannot start this workout.',
                  ),
                );
              }
            }
            final status = SessionStatus.running.wireValue;
            final sessionId = await database
                .into(database.session)
                .insert(
                  SessionCompanion.insert(
                    workoutId: Value(command.workoutId),
                    scheduleEntryId: Value(command.scheduleEntryId),
                    workoutNameSnapshot: workout.name,
                    startedAt: command.startedAt.toUtc(),
                    timezone: command.timezone,
                    status: status,
                  ),
                );
            for (var order = 0; order < exercises.length; order++) {
              final row = exercises[order];
              final exerciseId = await database
                  .into(database.sessionExercise)
                  .insert(
                    SessionExerciseCompanion.insert(
                      sessionId: sessionId,
                      nameSnapshot: row.name,
                      normalizedName: row.normalizedName,
                      orderIndex: order,
                      plannedSets: row.plannedSets,
                      plannedRepType: row.repType,
                      plannedTargetReps: Value(row.targetReps),
                      plannedMinReps: Value(row.minReps),
                      plannedMaxReps: Value(row.maxReps),
                      plannedLoadType: row.loadType,
                      plannedWeightCanonicalMg: Value(row.weightCanonicalMg),
                      plannedPercentage: Value(row.percentage),
                      plannedTargetRpe: Value(row.targetRpe),
                      plannedFreeformText: Value(row.freeformText),
                      plannedRestSeconds: row.restSeconds,
                      supersetGroup: Value(row.supersetGroup),
                    ),
                  );
              final templateSets = setsByExercise[row.id]!;
              const setBatchSize = 256;
              for (
                var offset = 0;
                offset < templateSets.length;
                offset += setBatchSize
              ) {
                final end = (offset + setBatchSize).clamp(
                  0,
                  templateSets.length,
                );
                final sets = [
                  for (var index = offset; index < end; index++)
                    _templateSetCompanion(exerciseId, templateSets[index]),
                ];
                await database.batch(
                  (batch) => batch.insertAll(database.sessionSet, sets),
                );
              }
            }
            return sessionId;
          }),
        ),
      );
    } on _RepositoryFailure catch (error) {
      return Err(error.failure);
    } on StorageFailure catch (error) {
      return Err(error);
    } on Exception catch (error, stack) {
      return Err(
        StorageFailure(
          'Session snapshot could not be saved.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<ActiveSession>> _loadAggregate(int sessionId) async {
    final row = await (database.select(
      database.session,
    )..where((table) => table.id.equals(sessionId))).getSingleOrNull();
    if (row == null) {
      return const Err(NotFoundFailure('Session was not found.'));
    }
    final exerciseRows =
        await (database.select(database.sessionExercise)
              ..where((table) => table.sessionId.equals(sessionId))
              ..orderBy([(table) => OrderingTerm.asc(table.orderIndex)]))
            .get();
    final exercises = <SessionExerciseSnapshot>[];
    for (final exerciseRow in exerciseRows) {
      final setRows =
          await (database.select(database.sessionSet)
                ..where(
                  (table) => table.sessionExerciseId.equals(exerciseRow.id),
                )
                ..orderBy([(table) => OrderingTerm.asc(table.setIndex)]))
              .get();
      final sets = <SessionSetSnapshot>[];
      for (final setRow in setRows) {
        final mapped = mapSessionSetRow(setRow);
        if (mapped case Err(:final failure)) {
          return Err(failure);
        }
        sets.add((mapped as Ok<SessionSetSnapshot>).value);
      }
      final mappedExercise = mapSessionExerciseRow(exerciseRow, sets);
      if (mappedExercise case Err(:final failure)) {
        return Err(failure);
      }
      exercises.add((mappedExercise as Ok<SessionExerciseSnapshot>).value);
    }
    return mapSessionAggregate(row, exercises);
  }

  Future<void> _requireNoActiveSession() async {
    final active =
        await (database.select(database.session)..where(
              (row) =>
                  row.status.equals('running') | row.status.equals('paused'),
            ))
            .get();
    if (active.isNotEmpty) {
      throw const _RepositoryFailure(
        ValidationFailure('An active session is already in progress.'),
      );
    }
  }

  Future<int> _nextExerciseOrder(int sessionId) async {
    final maximum = database.sessionExercise.orderIndex.max();
    final query = database.selectOnly(database.sessionExercise)
      ..addColumns([maximum])
      ..where(database.sessionExercise.sessionId.equals(sessionId));
    final row = await query.getSingle();
    return (row.read(maximum) ?? -1) + 1;
  }

  SessionExerciseCompanion _exerciseCompanion({
    required int sessionId,
    required ExerciseName name,
    required int orderIndex,
    required int plannedSets,
    required RepPrescription reps,
    required LoadPrescription load,
    required int restSeconds,
  }) {
    final repFields = _repFields(reps);
    final loadFields = _loadFields(load);
    return SessionExerciseCompanion.insert(
      sessionId: sessionId,
      nameSnapshot: name.display,
      normalizedName: name.normalized,
      orderIndex: orderIndex,
      plannedSets: plannedSets,
      plannedRepType: reps.type.wireValue,
      plannedTargetReps: Value(repFields.target),
      plannedMinReps: Value(repFields.min),
      plannedMaxReps: Value(repFields.max),
      plannedLoadType: load.type.wireValue,
      plannedWeightCanonicalMg: Value(loadFields.milligrams),
      plannedPercentage: Value(loadFields.percentage),
      plannedTargetRpe: Value(loadFields.rpe),
      plannedFreeformText: Value(loadFields.text),
      plannedRestSeconds: restSeconds,
      supersetGroup: const Value(null),
    );
  }

  SessionSetCompanion _setCompanion({
    required int exerciseId,
    required int setIndex,
    required RepPrescription reps,
    required LoadPrescription load,
  }) {
    final repFields = _repFields(reps);
    final loadFields = _loadFields(load);
    // NULL planned rest falls back to the session exercise's planned rest.
    return SessionSetCompanion.insert(
      sessionExerciseId: exerciseId,
      setIndex: setIndex,
      plannedRepType: reps.type.wireValue,
      plannedTargetReps: Value(repFields.target),
      plannedMinReps: Value(repFields.min),
      plannedMaxReps: Value(repFields.max),
      plannedLoadType: load.type.wireValue,
      plannedWeightCanonicalMg: Value(loadFields.milligrams),
      plannedPercentage: Value(loadFields.percentage),
      plannedTargetRpe: Value(loadFields.rpe),
      plannedFreeformText: Value(loadFields.text),
      completed: false,
    );
  }

  SessionSetCompanion _templateSetCompanion(
    int exerciseId,
    WorkoutSetData set,
  ) => SessionSetCompanion.insert(
    sessionExerciseId: exerciseId,
    setIndex: set.setIndex,
    plannedRepType: set.repType,
    plannedTargetReps: Value(set.targetReps),
    plannedMinReps: Value(set.minReps),
    plannedMaxReps: Value(set.maxReps),
    plannedLoadType: set.loadType,
    plannedWeightCanonicalMg: Value(set.weightCanonicalMg),
    plannedPercentage: Value(set.percentage),
    plannedTargetRpe: Value(set.targetRpe),
    plannedFreeformText: Value(set.freeformText),
    plannedRestSeconds: Value(set.restSeconds),
    completed: false,
  );

  Future<_SetContext> _requireMutableSetContext({
    required int sessionId,
    required int setId,
    bool allowCompleted = false,
  }) async {
    final set = await (database.select(
      database.sessionSet,
    )..where((row) => row.id.equals(setId))).getSingleOrNull();
    if (set == null) {
      throw const _RepositoryFailure(NotFoundFailure('Set was not found.'));
    }
    final exercise = await (database.select(
      database.sessionExercise,
    )..where((row) => row.id.equals(set.sessionExerciseId))).getSingleOrNull();
    if (exercise == null) {
      throw const _RepositoryFailure(
        ValidationFailure('Set does not belong to a session exercise.'),
      );
    }
    if (exercise.sessionId != sessionId) {
      throw const _RepositoryFailure(
        ValidationFailure('Set does not belong to this session.'),
      );
    }
    if (!allowCompleted && set.completed) {
      throw const _RepositoryFailure(
        ValidationFailure('Completed sets cannot be edited.'),
      );
    }
    final session = await _requireMutableSession(sessionId);
    return _SetContext(set: set, exercise: exercise, session: session);
  }

  Future<SessionData> _requireMutableSession(
    int sessionId, {
    SessionStatus? expectedStatus,
  }) async {
    final session = await (database.select(
      database.session,
    )..where((row) => row.id.equals(sessionId))).getSingleOrNull();
    if (session == null) {
      throw const _RepositoryFailure(NotFoundFailure('Session was not found.'));
    }
    final status = SessionStatus.fromWire(session.status);
    if (status case Err(:final failure)) {
      throw _RepositoryFailure(failure);
    }
    final parsed = (status as Ok<SessionStatus>).value;
    if (expectedStatus != null && parsed != expectedStatus) {
      throw const _RepositoryFailure(
        ValidationFailure('Session status no longer matches the command.'),
      );
    }
    if (parsed != SessionStatus.running && parsed != SessionStatus.paused) {
      throw const _RepositoryFailure(
        ValidationFailure('Session is not active.'),
      );
    }
    return session;
  }

  void _requireTransition(SessionStatus current, SessionStatus target) {
    final transition = current.validateTransitionTo(target);
    if (transition case Err(:final failure)) {
      throw _RepositoryFailure(failure);
    }
  }

  bool _completionMatches(SessionSetData row, CompleteSetCommand command) {
    if (!row.completed || row.completedAt == null) {
      return false;
    }
    if (row.completedAt!.toUtc() != command.completedAt) {
      return false;
    }
    if (row.rpe != command.rpe) {
      return false;
    }
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
    if (actual case Err()) {
      return false;
    }
    final stored = (actual as Ok<ActualPrescription?>).value;
    if (stored == null) {
      return false;
    }
    return _actualPrescriptionEquals(stored, command.actual);
  }

  bool _restMatches(SessionData session, AbsoluteRestState? rest) {
    final stored = mapSessionRestState(session);
    if (stored case Err()) {
      return false;
    }
    final storedRest = (stored as Ok<AbsoluteRestState?>).value;
    if (rest == null && storedRest == null) {
      return true;
    }
    if (rest == null || storedRest == null) {
      return false;
    }
    return rest.startedAt == storedRest.startedAt &&
        rest.durationSeconds == storedRest.durationSeconds &&
        rest.targetAt == storedRest.targetAt;
  }

  bool _actualPrescriptionEquals(
    ActualPrescription left,
    ActualPrescription right,
  ) {
    if (left.reps.type != right.reps.type ||
        left.load.type != right.load.type) {
      return false;
    }
    final repsMatch = switch (left.reps) {
      FixedReps(:final reps) =>
        right.reps is FixedReps && (right.reps as FixedReps).reps == reps,
      RepRange(:final min, :final max) =>
        right.reps is RepRange &&
            (right.reps as RepRange).min == min &&
            (right.reps as RepRange).max == max,
      Amrap() => right.reps is Amrap,
    };
    if (!repsMatch) {
      return false;
    }
    return switch (left.load) {
      NoLoad() => right.load is NoLoad,
      BodyweightLoad() => right.load is BodyweightLoad,
      AbsoluteLoad(:final milligrams) =>
        right.load is AbsoluteLoad &&
            (right.load as AbsoluteLoad).milligrams == milligrams,
      PercentageLoad(:final percentage) =>
        right.load is PercentageLoad &&
            (right.load as PercentageLoad).percentage == percentage,
      TargetRpeLoad(:final rpe) =>
        right.load is TargetRpeLoad && (right.load as TargetRpeLoad).rpe == rpe,
      TextLoad(:final text) =>
        right.load is TextLoad && (right.load as TextLoad).text == text,
    };
  }

  SessionStatus _sessionStatus(SessionData session) {
    final status = SessionStatus.fromWire(session.status);
    if (status case Err(:final failure)) {
      throw _RepositoryFailure(failure);
    }
    return (status as Ok<SessionStatus>).value;
  }

  StorageFailure _storageFailure(Object error, StackTrace stack) =>
      StorageFailure(
        'Session storage operation failed.',
        cause: error,
        stackTrace: stack,
      );
}

({int? target, int? min, int? max}) _repFields(RepPrescription value) =>
    switch (value) {
      FixedReps(:final reps) => (target: reps, min: null, max: null),
      RepRange(:final min, :final max) => (target: null, min: min, max: max),
      Amrap() => (target: null, min: null, max: null),
    };

({int? milligrams, int? percentage, double? rpe, String? text}) _loadFields(
  LoadPrescription value,
) => switch (value) {
  NoLoad() || BodyweightLoad() => (
    milligrams: null,
    percentage: null,
    rpe: null,
    text: null,
  ),
  AbsoluteLoad(:final milligrams) => (
    milligrams: milligrams,
    percentage: null,
    rpe: null,
    text: null,
  ),
  PercentageLoad(:final percentage) => (
    milligrams: null,
    percentage: percentage,
    rpe: null,
    text: null,
  ),
  TargetRpeLoad(:final rpe) => (
    milligrams: null,
    percentage: null,
    rpe: rpe,
    text: null,
  ),
  TextLoad(:final text) => (
    milligrams: null,
    percentage: null,
    rpe: null,
    text: text,
  ),
};

final class _SetContext {
  const _SetContext({
    required this.set,
    required this.exercise,
    required this.session,
  });

  final SessionSetData set;
  final SessionExerciseData exercise;
  final SessionData session;
}

final class _RepositoryFailure implements Exception {
  const _RepositoryFailure(this.failure);
  final Failure failure;
}
