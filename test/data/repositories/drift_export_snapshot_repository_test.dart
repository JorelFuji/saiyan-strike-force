import 'package:drift/native.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';
import 'package:vulcan_fitness/data/repositories/drift_export_snapshot_repository.dart';

import '../database/database_fixture.dart';

void main() {
  test('exports all public collections in a stable portable form', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db
        .into(db.settings)
        .insert(SettingsCompanion.insert(key: 'units', value: 'kg'));
    final workoutId = await db
        .into(db.workout)
        .insert(
          WorkoutCompanion.insert(name: 'Plan', createdAt: DateTime.utc(2026)),
        );
    final workoutExerciseId = await insertExercise(db, workoutId: workoutId);
    await insertWorkoutSet(
      db,
      workoutExerciseId: workoutExerciseId,
      restSeconds: 150,
    );
    final sessionId = await db
        .into(db.session)
        .insert(
          SessionCompanion.insert(
            workoutNameSnapshot: 'Historical plan',
            startedAt: DateTime.utc(2026, 1),
            timezone: 'America/Denver',
            status: 'abandoned',
          ),
        );
    final sessionExerciseId = await insertSessionExercise(
      db,
      sessionId: sessionId,
    );
    await insertSet(
      db,
      sessionExerciseId: sessionExerciseId,
      completed: true,
      completedAt: DateTime.utc(2026, 1, 1, 1),
      actualWeightCanonicalMg: 110000000,
      actualLoadType: 'absolute',
    );
    await insertSchedule(db, workoutId: workoutId);
    final result = await DriftExportSnapshotRepository(db).readSnapshot();
    expect(result, isA<Ok>());
    final collections = (result as Ok).value;
    expect(collections.settings.single['key'], 'units');
    expect(collections.workouts.single['id'], workoutId);
    expect(collections.sessions.single['id'], sessionId);
    expect(collections.sessions.single['status'], 'abandoned');
    expect(
      collections.sessions.single['startedAt'],
      '2026-01-01T00:00:00.000Z',
    );
    expect(collections.sessions.single['timezone'], 'America/Denver');
    expect(collections.workoutExercises.single['id'], workoutExerciseId);
    expect(collections.workoutExercises.single['weightCanonicalMg'], 102058280);
    expect(
      collections.workoutSets.single['workoutExerciseId'],
      workoutExerciseId,
    );
    expect(collections.workoutSets.single['restSeconds'], 150);
    expect(collections.scheduleEntries.single['workoutId'], workoutId);
    expect(collections.sessionExercises.single['sessionId'], sessionId);
    expect(collections.sessionSets.single['completed'], isTrue);
    expect(
      collections.sessionSets.single['actualWeightCanonicalMg'],
      110000000,
    );
    expect(
      collections.sessionSets.single['completedAt'],
      '2026-01-01T01:00:00.000Z',
    );
    expect(collections.sessionSets.single['actualMinReps'], isNull);
    expect(collections.sessionSets.single['plannedRestSeconds'], isNull);
    expect(collections.toJson().containsKey('app_metadata'), isFalse);
    expect(collections.toJson().keys, [
      'settings',
      'workouts',
      'workoutExercises',
      'workoutSets',
      'scheduleEntries',
      'sessions',
      'sessionExercises',
      'sessionSets',
    ]);
  });

  test('unknown stored prescription wire returns validation failure', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final workoutId = await db
        .into(db.workout)
        .insert(
          WorkoutCompanion.insert(name: 'Plan', createdAt: DateTime.utc(2026)),
        );
    await insertExercise(db, workoutId: workoutId);
    await db.customStatement('PRAGMA ignore_check_constraints = ON');
    await db.customStatement("UPDATE workout_exercise SET rep_type = 'future'");

    final result = await DriftExportSnapshotRepository(db).readSnapshot();
    expect(result, isA<Err>());
    expect((result as Err).failure, isA<ValidationFailure>());
  });

  test('retains every session status and nullable rest fields', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    for (final status in [
      'draft',
      'running',
      'paused',
      'finished',
      'abandoned',
    ]) {
      await insertSession(
        db,
        status: status,
        includeRest: status == 'running',
        workoutNameSnapshot: status,
      );
    }

    final result = await DriftExportSnapshotRepository(db).readSnapshot();
    final sessions = (result as Ok).value.sessions;
    expect(sessions.map((row) => row['status']), [
      'draft',
      'running',
      'paused',
      'finished',
      'abandoned',
    ]);
    expect(sessions[1]['restStartedAt'], '2026-09-01T15:00:00.000Z');
    expect(sessions[1]['restDurationSeconds'], 90);
    expect(sessions[1]['restTargetAt'], '2026-09-01T15:01:30.000Z');
    expect(sessions.first['restStartedAt'], isNull);
    expect(sessions.last['endedAt'], isNull);
  });
}
