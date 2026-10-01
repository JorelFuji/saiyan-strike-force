import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/clock.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';

import '../database/database_fixture.dart';

import 'package:vulcan_fitness/data/repositories/drift_workout_repository.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';

void main() {
  late AppDatabase database;
  late DriftWorkoutRepository repository;
  final now = DateTime.utc(2026, 9, 25, 12);

  setUp(() {
    database = openTestDatabase();
    repository = DriftWorkoutRepository(database, _FixedClock(now));
  });
  tearDown(() => database.close());

  test('creates, reads, watches, orders, and archives templates', () async {
    final first = await repository.create(_draft(' First ', 'Bench Press'));
    final second = await repository.create(_draft('Second', 'Squat'));
    final firstValue = (first as Ok<WorkoutTemplate>).value;
    expect(firstValue.name, 'First');
    expect(firstValue.createdAt, now);
    expect(firstValue.exercises.single.normalizedName, 'bench press');
    final persistedExercise = await (database.select(
      database.workoutExercise,
    )..where((row) => row.workoutId.equals(firstValue.id))).getSingle();
    final persistedSets =
        await (database.select(database.workoutSet)..where(
              (row) => row.workoutExerciseId.equals(persistedExercise.id),
            ))
            .get();
    expect(persistedSets, hasLength(3));
    expect(persistedSets.map((row) => row.setIndex), [0, 1, 2]);
    expect(
      (await repository.getById(firstValue.id)),
      isA<Ok<WorkoutTemplate?>>(),
    );
    expect(
      (await repository.watchAll().first as Ok<List<WorkoutTemplate>>).value
          .map((e) => e.name),
      ['First', 'Second'],
    );
    await repository.archive(firstValue.id);
    expect(
      (await repository.watchAll().first as Ok<List<WorkoutTemplate>>).value
          .map((e) => e.name),
      ['Second'],
    );
    expect(
      (await repository.getById(
        firstValue.id,
      ) as Ok<WorkoutTemplate?>).value!.archivedAt,
      now,
    );
    expect(
      (await repository.watchAll(includeArchived: true).first
              as Ok<List<WorkoutTemplate>>)
          .value,
      hasLength(2),
    );
    expect(second, isA<Ok<WorkoutTemplate>>());
  });

  test('updates and duplicates without sharing mutable persistence', () async {
    final created = (await repository.create(
      _draft('Push', 'Bench Press'),
    ) as Ok<WorkoutTemplate>).value;
    final changedExercise = (TemplateExercise.create(
      name: 'Row',
      plannedSets: 4,
      reps: const Amrap(),
      load: const NoLoad(),
      restSeconds: 0,
    ) as Ok<TemplateExercise>).value;
    final updated = (await repository.update(
      (WorkoutTemplate.create(
        id: created.id,
        name: 'Push+',
        notes: 'changed',
        createdAt: created.createdAt,
        exercises: [changedExercise],
      ) as Ok<WorkoutTemplate>).value,
    ) as Ok<WorkoutTemplate>).value;
    expect(updated.exercises.single.name, 'Row');
    final updatedSets = await database.select(database.workoutSet).get();
    expect(updatedSets, hasLength(4));
    expect(updatedSets.map((row) => row.setIndex), [0, 1, 2, 3]);
    final duplicate =
        (await repository.duplicate(updated.id) as Ok<WorkoutTemplate>).value;
    expect(duplicate.id, isNot(updated.id));
    expect(duplicate.name, updated.name);
    expect(duplicate.archivedAt, isNull);
    await repository.delete(duplicate.id);
    expect(
      (await repository.getById(
        updated.id,
      ) as Ok<WorkoutTemplate?>).value!.exercises.single.name,
      'Row',
    );
  });

  test(
    'returns typed not-found outcomes and rejects scheduled deletion',
    () async {
      expect(await repository.archive(999), isA<Err<WorkoutTemplate>>());
      expect(
        (await repository.delete(999) as Err<void>).failure,
        isA<NotFoundFailure>(),
      );
      final created = (await repository.create(
        _draft('Scheduled', 'Bench'),
      ) as Ok<WorkoutTemplate>).value;
      await insertSchedule(database, workoutId: created.id);
      final result = await repository.delete(created.id);
      expect(result, isA<Err<void>>());
      expect(
        (await repository.getById(created.id) as Ok<WorkoutTemplate?>).value,
        isNotNull,
      );
    },
  );

  test(
    'round-trips every structured load variant and keeps archive idempotent',
    () async {
      final exercises = <TemplateExercise>[
        _exercise(
          'None',
          const NoLoad(),
          (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
          supersetGroup: 4,
        ),
        _exercise(
          'Bodyweight',
          const BodyweightLoad(),
          const Amrap(),
          supersetGroup: 4,
        ),
        _exercise(
          'Absolute',
          (LoadPrescription.absolute(10) as Ok<LoadPrescription>).value,
          (RepPrescription.range(3, 5) as Ok<RepPrescription>).value,
        ),
        _exercise(
          'Percentage',
          (LoadPrescription.percentage(50) as Ok<LoadPrescription>).value,
          const Amrap(),
        ),
        _exercise(
          'RPE',
          (LoadPrescription.targetRpe(7.5) as Ok<LoadPrescription>).value,
          const Amrap(),
        ),
        _exercise(
          'Text',
          (LoadPrescription.text('plates') as Ok<LoadPrescription>).value,
          const Amrap(),
        ),
      ];
      final draft = (WorkoutTemplateDraft.create(
        name: 'All loads',
        exercises: exercises,
      ) as Ok<WorkoutTemplateDraft>).value;
      final created =
          (await repository.create(draft) as Ok<WorkoutTemplate>).value;
      final read =
          (await repository.getById(created.id) as Ok<WorkoutTemplate?>).value!;
      expect(read.exercises.map((exercise) => exercise.load.type), [
        LoadType.none,
        LoadType.bodyweight,
        LoadType.absolute,
        LoadType.percentage,
        LoadType.targetRpe,
        LoadType.text,
      ]);
      expect(read.exercises.take(2).map((exercise) => exercise.supersetGroup), [
        4,
        4,
      ]);
      final duplicate =
          (await repository.duplicate(created.id) as Ok<WorkoutTemplate>).value;
      expect(
        duplicate.exercises.take(2).map((exercise) => exercise.supersetGroup),
        [4, 4],
      );
      final archived =
          (await repository.archive(created.id) as Ok<WorkoutTemplate>).value;
      final archivedAgain =
          (await repository.archive(created.id) as Ok<WorkoutTemplate>).value;
      expect(archivedAgain.archivedAt, archived.archivedAt);
    },
  );

  test(
    'restores archive metadata without rewriting exercises or sessions',
    () async {
      final created = (await repository.create(
        _draft('Restore', 'Bench'),
      ) as Ok<WorkoutTemplate>).value;
      final sessionId = await insertSession(
        database,
        workoutId: created.id,
        status: 'finished',
      );
      await insertSessionExercise(database, sessionId: sessionId);

      final archived =
          (await repository.archive(created.id) as Ok<WorkoutTemplate>).value;
      final restored =
          (await repository.restore(created.id) as Ok<WorkoutTemplate>).value;
      final restoredAgain =
          (await repository.restore(created.id) as Ok<WorkoutTemplate>).value;

      expect(archived.archivedAt, now);
      expect(restored.archivedAt, isNull);
      expect(restoredAgain.archivedAt, isNull);
      expect(restored.createdAt, created.createdAt);
      expect(restored.exercises.single.name, created.exercises.single.name);
      expect(
        restored.exercises.single.normalizedName,
        created.exercises.single.normalizedName,
      );
      expect(
        await (database.select(
          database.sessionExercise,
        )..where((row) => row.sessionId.equals(sessionId))).get(),
        hasLength(1),
      );
      expect(await repository.restore(999), isA<Err<WorkoutTemplate>>());
      expect(
        (await repository.restore(999) as Err<WorkoutTemplate>).failure,
        isA<NotFoundFailure>(),
      );
    },
  );

  test(
    'maps corrupt persisted prescription fields to validation failure',
    () async {
      final id = await insertWorkout(database, name: 'Corrupt');
      await database.customStatement('PRAGMA ignore_check_constraints = ON');
      await database.customStatement(
        'INSERT INTO workout_exercise '
        '(workout_id, name, normalized_name, order_index, planned_sets, rep_type, '
        'load_type, rest_seconds) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [id, 'Bad', 'bad', 0, 1, 'unknown', 'none', 0],
      );
      await database.customStatement('PRAGMA ignore_check_constraints = OFF');
      final result = await repository.getById(id);
      expect(result, isA<Err<WorkoutTemplate?>>());
      expect(
        (result as Err<WorkoutTemplate?>).failure,
        isA<ValidationFailure>(),
      );
    },
  );

  test('deletes only the template while retaining session snapshots', () async {
    final created = (await repository.create(
      _draft('History', 'Bench'),
    ) as Ok<WorkoutTemplate>).value;
    final sessionId = await insertSession(
      database,
      workoutId: created.id,
      status: 'finished',
    );
    await insertSessionExercise(database, sessionId: sessionId);
    expect(await repository.delete(created.id), isA<Ok<void>>());
    final session = await (database.select(
      database.session,
    )..where((row) => row.id.equals(sessionId))).getSingle();
    final snapshots = await (database.select(
      database.sessionExercise,
    )..where((row) => row.sessionId.equals(sessionId))).get();
    expect(session.workoutId, isNull);
    expect(snapshots, hasLength(1));
  });

  test('updating a template never rewrites session snapshot rows', () async {
    final created = (await repository.create(
      _draft('Snapshot source', 'Bench'),
    ) as Ok<WorkoutTemplate>).value;
    final archived =
        (await repository.archive(created.id) as Ok<WorkoutTemplate>).value;
    final sessionId = await insertSession(
      database,
      workoutId: created.id,
      status: 'finished',
    );
    final sessionExerciseId = await insertSessionExercise(
      database,
      sessionId: sessionId,
      nameSnapshot: 'Bench snapshot',
    );
    await insertSet(
      database,
      sessionExerciseId: sessionExerciseId,
      completed: true,
      completedAt: now,
    );
    final sessionsBefore = await database.select(database.session).get();
    final exercisesBefore = await database
        .select(database.sessionExercise)
        .get();
    final setsBefore = await database.select(database.sessionSet).get();
    final replacement = _exercise(
      'Row',
      const BodyweightLoad(),
      (RepPrescription.fixed(10) as Ok<RepPrescription>).value,
    );
    final second = _exercise(
      'Press',
      const NoLoad(),
      (RepPrescription.range(6, 8) as Ok<RepPrescription>).value,
    );

    final updated = (await repository.update(
      (WorkoutTemplate.create(
        id: archived.id,
        name: 'Snapshot source revised',
        notes: 'reordered',
        createdAt: archived.createdAt,
        archivedAt: archived.archivedAt,
        exercises: [replacement, second],
      ) as Ok<WorkoutTemplate>).value,
    ) as Ok<WorkoutTemplate>).value;

    expect(updated.id, created.id);
    expect(updated.createdAt, created.createdAt);
    expect(updated.archivedAt, archived.archivedAt);
    expect(updated.exercises.map((exercise) => exercise.name), [
      'Row',
      'Press',
    ]);
    expect(await database.select(database.session).get(), sessionsBefore);
    expect(
      await database.select(database.sessionExercise).get(),
      exercisesBefore,
    );
    expect(await database.select(database.sessionSet).get(), setsBefore);
    final templateRows =
        await (database.select(database.workoutExercise)
              ..where((row) => row.workoutId.equals(created.id))
              ..orderBy([(row) => OrderingTerm.asc(row.orderIndex)]))
            .get();
    expect(templateRows.map((row) => row.orderIndex), [0, 1]);
  });
}

TemplateExercise _exercise(
  String name,
  LoadPrescription load,
  RepPrescription reps, {
  int? supersetGroup,
}) => (TemplateExercise.create(
  name: name,
  plannedSets: 1,
  reps: reps,
  load: load,
  restSeconds: 0,
  supersetGroup: supersetGroup,
) as Ok<TemplateExercise>).value;

WorkoutTemplateDraft _draft(String name, String exerciseName) {
  final exercise = (TemplateExercise.create(
    name: exerciseName,
    plannedSets: 3,
    reps: (RepPrescription.range(5, 8) as Ok<RepPrescription>).value,
    load: (LoadPrescription.absolute(102058280) as Ok<LoadPrescription>).value,
    restSeconds: 90,
    supersetGroup: null,
  ) as Ok<TemplateExercise>).value;
  return (WorkoutTemplateDraft.create(
    name: name,
    notes: 'notes',
    exercises: [exercise],
  ) as Ok<WorkoutTemplateDraft>).value;
}

final class _FixedClock implements Clock {
  const _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}
