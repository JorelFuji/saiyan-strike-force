import 'package:drift/drift.dart' show OrderingTerm, Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/clock.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';
import 'package:vulcan_fitness/data/repositories/drift_session_repository.dart';
import 'package:vulcan_fitness/data/repositories/drift_workout_repository.dart';
import 'package:vulcan_fitness/data/repositories/session_storage_retry.dart';
import 'package:vulcan_fitness/data/services/flutter_local_notification_service.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/completed_session_summary.dart';
import 'package:vulcan_fitness/domain/models/exercise_history.dart';
import 'package:vulcan_fitness/domain/models/exercise_name.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/session_status.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';
import 'package:vulcan_fitness/domain/usecases/start_session.dart';

import '../database/database_fixture.dart';

void main() {
  late AppDatabase database;
  late DriftSessionRepository repository;
  setUp(() {
    database = openTestDatabase();
    repository = DriftSessionRepository(database);
  });
  tearDown(() => database.close());

  StartSessionCommand command(int workoutId, {int? scheduleId}) =>
      (StartSessionCommand.create(
        workoutId: workoutId,
        scheduleEntryId: scheduleId,
        startedAt: DateTime.utc(2026, 9, 26, 15),
        timezone: 'America/Denver',
      ) as Ok<StartSessionCommand>).value;

  test(
    'commits ordered session, exercise and incomplete set snapshots',
    () async {
      final workout = await insertWorkout(database, name: 'Push');
      await insertExercise(
        database,
        workoutId: workout,
        orderIndex: 0,
        plannedSets: 2,
      );
      final schedule = await insertSchedule(database, workoutId: workout);
      final result = await repository.startFromTemplate(
        command(workout, scheduleId: schedule),
      );
      final sessionId = (result as Ok<int>).value;
      final session = await (database.select(
        database.session,
      )..where((row) => row.id.equals(sessionId))).getSingle();
      final exercises = await (database.select(
        database.sessionExercise,
      )..where((row) => row.sessionId.equals(sessionId))).get();
      final sets =
          await (database.select(database.sessionSet)..where(
                (row) => row.sessionExerciseId.equals(exercises.single.id),
              ))
              .get();
      expect(session.status, 'running');
      expect(session.workoutNameSnapshot, 'Push');
      expect(session.startedAt.toUtc(), DateTime.utc(2026, 9, 26, 15));
      expect(session.scheduleEntryId, schedule);
      expect(exercises.single.plannedWeightCanonicalMg, 102058280);
      expect(sets.map((row) => row.setIndex), [0, 1]);
      expect(
        sets.every(
          (row) =>
              !row.completed &&
              row.completedAt == null &&
              row.actualRepType == null,
        ),
        isTrue,
      );
      expect(
        (await (database.select(
          database.scheduleEntry,
        )..where((row) => row.id.equals(schedule))).getSingle()).status,
        'planned',
      );
    },
  );

  test(
    'commits a null-source freestyle graph and appends copied sets',
    () async {
      final start = (StartFreestyleSessionCommand.create(
        startedAt: DateTime.utc(2026, 9, 29, 12),
        timezone: 'UTC',
      ) as Ok<StartFreestyleSessionCommand>).value;
      final sessionId =
          (await repository.startFreestyle(start) as Ok<int>).value;
      final session = await (database.select(
        database.session,
      )..where((row) => row.id.equals(sessionId))).getSingle();
      expect(session.workoutId, isNull);
      expect(session.scheduleEntryId, isNull);
      expect(session.workoutNameSnapshot, 'Freestyle Workout');
      final exercise = (AddSessionExerciseCommand.create(
        sessionId: sessionId,
        name: '  Goblet Squat ',
        initialSetCount: 2,
        reps: (RepPrescription.fixed(8) as Ok<RepPrescription>).value,
        load:
            (LoadPrescription.absolute(20000000) as Ok<LoadPrescription>).value,
        restSeconds: 90,
      ) as Ok<AddSessionExerciseCommand>).value;
      final exerciseId =
          (await repository.addExercise(exercise) as Ok<int>).value;
      final added = (AddSessionSetCommand.create(
        sessionId: sessionId,
        exerciseId: exerciseId,
      ) as Ok<AddSessionSetCommand>).value;
      expect(await repository.addSet(added), isA<Ok<int>>());
      final rows =
          await (database.select(database.sessionSet)
                ..where((row) => row.sessionExerciseId.equals(exerciseId))
                ..orderBy([(row) => OrderingTerm.asc(row.setIndex)]))
              .get();
      expect(rows.map((row) => row.setIndex), [0, 1, 2]);
      expect(
        rows.every((row) => row.plannedWeightCanonicalMg == 20000000),
        isTrue,
      );
      expect(await repository.startFreestyle(start), isA<Err<int>>());
    },
  );

  test('adds exercise while paused but rejects terminal writes', () async {
    final start = (StartFreestyleSessionCommand.create(
      startedAt: DateTime.utc(2026, 9, 29, 12),
      timezone: 'UTC',
    ) as Ok<StartFreestyleSessionCommand>).value;
    final sessionId = (await repository.startFreestyle(start) as Ok<int>).value;
    await (database.update(database.session)
          ..where((row) => row.id.equals(sessionId)))
        .write(const SessionCompanion(status: Value('paused')));
    final command = (AddSessionExerciseCommand.create(
      sessionId: sessionId,
      name: 'Row',
      initialSetCount: 1,
      reps: (RepPrescription.fixed(10) as Ok<RepPrescription>).value,
      load: LoadPrescription.noLoad,
      restSeconds: 0,
    ) as Ok<AddSessionExerciseCommand>).value;
    final exerciseId = (await repository.addExercise(command) as Ok<int>).value;
    expect(
      await repository.addSet(
        (AddSessionSetCommand.create(
          sessionId: sessionId,
          exerciseId: exerciseId,
        ) as Ok<AddSessionSetCommand>).value,
      ),
      isA<Ok<int>>(),
    );
    await (database.update(
      database.session,
    )..where((row) => row.id.equals(sessionId))).write(
      SessionCompanion(
        status: const Value('finished'),
        endedAt: Value(DateTime.utc(2026, 9, 29, 13)),
      ),
    );
    expect(await repository.addExercise(command), isA<Err<int>>());
  });

  test('starts archived empty templates and reports missing source', () async {
    final workout = await insertWorkout(database, name: 'Empty');
    await (database.update(database.workout)
          ..where((row) => row.id.equals(workout)))
        .write(WorkoutCompanion(archivedAt: Value(DateTime.utc(2026))));
    expect(
      await repository.startFromTemplate(command(workout)),
      isA<Ok<int>>(),
    );
    expect(await repository.startFromTemplate(command(999)), isA<Err<int>>());
  });

  test(
    'copies every rep and load wire variant and preserves template history',
    () async {
      final workout = await insertWorkout(database, name: 'Variants');
      final variants =
          <
            ({
              String rep,
              int? target,
              int? min,
              int? max,
              String load,
              int? mg,
              int? pct,
              double? rpe,
              String? text,
            })
          >[
            (
              rep: 'fixed',
              target: 5,
              min: null,
              max: null,
              load: 'none',
              mg: null,
              pct: null,
              rpe: null,
              text: null,
            ),
            (
              rep: 'range',
              target: null,
              min: 3,
              max: 7,
              load: 'bodyweight',
              mg: null,
              pct: null,
              rpe: null,
              text: null,
            ),
            (
              rep: 'amrap',
              target: null,
              min: null,
              max: null,
              load: 'absolute',
              mg: 45000000,
              pct: null,
              rpe: null,
              text: null,
            ),
            (
              rep: 'fixed',
              target: 8,
              min: null,
              max: null,
              load: 'percentage',
              mg: null,
              pct: 65,
              rpe: null,
              text: null,
            ),
            (
              rep: 'range',
              target: null,
              min: 1,
              max: 4,
              load: 'target_rpe',
              mg: null,
              pct: null,
              rpe: 8.5,
              text: null,
            ),
            (
              rep: 'amrap',
              target: null,
              min: null,
              max: null,
              load: 'text',
              mg: null,
              pct: null,
              rpe: null,
              text: 'chains',
            ),
          ];
      for (var i = 0; i < variants.length; i++) {
        final item = variants[i];
        await insertExercise(
          database,
          workoutId: workout,
          orderIndex: i,
          repType: item.rep,
          targetReps: item.target,
          minReps: item.min,
          maxReps: item.max,
          loadType: item.load,
          weightCanonicalMg: item.mg,
          percentage: item.pct,
          targetRpe: item.rpe,
          freeformText: item.text,
          plannedSets: 1,
        );
      }
      final id = (await repository.startFromTemplate(
        command(workout),
      ) as Ok<int>).value;
      final snapshots =
          await (database.select(database.sessionExercise)
                ..where((row) => row.sessionId.equals(id))
                ..orderBy([(row) => OrderingTerm.asc(row.orderIndex)]))
              .get();
      expect(
        snapshots.map((row) => row.plannedRepType),
        variants.map((row) => row.rep),
      );
      expect(
        snapshots.map((row) => row.plannedLoadType),
        variants.map((row) => row.load),
      );
      expect(
        snapshots.map((row) => row.plannedWeightCanonicalMg),
        variants.map((row) => row.mg),
      );
      expect(
        snapshots.map((row) => row.plannedPercentage),
        variants.map((row) => row.pct),
      );
      expect(
        snapshots.map((row) => row.plannedTargetRpe),
        variants.map((row) => row.rpe),
      );
      expect(
        snapshots.map((row) => row.plannedFreeformText),
        variants.map((row) => row.text),
      );
      await (database.delete(
        database.workout,
      )..where((row) => row.id.equals(workout))).go();
      final retained = await (database.select(
        database.sessionExercise,
      )..where((row) => row.sessionId.equals(id))).get();
      expect(retained, hasLength(6));
      final session = await (database.select(
        database.session,
      )..where((row) => row.id.equals(id))).getSingle();
      expect(session.workoutId, isNull);
    },
  );

  test(
    'template edits and archival leave an existing snapshot unchanged',
    () async {
      final workouts = DriftWorkoutRepository(database, const _FixedClock());
      final originalExercise = (TemplateExercise.create(
        name: 'Bench Press',
        plannedSets: 3,
        reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        load:
            (LoadPrescription.absolute(60000000) as Ok<LoadPrescription>).value,
        restSeconds: 90,
        supersetGroup: 2,
      ) as Ok<TemplateExercise>).value;
      final draft = (WorkoutTemplateDraft.create(
        name: 'Push',
        exercises: [originalExercise],
      ) as Ok<WorkoutTemplateDraft>).value;
      final created =
          (await workouts.create(draft) as Ok<WorkoutTemplate>).value;
      final sessionId = (await repository.startFromTemplate(
        command(created.id),
      ) as Ok<int>).value;
      final before = await (database.select(
        database.sessionExercise,
      )..where((row) => row.sessionId.equals(sessionId))).getSingle();
      final replacement = (TemplateExercise.create(
        name: 'Incline Press',
        plannedSets: 4,
        reps: const Amrap(),
        load: const BodyweightLoad(),
        restSeconds: 30,
      ) as Ok<TemplateExercise>).value;
      final changed = (WorkoutTemplate.create(
        id: created.id,
        name: 'Push Revised',
        createdAt: created.createdAt,
        exercises: [replacement],
      ) as Ok<WorkoutTemplate>).value;
      expect(await workouts.update(changed), isA<Ok<WorkoutTemplate>>());
      expect(await workouts.archive(created.id), isA<Ok<WorkoutTemplate>>());
      final after = await (database.select(
        database.sessionExercise,
      )..where((row) => row.sessionId.equals(sessionId))).getSingle();
      expect(after.nameSnapshot, before.nameSnapshot);
      expect(after.plannedSets, before.plannedSets);
      expect(after.plannedWeightCanonicalMg, before.plannedWeightCanonicalMg);
      expect(await workouts.delete(created.id), isA<Ok<void>>());
      final afterDelete = await (database.select(
        database.sessionExercise,
      )..where((row) => row.sessionId.equals(sessionId))).getSingle();
      final session = await (database.select(
        database.session,
      )..where((row) => row.id.equals(sessionId))).getSingle();
      expect(afterDelete.nameSnapshot, before.nameSnapshot);
      expect(session.workoutId, isNull);
    },
  );

  test('late set insertion failure rolls back all snapshot tables', () async {
    final workout = await insertWorkout(database);
    await insertExercise(database, workoutId: workout, plannedSets: 2);
    await database.customStatement(
      "CREATE TRIGGER fail_session_set BEFORE INSERT ON session_set BEGIN SELECT RAISE(ABORT, 'forced'); END",
    );
    final result = await repository.startFromTemplate(command(workout));
    expect((result as Err<int>).failure, isA<StorageFailure>());
    expect(await database.select(database.session).get(), isEmpty);
    expect(await database.select(database.sessionExercise).get(), isEmpty);
    expect(await database.select(database.sessionSet).get(), isEmpty);
  });

  test(
    'rejects invalid schedules and corrupt source rows before writing',
    () async {
      final workout = await insertWorkout(database);
      final otherWorkout = await insertWorkout(database, name: 'Other');
      final skipped = await insertSchedule(
        database,
        workoutId: workout,
        status: 'skipped',
      );
      final mismatched = await insertSchedule(
        database,
        workoutId: otherWorkout,
      );
      final missingResult = await repository.startFromTemplate(
        command(workout, scheduleId: 999),
      );
      final skippedResult = await repository.startFromTemplate(
        command(workout, scheduleId: skipped),
      );
      final mismatchedResult = await repository.startFromTemplate(
        command(workout, scheduleId: mismatched),
      );
      expect((missingResult as Err<int>).failure, isA<NotFoundFailure>());
      expect((skippedResult as Err<int>).failure, isA<ValidationFailure>());
      expect((mismatchedResult as Err<int>).failure, isA<ValidationFailure>());

      await database.customStatement('PRAGMA ignore_check_constraints = ON');
      await database.customStatement(
        'INSERT INTO workout_exercise '
        '(workout_id, name, normalized_name, order_index, planned_sets, rep_type, load_type, rest_seconds) '
        "VALUES (?, 'Broken', 'broken', 0, 1, 'unknown', 'none', 0)",
        [workout],
      );
      final corrupt = await repository.startFromTemplate(command(workout));
      expect((corrupt as Err<int>).failure, isA<ValidationFailure>());
      expect(await database.select(database.session).get(), isEmpty);
      expect(await database.select(database.sessionExercise).get(), isEmpty);
      expect(await database.select(database.sessionSet).get(), isEmpty);
    },
  );

  group('VF-005 part 2 persistence', () {
    Future<({int sessionId, int setId})> startSingleSetSession() async {
      final workout = await insertWorkout(database, name: 'Hydrate');
      await insertExercise(database, workoutId: workout, plannedSets: 1);
      final sessionId = (await repository.startFromTemplate(
        command(workout),
      ) as Ok<int>).value;
      final exercise = await (database.select(
        database.sessionExercise,
      )..where((row) => row.sessionId.equals(sessionId))).getSingle();
      final set = await (database.select(
        database.sessionSet,
      )..where((row) => row.sessionExerciseId.equals(exercise.id))).getSingle();
      return (sessionId: sessionId, setId: set.id);
    }

    Future<int> firstSetId(int sessionId) async {
      final exercise = await (database.select(
        database.sessionExercise,
      )..where((row) => row.sessionId.equals(sessionId))).getSingle();
      return (await (database.select(database.sessionSet)
                ..where((row) => row.sessionExerciseId.equals(exercise.id))
                ..orderBy([(row) => OrderingTerm.asc(row.setIndex)]))
              .get())
          .first
          .id;
    }

    test('hydrates ordered aggregates and empty sessions', () async {
      final emptyWorkout = await insertWorkout(database, name: 'Empty');
      final emptyId = (await repository.startFromTemplate(
        command(emptyWorkout),
      ) as Ok<int>).value;
      final empty =
          (await repository.getById(emptyId) as Ok<ActiveSession>).value;
      expect(empty.exercises, isEmpty);
      expect(await repository.getById(999), isA<Err<ActiveSession>>());
    });

    test('hydrates exercises and sets for active sessions', () async {
      final ids = await startSingleSetSession();
      final session =
          (await repository.getById(ids.sessionId) as Ok<ActiveSession>).value;
      expect(
        session.exercises.single.sets.single.plannedReps,
        isA<FixedReps>(),
      );
      expect(session.status, SessionStatus.running);
    });

    test('maps corrupt persisted rows to validation failures', () async {
      final ids = await startSingleSetSession();
      await database.customStatement('PRAGMA ignore_check_constraints = ON');
      await database.customStatement(
        "UPDATE session SET status = 'not-a-status' WHERE id = ?",
        [ids.sessionId],
      );
      expect(
        await repository.getById(ids.sessionId),
        isA<Err<ActiveSession>>(),
      );
    });

    test('watch emits initial and post-commit snapshots', () async {
      final ids = await startSingleSetSession();
      expect(
        await repository.watchById(ids.sessionId).first,
        isA<Ok<ActiveSession>>(),
      );

      final actual = (SaveSetActualValuesCommand.create(
        sessionId: ids.sessionId,
        setId: ids.setId,
        actual: _actualPrescription(),
      ) as Ok<SaveSetActualValuesCommand>).value;
      expect(await repository.saveSetActualValues(actual), isA<Ok<void>>());

      final watched =
          (await repository.watchById(ids.sessionId).first as Ok<ActiveSession>)
              .value;
      expect(
        watched.exercises.single.sets.single.actual,
        isA<ActualPrescription>(),
      );
    });

    test('perserves planned snapshots when saving actual values', () async {
      final ids = await startSingleSetSession();
      final before = await (database.select(
        database.sessionSet,
      )..where((row) => row.id.equals(ids.setId))).getSingle();
      final save = (SaveSetActualValuesCommand.create(
        sessionId: ids.sessionId,
        setId: ids.setId,
        actual: _actualPrescription(),
        rpe: 8,
      ) as Ok<SaveSetActualValuesCommand>).value;
      expect(await repository.saveSetActualValues(save), isA<Ok<void>>());
      final after = await (database.select(
        database.sessionSet,
      )..where((row) => row.id.equals(ids.setId))).getSingle();
      expect(after.plannedRepType, before.plannedRepType);
      expect(after.plannedWeightCanonicalMg, before.plannedWeightCanonicalMg);
      expect(after.actualRepType, 'fixed');
      expect(after.rpe, 8);
    });

    test(
      'complete set commits rest atomically and rolls back on failure',
      () async {
        final ids = await startSingleSetSession();
        final rest = (AbsoluteRestState.create(
          startedAt: DateTime.utc(2026, 9, 26, 16),
          durationSeconds: 90,
        ) as Ok<AbsoluteRestState>).value;
        final complete = (CompleteSetCommand.create(
          sessionId: ids.sessionId,
          setId: ids.setId,
          actual: _actualPrescription(),
          completedAt: DateTime.utc(2026, 9, 26, 16, 1),
          rest: rest,
        ) as Ok<CompleteSetCommand>).value;
        expect(await repository.completeSet(complete), isA<Ok<void>>());
        final set = await (database.select(
          database.sessionSet,
        )..where((row) => row.id.equals(ids.setId))).getSingle();
        final session = await (database.select(
          database.session,
        )..where((row) => row.id.equals(ids.sessionId))).getSingle();
        expect(set.completed, isTrue);
        expect(session.restTargetAt, isNotNull);

        final abandon = (AbandonSessionCommand.create(
          sessionId: ids.sessionId,
          currentStatus: SessionStatus.running,
          endedAt: DateTime.utc(2026, 9, 26, 16, 5),
        ) as Ok<AbandonSessionCommand>).value;
        expect(await repository.abandonSession(abandon), isA<Ok<void>>());

        final ids2 = await startSingleSetSession();
        await database.customStatement(
          "CREATE TRIGGER fail_rest AFTER UPDATE OF rest_target_at ON session "
          "BEGIN SELECT RAISE(ABORT, 'forced'); END",
        );
        final rollbackComplete = (CompleteSetCommand.create(
          sessionId: ids2.sessionId,
          setId: ids2.setId,
          actual: _actualPrescription(),
          completedAt: DateTime.utc(2026, 9, 26, 16, 2),
          rest: rest,
        ) as Ok<CompleteSetCommand>).value;
        expect(
          await repository.completeSet(rollbackComplete),
          isA<Err<void>>(),
        );
        final rolledSet = await (database.select(
          database.sessionSet,
        )..where((row) => row.id.equals(ids2.setId))).getSingle();
        final rolledSession = await (database.select(
          database.session,
        )..where((row) => row.id.equals(ids2.sessionId))).getSingle();
        expect(rolledSet.completed, isFalse);
        expect(rolledSession.restTargetAt, isNull);
        await database.customStatement('DROP TRIGGER IF EXISTS fail_rest');
      },
    );

    test(
      'handles transitions, schedule finish, guards, and resume lookup',
      () async {
        final workout = await insertWorkout(database);
        await insertExercise(database, workoutId: workout);
        final schedule = await insertSchedule(database, workoutId: workout);
        final sessionId = (await repository.startFromTemplate(
          command(workout, scheduleId: schedule),
        ) as Ok<int>).value;
        final setId = await firstSetId(sessionId);

        expect(await repository.findResumableSessionId(), isA<Ok<int?>>());
        expect(
          (await repository.findResumableSessionId() as Ok<int?>).value,
          sessionId,
        );

        final pause = (PauseSessionCommand.create(
          sessionId: sessionId,
          currentStatus: SessionStatus.running,
        ) as Ok<PauseSessionCommand>).value;
        expect(await repository.pauseSession(pause), isA<Ok<void>>());

        final resume = (ContinueSessionCommand.create(
          sessionId: sessionId,
          currentStatus: SessionStatus.paused,
        ) as Ok<ContinueSessionCommand>).value;
        expect(await repository.continueSession(resume), isA<Ok<void>>());

        final endedAt = DateTime.utc(2026, 9, 26, 17);
        final finish = (FinishSessionCommand.create(
          sessionId: sessionId,
          currentStatus: SessionStatus.running,
          endedAt: endedAt,
        ) as Ok<FinishSessionCommand>).value;
        expect(await repository.finishSession(finish), isA<Ok<void>>());
        final scheduleRow = await (database.select(
          database.scheduleEntry,
        )..where((row) => row.id.equals(schedule))).getSingle();
        expect(scheduleRow.status, 'completed_by_session');
        expect(scheduleRow.sessionId, sessionId);
        expect(
          (await repository.findResumableSessionId() as Ok<int?>).value,
          isNull,
        );

        final workout2 = await insertWorkout(database, name: 'Next');
        expect(
          await repository.startFromTemplate(command(workout2)),
          isA<Ok<int>>(),
        );

        final wrongSessionSave = (SaveSetActualValuesCommand.create(
          sessionId: sessionId,
          setId: setId,
          actual: _actualPrescription(),
        ) as Ok<SaveSetActualValuesCommand>).value;
        expect(
          await repository.saveSetActualValues(wrongSessionSave),
          isA<Err<void>>(),
        );
      },
    );

    test(
      'rejects duplicate active starts and conflicting completion retries',
      () async {
        final workout = await insertWorkout(database);
        await insertExercise(database, workoutId: workout, plannedSets: 1);
        final sessionId = (await repository.startFromTemplate(
          command(workout),
        ) as Ok<int>).value;
        expect(
          await repository.startFromTemplate(command(workout)),
          isA<Err<int>>(),
        );
        final setId = await firstSetId(sessionId);
        final completedAt = DateTime.utc(2026, 9, 26, 16);
        final first = (CompleteSetCommand.create(
          sessionId: sessionId,
          setId: setId,
          actual: _actualPrescription(),
          completedAt: completedAt,
        ) as Ok<CompleteSetCommand>).value;
        expect(await repository.completeSet(first), isA<Ok<void>>());
        expect(await repository.completeSet(first), isA<Ok<void>>());

        final conflict = (CompleteSetCommand.create(
          sessionId: sessionId,
          setId: setId,
          actual: (ActualPrescription.create(
            reps: (RepPrescription.fixed(10) as Ok<RepPrescription>).value,
            load: LoadPrescription.bodyweight,
          ) as Ok<ActualPrescription>).value,
          completedAt: completedAt,
        ) as Ok<CompleteSetCommand>).value;
        expect(await repository.completeSet(conflict), isA<Err<void>>());
      },
    );

    test(
      'repository write retries busy failures through storage retry',
      () async {
        final ids = await startSingleSetSession();
        var attempts = 0;
        final retryRepository = DriftSessionRepository(
          database,
          storageRetry: SessionStorageRetry(
            runnerForTesting: <T>(Future<T> Function() action) =>
                SessionStorageRetry(maxAttempts: 3).run(() async {
                  attempts++;
                  if (attempts < 2) {
                    throw SqliteException(
                      extendedResultCode: SqlError.SQLITE_BUSY,
                      message: 'busy',
                    );
                  }
                  return action();
                }),
          ),
        );
        final save = (SaveSetActualValuesCommand.create(
          sessionId: ids.sessionId,
          setId: ids.setId,
          actual: _actualPrescription(),
        ) as Ok<SaveSetActualValuesCommand>).value;
        expect(
          await retryRepository.saveSetActualValues(save),
          isA<Ok<void>>(),
        );
        expect(attempts, 2);
      },
    );

    test('bounded contention retries reuse command input', () async {
      var attempts = 0;
      final retry = SessionStorageRetry(maxAttempts: 3);
      final value = await retry.run(() async {
        attempts++;
        if (attempts < 2) {
          throw SqliteException(
            extendedResultCode: SqlError.SQLITE_BUSY,
            message: 'busy',
          );
        }
        return 'committed';
      });
      expect(value, 'committed');
      expect(attempts, 2);

      var exhausted = 0;
      final limited = SessionStorageRetry(maxAttempts: 2);
      await expectLater(
        limited.run(() async {
          exhausted++;
          throw SqliteException(
            extendedResultCode: SqlError.SQLITE_LOCKED,
            message: 'locked',
          );
        }),
        throwsA(isA<StorageFailure>()),
      );
      expect(exhausted, 2);
    });

    test('update and clear rest on mutable sessions only', () async {
      final ids = await startSingleSetSession();
      final rest = (AbsoluteRestState.create(
        startedAt: DateTime.utc(2026, 9, 26, 16),
        durationSeconds: 60,
      ) as Ok<AbsoluteRestState>).value;
      final update = (UpdateSessionRestCommand.create(
        sessionId: ids.sessionId,
        rest: rest,
      ) as Ok<UpdateSessionRestCommand>).value;
      expect(await repository.updateSessionRest(update), isA<Ok<void>>());

      final finish = (FinishSessionCommand.create(
        sessionId: ids.sessionId,
        currentStatus: SessionStatus.running,
        endedAt: DateTime.utc(2026, 9, 26, 17),
      ) as Ok<FinishSessionCommand>).value;
      expect(await repository.finishSession(finish), isA<Ok<void>>());

      final clear = (ClearSessionRestCommand.create(
        sessionId: ids.sessionId,
      ) as Ok<ClearSessionRestCommand>).value;
      expect(await repository.clearSessionRest(clear), isA<Err<void>>());
    });
  });

  group('VF-005 part 3 file-backed recovery', () {
    setUpAll(() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    });

    test('committed session survives close and reopen', () async {
      final fixture = await openFileTestDatabase();
      addTearDown(() async {
        await fixture.directory.delete(recursive: true);
      });

      late int sessionId;
      const workoutName = 'Recovery Push';
      final completedAt = DateTime.utc(2026, 9, 26, 16, 1);
      final rest = (AbsoluteRestState.create(
        startedAt: DateTime.utc(2026, 9, 26, 16),
        durationSeconds: 90,
      ) as Ok<AbsoluteRestState>).value;

      {
        final repository = DriftSessionRepository(fixture.database);
        final workout = await insertWorkout(
          fixture.database,
          name: workoutName,
        );
        await insertExercise(
          fixture.database,
          workoutId: workout,
          plannedSets: 2,
        );
        sessionId = (await repository.startFromTemplate(
          command(workout),
        ) as Ok<int>).value;
        final setId = await firstSetIdForSession(fixture.database, sessionId);
        final complete = (CompleteSetCommand.create(
          sessionId: sessionId,
          setId: setId,
          actual: _actualPrescription(),
          completedAt: completedAt,
          rest: rest,
        ) as Ok<CompleteSetCommand>).value;
        expect(await repository.completeSet(complete), isA<Ok<void>>());
        await fixture.database.close();
      }

      final reopened = AppDatabase(NativeDatabase(fixture.file));
      addTearDown(reopened.close);
      final repository = DriftSessionRepository(reopened);

      expect(
        (await repository.findResumableSessionId() as Ok<int?>).value,
        sessionId,
      );
      final session =
          (await repository.getById(sessionId) as Ok<ActiveSession>).value;
      expect(session.status, SessionStatus.running);
      expect(session.workoutNameSnapshot, workoutName);
      expect(session.exercises.single.sets.map((set) => set.setIndex), [0, 1]);
      expect(session.exercises.single.sets.first.completed, isTrue);
      expect(
        session.exercises.single.sets.first.completedAt?.toUtc(),
        completedAt,
      );
      expect(
        session.exercises.single.sets.first.actual,
        isA<ActualPrescription>(),
      );
      expect(session.exercises.single.sets[1].completed, isFalse);
      expect(session.rest?.startedAt.toUtc(), rest.startedAt);
      expect(session.rest?.durationSeconds, rest.durationSeconds);
      expect(session.rest?.targetAt.toUtc(), rest.targetAt);
    });

    test('reopen with no active session returns null resumable id', () async {
      final fixture = await openFileTestDatabase();
      addTearDown(() async {
        await fixture.directory.delete(recursive: true);
      });

      final repository = DriftSessionRepository(fixture.database);
      final workout = await insertWorkout(fixture.database);
      await insertExercise(
        fixture.database,
        workoutId: workout,
        plannedSets: 1,
      );
      final sessionId = (await repository.startFromTemplate(
        command(workout),
      ) as Ok<int>).value;
      final finish = (FinishSessionCommand.create(
        sessionId: sessionId,
        currentStatus: SessionStatus.running,
        endedAt: DateTime.utc(2026, 9, 26, 17),
      ) as Ok<FinishSessionCommand>).value;
      expect(await repository.finishSession(finish), isA<Ok<void>>());
      await fixture.database.close();

      final reopened = AppDatabase(NativeDatabase(fixture.file));
      addTearDown(reopened.close);
      expect(
        (await DriftSessionRepository(reopened).findResumableSessionId()
                as Ok<int?>)
            .value,
        isNull,
      );
    });

    test(
      'reopen with multiple active sessions returns validation failure',
      () async {
        final fixture = await openFileTestDatabase();
        addTearDown(() async {
          await fixture.directory.delete(recursive: true);
        });

        await insertSession(fixture.database, status: 'running');
        await insertSession(fixture.database, status: 'paused');
        await fixture.database.close();

        final reopened = AppDatabase(NativeDatabase(fixture.file));
        addTearDown(reopened.close);
        final result = await DriftSessionRepository(reopened)
            .findResumableSessionId();
        expect(result, isA<Err<int?>>());
        expect((result as Err<int?>).failure, isA<ValidationFailure>());
      },
    );
  });

  group('watchCompletedSummaries', () {
    setUpAll(() {
      initializeTimezoneDatabase();
    });

    Future<List<CompletedSessionSummary>> firstOkEmission() async {
      final result = await repository.watchCompletedSummaries().first;
      expect(result, isA<Ok<List<CompletedSessionSummary>>>());
      return (result as Ok<List<CompletedSessionSummary>>).value;
    }

    test('emits empty list when no finished sessions exist', () async {
      await insertSession(database, status: 'running');
      await insertSession(
        database,
        status: 'abandoned',
        endedAt: DateTime.utc(2026, 9, 1, 16),
      );
      expect(await firstOkEmission(), isEmpty);
    });

    test('orders by started_at DESC then id DESC', () async {
      final early = DateTime.utc(2026, 9, 1, 15);
      final late = DateTime.utc(2026, 9, 2, 15);
      final ended = DateTime.utc(2026, 9, 2, 16);
      final firstSameInstant = await insertSession(
        database,
        status: 'finished',
        startedAtOverride: late,
        endedAt: ended,
        workoutNameSnapshot: 'A',
      );
      final secondSameInstant = await insertSession(
        database,
        status: 'finished',
        startedAtOverride: late,
        endedAt: ended,
        workoutNameSnapshot: 'B',
      );
      await insertSession(
        database,
        status: 'finished',
        startedAtOverride: early,
        endedAt: DateTime.utc(2026, 9, 1, 16),
        workoutNameSnapshot: 'C',
      );

      final summaries = await firstOkEmission();
      expect(summaries.map((s) => s.workoutNameSnapshot).toList(), [
        'B',
        'A',
        'C',
      ]);
      expect(summaries[0].id, secondSameInstant);
      expect(summaries[1].id, firstSameInstant);
    });

    test('includes zero-set finished sessions with 0/0 and volume 0', () async {
      await insertSession(
        database,
        status: 'finished',
        endedAt: DateTime.utc(2026, 9, 1, 16),
      );
      final summaries = await firstOkEmission();
      expect(summaries, hasLength(1));
      expect(summaries.single.completedSetCount, 0);
      expect(summaries.single.totalSetCount, 0);
      expect(summaries.single.absoluteVolumeMilligramReps, 0);
      expect(summaries.single.completionLabel, '0/0');
    });

    test('counts completion and absolute×fixed volume only', () async {
      final sessionId = await insertSession(
        database,
        status: 'finished',
        endedAt: DateTime.utc(2026, 9, 1, 16),
      );
      final exerciseId = await insertSessionExercise(
        database,
        sessionId: sessionId,
      );
      // Included: completed absolute × fixed → 1000mg * 5 = 5000
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        setIndex: 0,
        completed: true,
        completedAt: DateTime.utc(2026, 9, 1, 15, 10),
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'absolute',
        actualWeightCanonicalMg: 1000,
      );
      // Excluded shapes
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        setIndex: 1,
        completed: true,
        completedAt: DateTime.utc(2026, 9, 1, 15, 11),
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'bodyweight',
      );
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        setIndex: 2,
        completed: true,
        completedAt: DateTime.utc(2026, 9, 1, 15, 12),
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'percentage',
        actualPercentage: 80,
      );
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        setIndex: 3,
        completed: true,
        completedAt: DateTime.utc(2026, 9, 1, 15, 13),
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'target_rpe',
        actualTargetRpe: 8,
      );
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        setIndex: 4,
        completed: true,
        completedAt: DateTime.utc(2026, 9, 1, 15, 14),
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'text',
        actualFreeformText: 'heavy',
      );
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        setIndex: 5,
        completed: false,
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'absolute',
        actualWeightCanonicalMg: 9000,
      );
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        setIndex: 6,
        completed: true,
        completedAt: DateTime.utc(2026, 9, 1, 15, 15),
        actualRepType: 'amrap',
        actualLoadType: 'absolute',
        actualWeightCanonicalMg: 1000,
      );

      final summaries = await firstOkEmission();
      expect(summaries.single.totalSetCount, 7);
      expect(summaries.single.completedSetCount, 6);
      expect(summaries.single.absoluteVolumeMilligramReps, 5000);
    });

    test('derives startedOn from session timezone not device zone', () async {
      // 2026-03-08 07:00 UTC is still 2026-03-07 in America/Los_Angeles (PST).
      await insertSession(
        database,
        status: 'finished',
        startedAtOverride: DateTime.utc(2026, 3, 8, 7),
        endedAt: DateTime.utc(2026, 3, 8, 8),
        timezone: 'America/Los_Angeles',
      );
      final summaries = await firstOkEmission();
      expect(summaries.single.startedOn.toIso(), '2026-03-07');
      expect(summaries.single.timezone, 'America/Los_Angeles');
    });

    test('reacts when a running session finishes', () async {
      final sessionId = await insertSession(database, status: 'running');
      final emissions = <Result<List<CompletedSessionSummary>>>[];
      final sub = repository.watchCompletedSummaries().listen(emissions.add);
      addTearDown(sub.cancel);

      await pumpEventQueue();
      expect(emissions, isNotEmpty);
      expect(
        (emissions.last as Ok<List<CompletedSessionSummary>>).value,
        isEmpty,
      );

      await (database.update(
        database.session,
      )..where((row) => row.id.equals(sessionId))).write(
        SessionCompanion(
          status: const Value('finished'),
          endedAt: Value(DateTime.utc(2026, 9, 1, 16)),
        ),
      );
      await pumpEventQueue();
      expect(
        (emissions.last as Ok<List<CompletedSessionSummary>>).value,
        hasLength(1),
      );
    });

    test('snapshot name is independent of live template rename', () async {
      final workoutId = await insertWorkout(database, name: 'Live Push');
      final sessionId = await insertSession(
        database,
        workoutId: workoutId,
        status: 'finished',
        workoutNameSnapshot: 'Snap Push',
        endedAt: DateTime.utc(2026, 9, 1, 16),
      );
      await (database.update(
        database.workout,
      )..where((row) => row.id.equals(workoutId))).write(
        WorkoutCompanion(
          name: const Value('Renamed'),
          archivedAt: Value(DateTime.utc(2026, 9, 2)),
        ),
      );

      final summaries = await firstOkEmission();
      expect(summaries.single.id, sessionId);
      expect(summaries.single.workoutNameSnapshot, 'Snap Push');
    });

    test('corrupt timezone yields Err', () async {
      await insertSession(
        database,
        status: 'finished',
        endedAt: DateTime.utc(2026, 9, 1, 16),
        timezone: 'Not/ARealZone',
      );
      final result = await repository.watchCompletedSummaries().first;
      expect(result, isA<Err<List<CompletedSessionSummary>>>());
      expect(
        (result as Err<List<CompletedSessionSummary>>).failure,
        isA<ValidationFailure>(),
      );
    });
  });

  group('watchExerciseHistory', () {
    setUpAll(() {
      initializeTimezoneDatabase();
    });

    ExerciseName lookup(String display) =>
        (ExerciseName.forLookup(display) as Ok<ExerciseName>).value;

    Future<List<ExerciseHistoryEntry>> firstOkHistory(String name) async {
      final result = await repository.watchExerciseHistory(lookup(name)).first;
      expect(result, isA<Ok<List<ExerciseHistoryEntry>>>());
      return (result as Ok<List<ExerciseHistoryEntry>>).value;
    }

    test('matches normalized name and finished sessions only', () async {
      final finished = await insertSession(
        database,
        status: 'finished',
        endedAt: DateTime.utc(2026, 9, 1, 16),
      );
      final exerciseId = await insertSessionExercise(
        database,
        sessionId: finished,
        nameSnapshot: 'Bench Press',
        normalizedName: 'bench press',
      );
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        completed: true,
        completedAt: DateTime.utc(2026, 9, 1, 15, 10),
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'absolute',
        actualWeightCanonicalMg: 1000,
      );
      final running = await insertSession(database, status: 'running');
      final runningExercise = await insertSessionExercise(
        database,
        sessionId: running,
      );
      await insertSet(
        database,
        sessionExerciseId: runningExercise,
        completed: true,
        completedAt: DateTime.utc(2026, 9, 1, 15, 10),
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'absolute',
        actualWeightCanonicalMg: 1000,
      );

      expect(await firstOkHistory('bench press'), hasLength(1));
      expect(await firstOkHistory('  BENCH   PRESS '), hasLength(1));
      expect(await firstOkHistory('Squat'), isEmpty);
    });

    test('orders instances reverse chronologically with set order', () async {
      final early = DateTime.utc(2026, 9, 1, 15);
      final late = DateTime.utc(2026, 9, 2, 15);
      final ended = DateTime.utc(2026, 9, 2, 16);
      final olderSession = await insertSession(
        database,
        status: 'finished',
        startedAtOverride: early,
        endedAt: DateTime.utc(2026, 9, 1, 16),
      );
      final newerSession = await insertSession(
        database,
        status: 'finished',
        startedAtOverride: late,
        endedAt: ended,
      );
      final olderExercise = await insertSessionExercise(
        database,
        sessionId: olderSession,
      );
      final newerExercise = await insertSessionExercise(
        database,
        sessionId: newerSession,
      );
      await insertSet(
        database,
        sessionExerciseId: olderExercise,
        setIndex: 0,
        completed: true,
        completedAt: early,
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'absolute',
        actualWeightCanonicalMg: 1000,
      );
      await insertSet(
        database,
        sessionExerciseId: newerExercise,
        setIndex: 0,
        completed: true,
        completedAt: late,
        actualRepType: 'fixed',
        actualTargetReps: 8,
        actualLoadType: 'absolute',
        actualWeightCanonicalMg: 2000,
      );
      await insertSet(
        database,
        sessionExerciseId: newerExercise,
        setIndex: 1,
        completed: true,
        completedAt: late.add(const Duration(minutes: 1)),
        actualRepType: 'fixed',
        actualTargetReps: 6,
        actualLoadType: 'absolute',
        actualWeightCanonicalMg: 2500,
      );

      final entries = await firstOkHistory('Bench Press');
      expect(entries, hasLength(2));
      expect(entries[0].sessionId, newerSession);
      expect(entries[0].completedSets.map((s) => s.setIndex), [0, 1]);
      expect(
        entries[0].completedSets[1].actual.load,
        isA<AbsoluteLoad>().having((l) => l.milligrams, 'mg', 2500),
      );
    });

    test(
      'keeps duplicate normalized exercises in one session separate',
      () async {
        final sessionId = await insertSession(
          database,
          status: 'finished',
          endedAt: DateTime.utc(2026, 9, 1, 16),
        );
        final first = await insertSessionExercise(
          database,
          sessionId: sessionId,
          orderIndex: 0,
        );
        final second = await insertSessionExercise(
          database,
          sessionId: sessionId,
          orderIndex: 1,
        );
        for (final exerciseId in [first, second]) {
          await insertSet(
            database,
            sessionExerciseId: exerciseId,
            completed: true,
            completedAt: DateTime.utc(2026, 9, 1, 15),
            actualRepType: 'fixed',
            actualTargetReps: 5,
            actualLoadType: 'absolute',
            actualWeightCanonicalMg: 1000,
          );
        }

        final entries = await firstOkHistory('Bench Press');
        expect(entries, hasLength(2));
        expect(entries.map((e) => e.sessionExerciseId).toSet(), {
          first,
          second,
        });
      },
    );

    test('omits snapshots without completed sets', () async {
      final sessionId = await insertSession(
        database,
        status: 'finished',
        endedAt: DateTime.utc(2026, 9, 1, 16),
      );
      final exerciseId = await insertSessionExercise(
        database,
        sessionId: sessionId,
      );
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        completed: false,
      );
      expect(await firstOkHistory('Bench Press'), isEmpty);
    });

    test('reacts when a session finishes with matching data', () async {
      final sessionId = await insertSession(database, status: 'running');
      final exerciseId = await insertSessionExercise(
        database,
        sessionId: sessionId,
      );
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        completed: true,
        completedAt: DateTime.utc(2026, 9, 1, 15),
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'absolute',
        actualWeightCanonicalMg: 1000,
      );
      final emissions = <Result<List<ExerciseHistoryEntry>>>[];
      final sub = repository
          .watchExerciseHistory(lookup('Bench Press'))
          .listen(emissions.add);
      addTearDown(sub.cancel);
      await pumpEventQueue();
      expect((emissions.last as Ok<List<ExerciseHistoryEntry>>).value, isEmpty);

      await (database.update(
        database.session,
      )..where((row) => row.id.equals(sessionId))).write(
        SessionCompanion(
          status: const Value('finished'),
          endedAt: Value(DateTime.utc(2026, 9, 1, 16)),
        ),
      );
      await pumpEventQueue();
      expect(
        (emissions.last as Ok<List<ExerciseHistoryEntry>>).value,
        hasLength(1),
      );
    });

    test('snapshot values stay independent of template edits', () async {
      final workoutId = await insertWorkout(database, name: 'Push');
      final sessionId = await insertSession(
        database,
        workoutId: workoutId,
        status: 'finished',
        endedAt: DateTime.utc(2026, 9, 1, 16),
      );
      final exerciseId = await insertSessionExercise(
        database,
        sessionId: sessionId,
        nameSnapshot: 'Snap Bench',
        normalizedName: 'snap bench',
      );
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        completed: true,
        completedAt: DateTime.utc(2026, 9, 1, 15),
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'absolute',
        actualWeightCanonicalMg: 1000,
      );
      await (database.update(database.workout)
            ..where((row) => row.id.equals(workoutId)))
          .write(const WorkoutCompanion(name: Value('Renamed')));

      final entries = await firstOkHistory('Snap Bench');
      expect(entries.single.nameSnapshot, 'Snap Bench');
    });

    test('corrupt session timezone yields Err', () async {
      final sessionId = await insertSession(
        database,
        status: 'finished',
        endedAt: DateTime.utc(2026, 9, 1, 16),
        timezone: 'America/Denver',
      );
      final exerciseId = await insertSessionExercise(
        database,
        sessionId: sessionId,
      );
      await insertSet(
        database,
        sessionExerciseId: exerciseId,
        completed: true,
        completedAt: DateTime.utc(2026, 9, 1, 15),
        actualRepType: 'fixed',
        actualTargetReps: 5,
        actualLoadType: 'absolute',
        actualWeightCanonicalMg: 1000,
      );
      await database.customStatement(
        'UPDATE session SET timezone = ? WHERE id = ?',
        ['Not/ARealZone', sessionId],
      );
      final result = await repository
          .watchExerciseHistory(lookup('Bench Press'))
          .first;
      expect(result, isA<Err<List<ExerciseHistoryEntry>>>());
      expect(
        (result as Err<List<ExerciseHistoryEntry>>).failure,
        isA<ValidationFailure>(),
      );
    });

    test(
      'EXPLAIN QUERY PLAN uses existing indexes on representative lookup',
      () async {
        final sessionId = await insertSession(
          database,
          status: 'finished',
          endedAt: DateTime.utc(2026, 9, 1, 16),
        );
        final exerciseId = await insertSessionExercise(
          database,
          sessionId: sessionId,
        );
        await insertSet(
          database,
          sessionExerciseId: exerciseId,
          completed: true,
          completedAt: DateTime.utc(2026, 9, 1, 15),
          actualRepType: 'fixed',
          actualTargetReps: 5,
          actualLoadType: 'absolute',
          actualWeightCanonicalMg: 1000,
        );
        final plan = await database.customSelect('''
EXPLAIN QUERY PLAN
SELECT se.id
FROM session s
INNER JOIN session_exercise se ON se.session_id = s.id
INNER JOIN session_set ss ON ss.session_exercise_id = se.id
WHERE s.status = 'finished'
  AND se.normalized_name = 'bench press'
  AND ss.completed = 1
''').get();
        final detail = plan.map((row) => row.read<String>('detail')).join('\n');
        expect(detail, contains('session_exercise'));
        expect(
          detail.toLowerCase(),
          anyOf(contains('search'), contains('scan')),
        );
      },
    );
  });
}

Future<int> firstSetIdForSession(AppDatabase database, int sessionId) async {
  final exercise = await (database.select(
    database.sessionExercise,
  )..where((row) => row.sessionId.equals(sessionId))).getSingle();
  return (await (database.select(database.sessionSet)
            ..where((row) => row.sessionExerciseId.equals(exercise.id))
            ..orderBy([(row) => OrderingTerm.asc(row.setIndex)]))
          .get())
      .first
      .id;
}

ActualPrescription _actualPrescription() => (ActualPrescription.create(
  reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
  load: (LoadPrescription.absolute(45000000) as Ok<LoadPrescription>).value,
) as Ok<ActualPrescription>).value;

final class _FixedClock implements Clock {
  const _FixedClock();
  @override
  DateTime now() => DateTime.utc(2026, 9, 26);
}
