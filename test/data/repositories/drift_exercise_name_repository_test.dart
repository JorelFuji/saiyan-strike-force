import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';
import 'package:vulcan_fitness/data/repositories/drift_exercise_name_repository.dart';
import 'package:vulcan_fitness/domain/models/exercise_name.dart';

import '../database/database_fixture.dart';

void main() {
  late AppDatabase database;
  late DriftExerciseNameRepository repository;
  var nextOrder = 0;

  setUp(() {
    database = openTestDatabase();
    repository = DriftExerciseNameRepository(database);
    nextOrder = 0;
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> workoutAt(DateTime createdAt) {
    return database
        .into(database.workout)
        .insert(
          WorkoutCompanion.insert(name: 'Template', createdAt: createdAt),
        );
  }

  Future<int> templateExercise(
    int workoutId,
    String name, {
    String? normalized,
  }) async {
    final id = await insertExercise(
      database,
      workoutId: workoutId,
      orderIndex: nextOrder++,
    );
    await (database.update(
      database.workoutExercise,
    )..where((row) => row.id.equals(id))).write(
      WorkoutExerciseCompanion(
        name: Value(name),
        normalizedName: Value(normalized ?? normalizeExerciseName(name)),
      ),
    );
    return id;
  }

  Future<int> sessionExercise(
    DateTime at,
    String name, {
    String? normalized,
  }) async {
    final sessionId = await insertSession(database, startedAtOverride: at);
    return insertSessionExercise(
      database,
      sessionId: sessionId,
      nameSnapshot: name,
      normalizedName: normalized ?? normalizeExerciseName(name),
    );
  }

  Future<List<ExerciseNameSuggestion>> suggestions() async {
    final result = await repository.listSuggestions();
    return (result as Ok<List<ExerciseNameSuggestion>>).value;
  }

  List<String> displays(List<ExerciseNameSuggestion> values) =>
      values.map((value) => value.display).toList();

  test('returns an empty list for an empty database', () async {
    expect(await suggestions(), isEmpty);
  });

  test('includes template-only and session-only names', () async {
    await templateExercise(await workoutAt(DateTime.utc(2026, 9, 1)), 'Squat');
    await sessionExercise(DateTime.utc(2026, 9, 2), 'Deadlift');

    final values = await suggestions();

    expect(displays(values), ['Deadlift', 'Squat']);
    expect(values.map((value) => value.normalized), ['deadlift', 'squat']);
  });

  test('deduplicates case and whitespace variants to one key', () async {
    final workoutId = await workoutAt(DateTime.utc(2026, 9, 1));
    await templateExercise(workoutId, 'Bench Press');
    await templateExercise(workoutId, 'bench   press');
    await sessionExercise(DateTime.utc(2026, 8, 1), '  BENCH\tPRESS ');

    final values = await suggestions();

    expect(values, hasLength(1));
    expect(values.single.normalized, 'bench press');
  });

  test('prefers the newer session spelling over an older template', () async {
    await templateExercise(
      await workoutAt(DateTime.utc(2026, 9, 1)),
      'bench press',
    );
    await sessionExercise(DateTime.utc(2026, 9, 10), 'Bench Press');

    expect(displays(await suggestions()), ['Bench Press']);
  });

  test('prefers a newer template spelling over an older session', () async {
    await sessionExercise(DateTime.utc(2026, 9, 1), 'Bench Press');
    await templateExercise(
      await workoutAt(DateTime.utc(2026, 9, 10)),
      'bench press',
    );

    expect(displays(await suggestions()), ['bench press']);
  });

  test('timestamp ties prefer the session, then the higher child id', () async {
    final at = DateTime.utc(2026, 9, 5);
    final workoutId = await workoutAt(at);
    await templateExercise(workoutId, 'Row');
    await templateExercise(workoutId, 'ROW');
    expect(displays(await suggestions()), ['ROW']);

    await sessionExercise(at, 'row');
    expect(displays(await suggestions()), ['row']);

    await sessionExercise(at, 'Row ');
    expect(displays(await suggestions()), ['Row']);
  });

  test('orders suggestions by normalized key regardless of spelling', () async {
    final workoutId = await workoutAt(DateTime.utc(2026, 9, 1));
    await templateExercise(workoutId, 'squat');
    await templateExercise(workoutId, 'Bench Press');
    await templateExercise(workoutId, 'deadlift');
    await templateExercise(workoutId, 'Curl');

    expect(displays(await suggestions()), [
      'Bench Press',
      'Curl',
      'deadlift',
      'squat',
    ]);
  });

  test('includes names from archived templates', () async {
    final workoutId = await workoutAt(DateTime.utc(2026, 9, 1));
    await templateExercise(workoutId, 'Archived Lift');
    await (database.update(database.workout)
          ..where((row) => row.id.equals(workoutId)))
        .write(WorkoutCompanion(archivedAt: Value(DateTime.utc(2026, 9, 2))));

    expect(displays(await suggestions()), ['Archived Lift']);
  });

  test('does not mutate stored data', () async {
    await templateExercise(await workoutAt(DateTime.utc(2026, 9, 1)), 'Squat');
    final before = await database.select(database.workoutExercise).get();

    await suggestions();

    expect(await database.select(database.workoutExercise).get(), before);
  });

  test('returns a validation failure for a corrupt normalized key', () async {
    await templateExercise(
      await workoutAt(DateTime.utc(2026, 9, 1)),
      'Squat',
      normalized: 'not squat',
    );

    final result = await repository.listSuggestions();

    expect(result, isA<Err<List<ExerciseNameSuggestion>>>());
    expect((result as Err).failure, isA<ValidationFailure>());
  });

  test('returns a validation failure for a blank stored display', () async {
    await sessionExercise(DateTime.utc(2026, 9, 1), '   ', normalized: '');

    final result = await repository.listSuggestions();

    expect((result as Err).failure, isA<ValidationFailure>());
  });

  test('maps database exceptions to storage failure', () async {
    await database.customStatement('DROP TABLE session_exercise');

    final result = await repository.listSuggestions();

    expect(result, isA<Err<List<ExerciseNameSuggestion>>>());
    expect((result as Err).failure, isA<StorageFailure>());
  });
}
