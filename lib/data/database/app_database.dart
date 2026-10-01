import 'package:drift/drift.dart';

import 'app_database.steps.dart';

part 'app_database.g.dart';

/// Current local database schema.
///
/// Callers supply a [QueryExecutor]. Production opening is owned by the
/// encrypted database factory so migrations never receive an unverified file.
@DriftDatabase(include: {'schema.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => _migrate(migrator, from: 0, to: schemaVersion),
    onUpgrade: (migrator, from, to) => _migrate(migrator, from: from, to: to),
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Structural work and the metadata version write commit together.
  ///
  /// Foreign keys are disabled only around that transaction. `PRAGMA
  /// foreign_keys` is a no-op inside a transaction, so it is changed outside
  /// and restored even when the transaction rolls back.
  Future<void> _migrate(
    Migrator migrator, {
    required int from,
    required int to,
  }) async {
    await customStatement('PRAGMA foreign_keys = OFF');
    try {
      await transaction(() async {
        if (from == 0) {
          await migrator.createAll();
        } else {
          await migrator.runMigrationSteps(
            from: from,
            to: to,
            steps: migrationSteps(from1To2: _from1To2),
          );
        }
        await customStatement(
          "INSERT INTO app_metadata (key, value) VALUES ('schema_version', ?) "
          'ON CONFLICT(key) DO UPDATE SET value = excluded.value',
          [to.toString()],
        );
        final violations = await customSelect('PRAGMA foreign_key_check').get();
        if (violations.isNotEmpty) {
          throw StateError(
            'Migration left foreign key violations: '
            '${violations.map((row) => row.data).join(', ')}',
          );
        }
        // Drift writes user_version only after beforeOpen returns. Persist it
        // in this transaction so a crash cannot leave a created schema at
        // version 0, which would retry index creation and fail.
        await customStatement('PRAGMA user_version = $to');
      });
    } finally {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  }

  Future<void> _from1To2(Migrator m, Schema2 schema) async {
    await m.createTable(schema.workoutSet);
    await m.createIndex(schema.workoutSetParentOrder);
    await m.addColumn(schema.sessionSet, schema.sessionSet.plannedRestSeconds);
    await customStatement('''
      WITH RECURSIVE seq(n) AS (
        SELECT 0
        UNION ALL
        SELECT n + 1 FROM seq
        WHERE n + 1 < (SELECT MAX(planned_sets) FROM workout_exercise)
      )
      INSERT INTO workout_set (
        workout_exercise_id, set_index, rep_type, target_reps, min_reps,
        max_reps, load_type, weight_canonical_mg, percentage, target_rpe,
        freeform_text, rest_seconds
      )
      SELECT we.id, seq.n, we.rep_type, we.target_reps, we.min_reps,
        we.max_reps, we.load_type, we.weight_canonical_mg, we.percentage,
        we.target_rpe, we.freeform_text, we.rest_seconds
      FROM workout_exercise we
      JOIN seq ON seq.n < we.planned_sets
      ORDER BY we.id, seq.n
    ''');
  }
}
