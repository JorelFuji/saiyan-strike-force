import 'package:drift/drift.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/mass.dart';
import '../../domain/models/theme_mode.dart';
import '../../domain/repositories/settings_repository.dart';
import '../database/app_database.dart';

const displayMassUnitSettingsKey = 'display_mass_unit';
const restAutoStartSettingsKey = 'rest_auto_start';
const themeModeSettingsKey = 'theme_mode';

final class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this.database, {required this.firstUseDefault});

  final AppDatabase database;
  final MassUnit firstUseDefault;

  @override
  Future<Result<MassUnit>> readOrCreateDisplayMassUnit() async {
    try {
      return await database.transaction(() async {
        final existing =
            await (database.select(database.settings)
                  ..where((row) => row.key.equals(displayMassUnitSettingsKey)))
                .getSingleOrNull();
        if (existing != null) {
          return _decode(existing.value);
        }

        await database
            .into(database.settings)
            .insert(
              SettingsCompanion.insert(
                key: displayMassUnitSettingsKey,
                value: firstUseDefault.wireValue,
              ),
              mode: InsertMode.insertOrIgnore,
            );

        final row = await (database.select(
          database.settings,
        )..where((t) => t.key.equals(displayMassUnitSettingsKey))).getSingle();
        return _decode(row.value);
      });
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<VulcanThemeMode>> readOrCreateThemeMode() async {
    try {
      return await database.transaction(() async {
        final existing =
            await (database.select(database.settings)
                  ..where((row) => row.key.equals(themeModeSettingsKey)))
                .getSingleOrNull();
        if (existing != null) {
          return _decodeThemeMode(existing.value);
        }

        await database
            .into(database.settings)
            .insert(
              SettingsCompanion.insert(
                key: themeModeSettingsKey,
                value: VulcanThemeMode.system.wireValue,
              ),
              mode: InsertMode.insertOrIgnore,
            );

        final row = await (database.select(
          database.settings,
        )..where((t) => t.key.equals(themeModeSettingsKey))).getSingle();
        return _decodeThemeMode(row.value);
      });
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> updateThemeMode(VulcanThemeMode mode) async {
    try {
      await database.transaction(() async {
        await database
            .into(database.settings)
            .insertOnConflictUpdate(
              SettingsCompanion.insert(
                key: themeModeSettingsKey,
                value: mode.wireValue,
              ),
            );
      });
      return const Ok(null);
    } catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<bool>> readOrCreateRestAutoStart() async {
    try {
      return await database.transaction(() async {
        final existing =
            await (database.select(database.settings)
                  ..where((row) => row.key.equals(restAutoStartSettingsKey)))
                .getSingleOrNull();
        if (existing != null) {
          return _decodeRestAutoStart(existing.value);
        }

        await database
            .into(database.settings)
            .insert(
              SettingsCompanion.insert(
                key: restAutoStartSettingsKey,
                value: 'true',
              ),
              mode: InsertMode.insertOrIgnore,
            );

        final row = await (database.select(
          database.settings,
        )..where((t) => t.key.equals(restAutoStartSettingsKey))).getSingle();
        return _decodeRestAutoStart(row.value);
      });
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  Result<bool> _decodeRestAutoStart(String wire) {
    return switch (wire) {
      'true' => const Ok(true),
      'false' => const Ok(false),
      _ => const Err(
        ValidationFailure('Stored rest auto-start value is invalid.'),
      ),
    };
  }

  Result<VulcanThemeMode> _decodeThemeMode(String wire) {
    final decoded = VulcanThemeMode.fromWire(wire);
    return switch (decoded) {
      Ok() => decoded,
      Err(:final failure) => Err(
        ValidationFailure(
          'Stored theme mode is invalid.',
          cause: failure.message,
        ),
      ),
    };
  }

  Result<MassUnit> _decode(String wire) {
    final decoded = MassUnit.fromWire(wire);
    return switch (decoded) {
      Ok() => decoded,
      Err(:final failure) => Err(
        ValidationFailure(
          'Stored display mass unit is invalid.',
          cause: failure.message,
        ),
      ),
    };
  }

  Failure _storageFailure(Object error, StackTrace stack) => StorageFailure(
    'Settings storage operation failed.',
    cause: error,
    stackTrace: stack,
  );
}
