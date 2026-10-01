import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';

import 'database_fixture.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase db;

  setUp(() {
    db = openTestDatabase();
  });

  tearDown(() => db.close());

  Future<int> workoutId() => insertWorkout(db);

  Future<void> expectRejected(Future<Object?> action) {
    return expectLater(action, throwsA(isA<SqliteException>()));
  }

  test('accepts a valid template, schedule, and session snapshot', () async {
    final templateId = await workoutId();
    await insertExercise(db, workoutId: templateId);
    final scheduleId = await insertSchedule(
      db,
      workoutId: templateId,
      startTime: 0,
    );
    final sessionId = await insertSession(
      db,
      workoutId: templateId,
      scheduleEntryId: scheduleId,
      includeRest: true,
      status: 'finished',
    );
    final exerciseId = await insertSessionExercise(db, sessionId: sessionId);
    await insertSet(
      db,
      sessionExerciseId: exerciseId,
      completed: true,
      completedAt: startedAt,
      rpe: 8.5,
      actualRepType: 'fixed',
      actualTargetReps: 5,
      actualLoadType: 'absolute',
      actualWeightCanonicalMg: 102058280,
    );
    await db
        .update(db.scheduleEntry)
        .replace(
          ScheduleEntryData(
            id: scheduleId,
            workoutId: templateId,
            date: '2026-09-22',
            startTime: 1439,
            label: null,
            status: 'completed_by_session',
            sessionId: sessionId,
          ),
        );

    expect(await db.select(db.sessionSet).get(), hasLength(1));
  });

  test('rejects unknown wires and mismatched prescriptions', () async {
    final templateId = await workoutId();

    await expectRejected(
      insertExercise(db, workoutId: templateId, repType: 'reps'),
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        repType: 'fixed',
        targetReps: null,
      ),
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        repType: 'fixed',
        targetReps: 5,
        minReps: 3,
      ),
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        repType: 'range',
        targetReps: null,
        minReps: 8,
        maxReps: 6,
      ),
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        repType: 'amrap',
        targetReps: 5,
      ),
    );
    await expectRejected(
      insertExercise(db, workoutId: templateId, loadType: 'kg'),
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        loadType: 'none',
        weightCanonicalMg: 1000,
      ),
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        loadType: 'absolute',
        weightCanonicalMg: null,
      ),
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        loadType: 'text',
        weightCanonicalMg: null,
        freeformText: '',
      ),
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        loadType: 'bodyweight',
        weightCanonicalMg: null,
        percentage: 50,
      ),
    );

    final sessionId = await insertSession(db);
    final exerciseId = await insertSessionExercise(db, sessionId: sessionId);
    await expectRejected(
      insertSet(db, sessionExerciseId: exerciseId, actualRepType: 'fixed'),
    );
    await expectRejected(
      insertSet(db, sessionExerciseId: exerciseId, actualLoadType: 'absolute'),
    );
  });

  test('rejects invalid dates, minutes, order, and numeric bounds', () async {
    final templateId = await workoutId();

    await expectRejected(
      insertSchedule(db, workoutId: templateId, date: '2024-02-31'),
    );
    await expectRejected(
      insertSchedule(db, workoutId: templateId, date: '2023-02-29'),
    );
    await expectRejected(
      insertSchedule(db, workoutId: templateId, date: '2024-1-01'),
    );
    await expectRejected(
      insertSchedule(db, workoutId: templateId, startTime: -1),
    );
    await expectRejected(
      insertSchedule(db, workoutId: templateId, startTime: 1440),
    );
    await insertSchedule(
      db,
      workoutId: templateId,
      date: '2024-02-29',
      startTime: 0,
    );
    await insertSchedule(
      db,
      workoutId: templateId,
      date: '2024-03-01',
      startTime: 1439,
    );

    await expectRejected(
      insertExercise(db, workoutId: templateId, orderIndex: -1),
    );
    await expectRejected(
      insertExercise(db, workoutId: templateId, plannedSets: 0),
    );
    await expectRejected(
      insertExercise(db, workoutId: templateId, restSeconds: -1),
    );
    await expectRejected(
      insertExercise(db, workoutId: templateId, weightCanonicalMg: -1),
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        loadType: 'percentage',
        weightCanonicalMg: null,
        percentage: -1,
      ),
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        loadType: 'percentage',
        weightCanonicalMg: null,
        percentage: 101,
      ),
    );
    await insertExercise(
      db,
      workoutId: templateId,
      orderIndex: 1,
      loadType: 'percentage',
      weightCanonicalMg: null,
      percentage: 0,
    );
    await insertExercise(
      db,
      workoutId: templateId,
      orderIndex: 2,
      loadType: 'percentage',
      weightCanonicalMg: null,
      percentage: 100,
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        orderIndex: 3,
        loadType: 'target_rpe',
        weightCanonicalMg: null,
        targetRpe: -0.5,
      ),
    );
    await expectRejected(
      insertExercise(
        db,
        workoutId: templateId,
        orderIndex: 4,
        loadType: 'target_rpe',
        weightCanonicalMg: null,
        targetRpe: 10.5,
      ),
    );
    await insertExercise(
      db,
      workoutId: templateId,
      orderIndex: 5,
      loadType: 'target_rpe',
      weightCanonicalMg: null,
      targetRpe: 0,
    );
    await insertExercise(
      db,
      workoutId: templateId,
      orderIndex: 6,
      loadType: 'target_rpe',
      weightCanonicalMg: null,
      targetRpe: 10,
    );

    await insertExercise(db, workoutId: templateId, orderIndex: 7);
    await expectRejected(
      insertExercise(db, workoutId: templateId, orderIndex: 7),
    );

    final sessionId = await insertSession(db);
    final exerciseId = await insertSessionExercise(db, sessionId: sessionId);
    await expectRejected(
      insertSet(db, sessionExerciseId: exerciseId, setIndex: -1),
    );
    await expectRejected(
      insertSet(db, sessionExerciseId: exerciseId, rpe: -0.5),
    );
    await expectRejected(
      insertSet(db, sessionExerciseId: exerciseId, rpe: 10.5),
    );
    await insertSet(db, sessionExerciseId: exerciseId, setIndex: 1, rpe: 0);
    await insertSet(db, sessionExerciseId: exerciseId, setIndex: 2, rpe: 10);
    await expectRejected(
      insertSet(db, sessionExerciseId: exerciseId, setIndex: 1),
    );
  });

  test(
    'enforces workout set order, prescriptions, rest, and cascade',
    () async {
      final templateId = await workoutId();
      final exerciseId = await insertExercise(db, workoutId: templateId);
      await (db.delete(
        db.workoutSet,
      )..where((row) => row.workoutExerciseId.equals(exerciseId))).go();

      await expectRejected(
        insertWorkoutSet(db, workoutExerciseId: exerciseId, setIndex: -1),
      );
      await expectRejected(
        insertWorkoutSet(db, workoutExerciseId: exerciseId, restSeconds: -1),
      );
      await expectRejected(
        insertWorkoutSet(
          db,
          workoutExerciseId: exerciseId,
          loadType: 'none',
          weightCanonicalMg: 1,
        ),
      );
      await insertWorkoutSet(db, workoutExerciseId: exerciseId, setIndex: 0);
      await expectRejected(
        insertWorkoutSet(db, workoutExerciseId: exerciseId, setIndex: 0),
      );
      final sessionId = await insertSession(db);
      final sessionExerciseId = await insertSessionExercise(
        db,
        sessionId: sessionId,
      );
      await insertSet(
        db,
        sessionExerciseId: sessionExerciseId,
        plannedRestSeconds: null,
      );
      await expectRejected(
        insertSet(
          db,
          sessionExerciseId: sessionExerciseId,
          setIndex: 1,
          plannedRestSeconds: -1,
        ),
      );
      await (db.delete(
        db.workoutExercise,
      )..where((row) => row.id.equals(exerciseId))).go();
      expect(await db.select(db.workoutSet).get(), isEmpty);
    },
  );

  test('rejects inconsistent completion and rest groups', () async {
    final sessionId = await insertSession(db, includeRest: true);
    final exerciseId = await insertSessionExercise(db, sessionId: sessionId);

    await expectRejected(
      insertSet(db, sessionExerciseId: exerciseId, completed: true),
    );
    await expectRejected(
      insertSet(
        db,
        sessionExerciseId: exerciseId,
        completed: false,
        completedAt: startedAt,
      ),
    );
    await insertSet(
      db,
      sessionExerciseId: exerciseId,
      completed: true,
      completedAt: startedAt,
    );
    await insertSet(
      db,
      sessionExerciseId: exerciseId,
      setIndex: 1,
      completed: false,
    );

    await expectRejected(insertSession(db, restStartedAt: startedAt));
    await expectRejected(
      insertSession(
        db,
        restStartedAt: startedAt,
        restDurationSeconds: 90,
        restTargetAt: startedAt.add(const Duration(seconds: 91)),
      ),
    );
    await expectRejected(insertSession(db, status: 'complete'));
  });

  test('rejects invalid schedule and session links', () async {
    final templateId = await workoutId();
    final scheduleId = await insertSchedule(db, workoutId: templateId);
    final otherScheduleId = await insertSchedule(
      db,
      workoutId: templateId,
      date: '2026-09-23',
    );
    final sessionId = await insertSession(
      db,
      workoutId: templateId,
      scheduleEntryId: scheduleId,
    );

    await expectRejected(
      insertSchedule(db, workoutId: templateId, status: 'missed'),
    );
    await expectRejected(
      insertSchedule(
        db,
        workoutId: templateId,
        status: 'planned',
        sessionId: sessionId,
      ),
    );
    await expectRejected(
      insertSchedule(
        db,
        workoutId: templateId,
        status: 'skipped',
        sessionId: sessionId,
      ),
    );
    await expectRejected(
      insertSchedule(db, workoutId: templateId, status: 'completed_by_session'),
    );
    await expectRejected(
      (db.update(
        db.scheduleEntry,
      )..where((row) => row.id.equals(scheduleId))).write(
        ScheduleEntryCompanion(
          status: const Value('completed_by_session'),
          sessionId: Value(sessionId),
        ),
      ),
    );

    await (db.update(db.session)..where((row) => row.id.equals(sessionId)))
        .write(const SessionCompanion(status: Value('finished')));
    await expectRejected(
      (db.update(
        db.scheduleEntry,
      )..where((row) => row.id.equals(otherScheduleId))).write(
        ScheduleEntryCompanion(
          status: const Value('completed_by_session'),
          sessionId: Value(sessionId),
        ),
      ),
    );
    await (db.update(
      db.scheduleEntry,
    )..where((row) => row.id.equals(scheduleId))).write(
      ScheduleEntryCompanion(
        status: const Value('completed_by_session'),
        sessionId: Value(sessionId),
      ),
    );
    final otherWorkoutId = await workoutId();
    await expectRejected(
      (db.update(db.session)..where((row) => row.id.equals(sessionId))).write(
        SessionCompanion(workoutId: Value(otherWorkoutId)),
      ),
    );
    await expectRejected(
      (db.update(db.session)..where((row) => row.id.equals(sessionId))).write(
        const SessionCompanion(scheduleEntryId: Value(null)),
      ),
    );
  });

  test('cascades owned children and preserves historical sessions', () async {
    final templateId = await workoutId();
    final exerciseId = await insertExercise(db, workoutId: templateId);
    final scheduleId = await insertSchedule(db, workoutId: templateId);
    final sessionId = await insertSession(
      db,
      workoutId: templateId,
      scheduleEntryId: scheduleId,
    );
    final snapshotId = await insertSessionExercise(db, sessionId: sessionId);
    final setId = await insertSet(db, sessionExerciseId: snapshotId);

    await expectRejected(db.delete(db.workout).go());
    expect(await db.select(db.workout).get(), hasLength(1));
    expect(await db.select(db.scheduleEntry).get(), hasLength(1));

    await (db.update(db.session)..where((row) => row.id.equals(sessionId)))
        .write(const SessionCompanion(status: Value('finished')));
    await (db.update(
      db.scheduleEntry,
    )..where((row) => row.id.equals(scheduleId))).write(
      ScheduleEntryCompanion(
        status: const Value('completed_by_session'),
        sessionId: Value(sessionId),
      ),
    );

    await (db.delete(
      db.scheduleEntry,
    )..where((row) => row.id.equals(scheduleId))).go();
    final preserved = await (db.select(
      db.session,
    )..where((row) => row.id.equals(sessionId))).getSingle();
    expect(preserved.scheduleEntryId, isNull);
    expect(preserved.workoutId, templateId);
    expect(
      await (db.select(
        db.sessionExercise,
      )..where((row) => row.id.equals(snapshotId))).getSingleOrNull(),
      isNotNull,
    );

    await (db.delete(
      db.workout,
    )..where((row) => row.id.equals(templateId))).go();
    final afterTemplateDelete = await (db.select(
      db.session,
    )..where((row) => row.id.equals(sessionId))).getSingle();
    expect(afterTemplateDelete.workoutId, isNull);
    expect(afterTemplateDelete.workoutNameSnapshot, 'Push');
    expect(
      await (db.select(
        db.workoutExercise,
      )..where((row) => row.id.equals(exerciseId))).getSingleOrNull(),
      isNull,
    );
    expect(
      await (db.select(
        db.sessionSet,
      )..where((row) => row.id.equals(setId))).getSingleOrNull(),
      isNotNull,
    );

    await (db.delete(
      db.session,
    )..where((row) => row.id.equals(sessionId))).go();
    expect(await db.select(db.sessionExercise).get(), isEmpty);
    expect(await db.select(db.sessionSet).get(), isEmpty);
  });

  test('restricts deleting a session linked as completed', () async {
    final templateId = await workoutId();
    final scheduleId = await insertSchedule(db, workoutId: templateId);
    final sessionId = await insertSession(
      db,
      workoutId: templateId,
      scheduleEntryId: scheduleId,
      status: 'finished',
    );
    await (db.update(
      db.scheduleEntry,
    )..where((row) => row.id.equals(scheduleId))).write(
      ScheduleEntryCompanion(
        status: const Value('completed_by_session'),
        sessionId: Value(sessionId),
      ),
    );

    await expectRejected(
      (db.delete(db.session)..where((row) => row.id.equals(sessionId))).go(),
    );
    expect(await db.select(db.session).get(), hasLength(1));
    expect(await db.select(db.scheduleEntry).get(), hasLength(1));
  });
}
