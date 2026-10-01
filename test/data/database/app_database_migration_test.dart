import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';

import '../../generated_migrations/app_database/generated/schema.dart';

void main() {
  test('migrates an empty v1 database and writes version 2 metadata', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 2);

    expect((await db.select(db.appMetadata).get()).single.value, '2');
    expect(
      (await db.customSelect('PRAGMA user_version').get()).single.read<int>(
        'user_version',
      ),
      2,
    );
    expect(await db.select(db.workoutSet).get(), isEmpty);
  });
}
