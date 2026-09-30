import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/data/database/encrypted_database_factory.dart';
import 'package:vulcan_fitness/data/services/database_key.dart';

void main() {
  late Directory directory;
  final key = (DatabaseKey.fromHex('ab' * 32) as Ok<DatabaseKey>).value;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('vulcan_encrypted_');
  });
  tearDown(() => directory.delete(recursive: true));

  test('creates and reopens a sqlite3mc database only with its key', () async {
    final file = File('${directory.path}/database.sqlite');
    final factory = EncryptedDatabaseFactory();

    final opened = await factory.open(file: file, key: key);
    expect(opened, isA<Ok>());
    final database = (opened as Ok).value;
    await database.close();

    final unkeyed = sqlite3.open(file.path);
    addTearDown(unkeyed.close);
    expect(
      () => unkeyed.select('SELECT name FROM sqlite_master'),
      throwsA(isA<SqliteException>()),
    );

    final reopened = await factory.open(file: file, key: key);
    expect(reopened, isA<Ok>());
    await (reopened as Ok).value.close();
  });

  test('rejects a different valid key for an existing database', () async {
    final file = File('${directory.path}/database.sqlite');
    final factory = EncryptedDatabaseFactory();
    final opened = await factory.open(file: file, key: key);
    await (opened as Ok).value.close();
    final wrongKey = (DatabaseKey.fromHex('cd' * 32) as Ok<DatabaseKey>).value;

    final rejected = await factory.open(file: file, key: wrongKey);

    expect(rejected, isA<Err>());
    expect((rejected as Err).failure, isA<EncryptionFailure>());
  });

  test('sqlite3mc cipher support is present in the linked native library', () {
    final database = sqlite3.openInMemory();
    addTearDown(database.close);

    final cipher = database.select('PRAGMA cipher');

    expect(cipher, isNotEmpty);
    expect('${cipher.first.columnAt(0)}', isNotEmpty);
  });

  test('rejects an empty key before opening', () async {
    final invalid = DatabaseKey.fromHex('');

    expect(invalid, isA<Err<DatabaseKey>>());
    expect((invalid as Err<DatabaseKey>).failure, isA<EncryptionFailure>());
  });

  test('fails closed when cipher support is unavailable', () async {
    final factory = EncryptedDatabaseFactory(isCipherAvailable: () => false);

    final result = await factory.open(
      file: File('${directory.path}/database.sqlite'),
      key: key,
    );

    expect(result, isA<Err>());
    expect((result as Err).failure, isA<EncryptionFailure>());
  });

  test('maps an unavailable parent directory to storage failure', () async {
    final result = await EncryptedDatabaseFactory().open(
      file: File('${directory.path}/missing/database.sqlite'),
      key: key,
    );

    expect(result, isA<Err>());
    expect((result as Err).failure, isA<StorageFailure>());
  });
}
