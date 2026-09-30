import 'package:drift/drift.dart';

import 'app_database.steps.dart';

part 'app_database.g.dart';

/// Version-1 local database.
///
/// Callers supply a [QueryExecutor]. Production opening is owned by the
/// encrypted database factory so migrations never receive an unverified file.
@DriftDatabase(include: {'schema.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

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
            steps: migrationSteps(),
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
}
