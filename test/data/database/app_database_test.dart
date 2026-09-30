import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';

import '../../generated_migrations/app_database/generated/schema.dart';
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

  test('fresh database matches the committed v1 snapshot', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    await verifier.migrateAndValidate(db, 1);
  });

  test('seeds schema version and leaves settings empty', () async {
    final metadata = await db.select(db.appMetadata).get();
    expect(metadata, hasLength(1));
    expect(metadata.single.key, 'schema_version');
    expect(metadata.single.value, '1');

    final userVersion = await db.customSelect('PRAGMA user_version').get();
    expect(userVersion.single.read<int>('user_version'), 1);

    expect(await db.select(db.settings).get(), isEmpty);
  });

  test('creates the eight v1 tables and lookup indexes', () async {
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
          'ORDER BY name',
        )
        .get();
    expect(tables.map((row) => row.read<String>('name')), [
      'app_metadata',
      'schedule_entry',
      'session',
      'session_exercise',
      'session_set',
      'settings',
      'workout',
      'workout_exercise',
    ]);

    final indexes = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name NOT LIKE 'sqlite_%' ORDER BY name",
        )
        .get();
    expect(indexes.map((row) => row.read<String>('name')), [
      'schedule_entry_date_status',
      'schedule_entry_workout',
      'session_chronology',
      'session_exercise_normalized_name',
      'session_exercise_parent_order',
      'session_resume_status',
      'session_schedule_entry',
      'session_set_parent_order',
      'session_workout',
      'workout_exercise_normalized_name',
      'workout_exercise_parent_order',
    ]);
  });

  test('enables foreign keys before normal access', () async {
    final raw = sqlite3.openInMemory();
    final opened = AppDatabase(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    addTearDown(() async {
      await opened.close();
      raw.close();
    });

    await opened.customSelect('SELECT 1').get();
    expect(raw.select('PRAGMA foreign_keys').single['foreign_keys'], 1);
  });

  test('a late constraint failure rolls back the whole transaction', () async {
    await expectLater(
      db.transaction(() async {
        final workoutId = await insertWorkout(db);
        final sessionId = await insertSession(db, workoutId: workoutId);
        final exerciseId = await insertSessionExercise(
          db,
          sessionId: sessionId,
        );
        await insertSet(db, sessionExerciseId: exerciseId, completed: true);
      }),
      throwsA(isA<SqliteException>()),
    );

    expect(await db.select(db.workout).get(), isEmpty);
    expect(await db.select(db.session).get(), isEmpty);
    expect(await db.select(db.sessionExercise).get(), isEmpty);
    expect(await db.select(db.sessionSet).get(), isEmpty);
  });

  test(
    'migration failure rolls back metadata and restores foreign keys',
    () async {
      final raw = sqlite3.openInMemory();
      // Drift runs migrations below query interceptors, so reject the commit
      // that writes app_metadata. SQLite turns that commit into a rollback.
      var rejectMigrationCommit = false;
      final updates = raw.updatesSync.listen((update) {
        if (update.tableName == 'app_metadata') {
          rejectMigrationCommit = true;
        }
      });
      raw.commitFilter = () {
        if (!rejectMigrationCommit) {
          return true;
        }
        rejectMigrationCommit = false;
        return false;
      };
      addTearDown(updates.cancel);

      final failing = AppDatabase(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
      );
      addTearDown(() async {
        await failing.close();
        raw.close();
      });

      await expectLater(
        failing.customSelect('SELECT 1').get(),
        throwsA(isA<CouldNotRollBackException>()),
      );

      expect(
        raw.select(
          "SELECT name FROM sqlite_master WHERE name = 'app_metadata'",
        ),
        isEmpty,
      );
      expect(raw.select('PRAGMA user_version').single['user_version'], 0);
      expect(raw.select('PRAGMA foreign_keys').single['foreign_keys'], 1);
    },
  );

  test('reopening an existing database keeps foreign keys enabled', () async {
    final file = File(
      '${Directory.systemTemp.path}/vulcan-schema-${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    addTearDown(() {
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    final created = AppDatabase(NativeDatabase(file));
    await created.customSelect('SELECT 1').get();
    await created.close();

    final raw = sqlite3.open(file.path);
    final reopened = AppDatabase(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    addTearDown(() async {
      await reopened.close();
      raw.close();
    });

    await reopened.customSelect('SELECT 1').get();
    expect(raw.select('PRAGMA foreign_keys').single['foreign_keys'], 1);
    expect(await reopened.select(reopened.appMetadata).get(), hasLength(1));
    expect(raw.select('PRAGMA user_version').single['user_version'], 1);
  });
}
