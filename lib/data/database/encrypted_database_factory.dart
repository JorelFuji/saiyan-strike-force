import 'dart:io';

import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../../core/failure.dart';
import '../../core/result.dart';
import '../services/database_key.dart';
import 'app_database.dart';

/// Opens a sqlite3mc database only after its cipher and key are verified.
class EncryptedDatabaseFactory {
  EncryptedDatabaseFactory({bool Function()? isCipherAvailable})
    : _isCipherAvailable = isCipherAvailable ?? _cipherAvailable;

  final bool Function() _isCipherAvailable;

  Future<Result<AppDatabase>> open({
    required File file,
    required DatabaseKey key,
  }) async {
    if (!await file.parent.exists()) {
      return const Err(StorageFailure('Database storage is unavailable.'));
    }
    if (!_isCipherAvailable()) {
      return const Err(
        EncryptionFailure('Encrypted database could not be opened.'),
      );
    }

    AppDatabase? database;
    try {
      final executor = NativeDatabase.createInBackground(
        file,
        setup: (rawDatabase) => _setupEncryptedDatabase(rawDatabase, key),
      );
      database = AppDatabase(executor);
      // This forces background setup and Drift migrations before returning.
      await database
          .customSelect('SELECT name FROM sqlite_master LIMIT 1')
          .get();
      return Ok(database);
    } catch (error) {
      await database?.close();
      final message = error.toString();
      if (message.contains(_encryptionSetupMarker)) {
        return const Err(
          EncryptionFailure('Encrypted database could not be opened.'),
        );
      }
      return const Err(StorageFailure('Database storage is unavailable.'));
    }
  }

  static void _setupEncryptedDatabase(Database rawDatabase, DatabaseKey key) {
    try {
      final cipher = rawDatabase.select('PRAGMA cipher');
      if (cipher.isEmpty || '${cipher.first.columnAt(0)}'.isEmpty) {
        throw StateError('cipher unavailable');
      }
      rawDatabase.execute('PRAGMA hexkey = "${key.hex}"');
      rawDatabase.select('SELECT name FROM sqlite_master LIMIT 1');
    } catch (_) {
      throw StateError(_encryptionSetupMarker);
    }
  }

  static const _encryptionSetupMarker = 'vulcan_encryption_setup_failed';

  static bool _cipherAvailable() => true;
}
