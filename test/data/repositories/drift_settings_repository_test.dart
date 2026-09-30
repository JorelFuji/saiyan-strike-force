import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';
import 'package:vulcan_fitness/data/repositories/drift_settings_repository.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/domain/models/theme_mode.dart';

import '../database/database_fixture.dart';

void main() {
  late AppDatabase database;
  late DriftSettingsRepository repository;

  setUp(() {
    database = openTestDatabase();
    repository = DriftSettingsRepository(
      database,
      firstUseDefault: MassUnit.lb,
    );
  });
  tearDown(() => database.close());

  test('creates and returns the injected first-use default', () async {
    final result = await repository.readOrCreateDisplayMassUnit();
    expect(result, const Ok(MassUnit.lb));

    final row = await (database.select(
      database.settings,
    )..where((t) => t.key.equals(displayMassUnitSettingsKey))).getSingle();
    expect(row.value, 'lb');
  });

  test('returns existing kg and lb values without rewriting them', () async {
    await database
        .into(database.settings)
        .insert(
          SettingsCompanion.insert(
            key: displayMassUnitSettingsKey,
            value: 'kg',
          ),
        );

    final kgResult = await DriftSettingsRepository(
      database,
      firstUseDefault: MassUnit.lb,
    ).readOrCreateDisplayMassUnit();
    expect(kgResult, const Ok(MassUnit.kg));

    await (database.delete(
      database.settings,
    )..where((t) => t.key.equals(displayMassUnitSettingsKey))).go();
    await database
        .into(database.settings)
        .insert(
          SettingsCompanion.insert(
            key: displayMassUnitSettingsKey,
            value: 'lb',
          ),
        );

    final lbResult = await DriftSettingsRepository(
      database,
      firstUseDefault: MassUnit.kg,
    ).readOrCreateDisplayMassUnit();
    expect(lbResult, const Ok(MassUnit.lb));
  });

  test('returns validation failure for corrupt stored values', () async {
    await database
        .into(database.settings)
        .insert(
          SettingsCompanion.insert(
            key: displayMassUnitSettingsKey,
            value: 'stones',
          ),
        );

    final result = await repository.readOrCreateDisplayMassUnit();
    expect(result, isA<Err<MassUnit>>());
    expect((result as Err<MassUnit>).failure, isA<ValidationFailure>());
  });

  test('duplicate initialization returns the same persisted value', () async {
    final first = await repository.readOrCreateDisplayMassUnit();
    final second = await repository.readOrCreateDisplayMassUnit();
    expect(first, second);

    final rows = await database.select(database.settings).get();
    expect(
      rows.where((row) => row.key == displayMassUnitSettingsKey),
      hasLength(1),
    );
  });

  test('creates rest auto-start default on and round-trips false', () async {
    final first = await repository.readOrCreateRestAutoStart();
    expect(first, const Ok(true));

    await database
        .into(database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: restAutoStartSettingsKey,
            value: 'false',
          ),
        );

    final second = await repository.readOrCreateRestAutoStart();
    expect(second, const Ok(false));
  });

  test('creates default system theme mode on first read', () async {
    final result = await repository.readOrCreateThemeMode();
    expect(result, const Ok(VulcanThemeMode.system));

    final row = await (database.select(
      database.settings,
    )..where((t) => t.key.equals(themeModeSettingsKey))).getSingle();
    expect(row.value, 'system');
  });

  test('reads stored dark and light theme modes', () async {
    await database
        .into(database.settings)
        .insert(
          SettingsCompanion.insert(key: themeModeSettingsKey, value: 'dark'),
        );
    expect(
      await repository.readOrCreateThemeMode(),
      const Ok(VulcanThemeMode.dark),
    );

    await (database.delete(
      database.settings,
    )..where((t) => t.key.equals(themeModeSettingsKey))).go();
    await database
        .into(database.settings)
        .insert(
          SettingsCompanion.insert(key: themeModeSettingsKey, value: 'light'),
        );
    expect(
      await repository.readOrCreateThemeMode(),
      const Ok(VulcanThemeMode.light),
    );
  });

  test('theme mode duplicate initialization creates one row', () async {
    final first = await repository.readOrCreateThemeMode();
    final second = await repository.readOrCreateThemeMode();
    expect(first, second);
    final rows = await (database.select(
      database.settings,
    )..where((t) => t.key.equals(themeModeSettingsKey))).get();
    expect(rows, hasLength(1));
  });

  test('corrupt theme mode returns validation failure', () async {
    await database
        .into(database.settings)
        .insert(
          SettingsCompanion.insert(key: themeModeSettingsKey, value: 'sepia'),
        );
    final result = await repository.readOrCreateThemeMode();
    expect(result, isA<Err<VulcanThemeMode>>());
    expect((result as Err<VulcanThemeMode>).failure, isA<ValidationFailure>());
  });

  test('updateThemeMode round trips committed value', () async {
    await repository.readOrCreateThemeMode();
    expect(
      await repository.updateThemeMode(VulcanThemeMode.dark),
      isA<Ok<void>>(),
    );

    final reopened = DriftSettingsRepository(
      database,
      firstUseDefault: MassUnit.lb,
    );
    expect(
      await reopened.readOrCreateThemeMode(),
      const Ok(VulcanThemeMode.dark),
    );
  });

  test(
    'updateThemeMode returns storage failure when database is closed',
    () async {
      final isolated = openTestDatabase();
      addTearDown(isolated.close);
      final isolatedRepository = DriftSettingsRepository(
        isolated,
        firstUseDefault: MassUnit.lb,
      );
      await isolatedRepository.readOrCreateThemeMode();
      await isolated.close();
      final result = await isolatedRepository.updateThemeMode(
        VulcanThemeMode.light,
      );
      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<StorageFailure>());
    },
  );

  test('does not mutate stored session canonical mass', () async {
    final sessionId = await insertSession(database);
    final exerciseId = await insertSessionExercise(
      database,
      sessionId: sessionId,
    );
    await insertSet(
      database,
      sessionExerciseId: exerciseId,
      actualWeightCanonicalMg: 102058280,
    );

    expect(
      await repository.readOrCreateDisplayMassUnit(),
      const Ok(MassUnit.lb),
    );

    final setRow = await (database.select(
      database.sessionSet,
    )..where((row) => row.sessionExerciseId.equals(exerciseId))).getSingle();
    expect(setRow.plannedWeightCanonicalMg, 102058280);
    expect(setRow.actualWeightCanonicalMg, 102058280);
  });
}
