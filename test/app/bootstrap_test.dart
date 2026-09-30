import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/app/app.dart';
import 'package:vulcan_fitness/app/bootstrap.dart';
import 'package:vulcan_fitness/app/dependencies.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';
import 'package:vulcan_fitness/data/database/encrypted_database_factory.dart';
import 'package:vulcan_fitness/data/services/database_directory_service.dart';
import 'package:vulcan_fitness/data/services/database_key.dart';
import 'package:vulcan_fitness/data/services/secure_key_service.dart';

import '../support/fake_notification_service.dart';
import '../support/fake_session_repository.dart';

void main() {
  test(
    'bootstraps in order and mounts normal app only after migration open',
    () async {
      final events = <String>[];
      Widget? mounted;
      final directory = await Directory.systemTemp.createTemp(
        'vulcan_bootstrap_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final database = AppDatabase(NativeDatabase.memory());
      await database.customSelect('SELECT 1').get();
      addTearDown(database.close);

      final bootstrap = Bootstrap(
        directoryService: FakeDirectoryService(directory, events),
        keyService: FakeKeyService(events, Ok(DatabaseKeyTest.key)),
        databaseFactory: FakeDatabaseFactory(events, Ok(database)),
        initializeBindings: () => events.add('bindings'),
        runApplication: (app) => mounted = app,
        createDependencies: (opened) => AppDependencies(
          database: opened,
          notificationService: FakeNotificationService(),
        ),
      );

      await bootstrap.start();

      expect(events, ['bindings', 'directory', 'key:false', 'open']);
      expect(mounted, isA<VulcanApp>());
      expect((mounted! as VulcanApp).startupResumeSessionId, isNull);
    },
  );

  test('initializes notifications before resume lookup', () async {
    final directory = await Directory.systemTemp.createTemp(
      'vulcan_bootstrap_notify_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final database = AppDatabase(NativeDatabase.memory());
    await database.customSelect('SELECT 1').get();
    addTearDown(database.close);
    final fakeNotifications = FakeNotificationService();
    final fakeRepository = FakeSessionRepository()..resumeResult = const Ok(3);
    final events = <String>[];
    Widget? mounted;
    final bootstrap = Bootstrap(
      directoryService: FakeDirectoryService(directory, events),
      keyService: FakeKeyService(events, Ok(DatabaseKeyTest.key)),
      databaseFactory: FakeDatabaseFactory(events, Ok(database)),
      initializeBindings: () => events.add('bindings'),
      runApplication: (app) => mounted = app,
      createDependencies: (opened) => AppDependencies(
        database: opened,
        sessionRepository: fakeRepository,
        notificationService: fakeNotifications,
      ),
    );

    await bootstrap.start();

    expect(fakeNotifications.initializeCalls, 1);
    expect(fakeRepository.resumeCalls, 1);
    expect(mounted, isA<VulcanApp>());
    expect((mounted! as VulcanApp).startupResumeSessionId, 3);
  });

  test(
    'runs resume lookup after dependencies and retains resumable id',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'vulcan_bootstrap_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final database = AppDatabase(NativeDatabase.memory());
      await database.customSelect('SELECT 1').get();
      addTearDown(database.close);
      final fakeRepository = FakeSessionRepository()
        ..resumeResult = const Ok(12);
      Widget? mounted;
      final bootstrap = Bootstrap(
        directoryService: FakeDirectoryService(directory, <String>[]),
        keyService: FakeKeyService(<String>[], Ok(DatabaseKeyTest.key)),
        databaseFactory: FakeDatabaseFactory(<String>[], Ok(database)),
        initializeBindings: () {},
        runApplication: (app) => mounted = app,
        createDependencies: (opened) => AppDependencies(
          database: opened,
          sessionRepository: fakeRepository,
          notificationService: FakeNotificationService(),
        ),
      );

      await bootstrap.start();

      expect(fakeRepository.resumeCalls, 1);
      expect(mounted, isA<VulcanApp>());
      expect((mounted! as VulcanApp).startupResumeSessionId, 12);
    },
  );

  test(
    'fails closed when resume lookup fails and closes the database',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'vulcan_bootstrap_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final database = AppDatabase(NativeDatabase.memory());
      await database.customSelect('SELECT 1').get();
      Widget? mounted;
      final fakeRepository = FakeSessionRepository()
        ..resumeResult = const Err(
          ValidationFailure('Multiple active sessions were found in storage.'),
        );
      final bootstrap = Bootstrap(
        directoryService: FakeDirectoryService(directory, <String>[]),
        keyService: FakeKeyService(<String>[], Ok(DatabaseKeyTest.key)),
        databaseFactory: FakeDatabaseFactory(<String>[], Ok(database)),
        initializeBindings: () {},
        runApplication: (app) => mounted = app,
        createDependencies: (opened) => AppDependencies(
          database: opened,
          sessionRepository: fakeRepository,
          notificationService: FakeNotificationService(),
        ),
      );

      await bootstrap.start();

      expect(fakeRepository.resumeCalls, 1);
      expect(mounted, isA<FatalStorageApp>());
      await expectLater(
        database.customSelect('SELECT 1').get(),
        throwsA(anything),
      );
    },
  );

  test('mounts only generic fatal storage UI on any stage failure', () async {
    final directory = await Directory.systemTemp.createTemp(
      'vulcan_bootstrap_',
    );
    addTearDown(() => directory.delete(recursive: true));
    Widget? mounted;
    final bootstrap = Bootstrap(
      directoryService: FakeDirectoryService(
        directory,
        <String>[],
        result: const Err(StorageFailure('private cause')),
      ),
      keyService: FakeKeyService(
        <String>[],
        const Err(EncryptionFailure('private cause')),
      ),
      databaseFactory: FakeDatabaseFactory(
        <String>[],
        const Err(EncryptionFailure('private cause')),
      ),
      initializeBindings: () {},
      runApplication: (app) => mounted = app,
    );

    await bootstrap.start();
    expect(mounted, isA<FatalStorageApp>());
  });

  test('fails closed for binding, key, and database-open failures', () async {
    final directory = await Directory.systemTemp.createTemp(
      'vulcan_bootstrap_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final validKey = Ok(DatabaseKeyTest.key);
    final stages = <({BindingInitializer initialize, Result<DatabaseKey> key})>[
      (initialize: () => throw StateError('private cause'), key: validKey),
      (initialize: () {}, key: const Err(EncryptionFailure('private cause'))),
      (initialize: () {}, key: validKey),
    ];

    for (final stage in stages) {
      Widget? mounted;
      final bootstrap = Bootstrap(
        directoryService: FakeDirectoryService(directory, <String>[]),
        keyService: FakeKeyService(<String>[], stage.key),
        databaseFactory: FakeDatabaseFactory(
          <String>[],
          const Err(EncryptionFailure('private cause')),
        ),
        initializeBindings: stage.initialize,
        runApplication: (app) => mounted = app,
      );
      await bootstrap.start();
      expect(mounted, isA<FatalStorageApp>());
    }
  });

  test('closes a created database when normal app mounting fails', () async {
    final directory = await Directory.systemTemp.createTemp(
      'vulcan_bootstrap_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final database = AppDatabase(NativeDatabase.memory());
    await database.customSelect('SELECT 1').get();
    Widget? mounted;
    final bootstrap = Bootstrap(
      directoryService: FakeDirectoryService(directory, <String>[]),
      keyService: FakeKeyService(<String>[], Ok(DatabaseKeyTest.key)),
      databaseFactory: FakeDatabaseFactory(<String>[], Ok(database)),
      initializeBindings: () {},
      runApplication: (app) {
        if (app is VulcanApp) throw StateError('mount failed');
        mounted = app;
      },
    );

    await bootstrap.start();
    expect(mounted, isA<FatalStorageApp>());
    await expectLater(
      database.customSelect('SELECT 1').get(),
      throwsA(anything),
    );
  });
}

final class DatabaseKeyTest {
  static final key = (DatabaseKey.fromHex('ab' * 32) as Ok<DatabaseKey>).value;
}

final class FakeDirectoryService extends DatabaseDirectoryService {
  FakeDirectoryService(this.directory, this.events, {this.result})
    : super(
        applicationSupportDirectory: _UnusedSupportDirectory(),
        backupProtection: _UnusedBackupProtection(),
      );

  final Directory directory;
  final List<String> events;
  final Result<Directory>? result;

  @override
  Future<Result<Directory>> resolveAndProtect() async {
    events.add('directory');
    return result ?? Ok(directory);
  }
}

final class FakeKeyService extends SecureKeyService {
  FakeKeyService(this.events, this.result)
    : super(storage: _UnusedStorage(), entropy: _UnusedEntropy());

  final List<String> events;
  final Result<DatabaseKey> result;

  @override
  Future<Result<DatabaseKey>> loadOrCreate({
    required bool databaseExists,
  }) async {
    events.add('key:$databaseExists');
    return result;
  }
}

final class FakeDatabaseFactory extends EncryptedDatabaseFactory {
  FakeDatabaseFactory(this.events, this.result);

  final List<String> events;
  final Result<AppDatabase> result;

  @override
  Future<Result<AppDatabase>> open({
    required File file,
    required DatabaseKey key,
  }) async {
    events.add('open');
    return result;
  }
}

final class _UnusedSupportDirectory implements ApplicationSupportDirectory {
  @override
  Future<Directory> get() => throw UnimplementedError();
}

final class _UnusedBackupProtection implements DirectoryBackupProtection {
  @override
  Future<void> excludeFromBackup(Directory directory) =>
      throw UnimplementedError();
}

final class _UnusedStorage implements SecureKeyStorage {
  @override
  Future<String?> read() => throw UnimplementedError();

  @override
  Future<void> write(String value) => throw UnimplementedError();
}

final class _UnusedEntropy implements EntropySource {
  @override
  List<int> bytes(int length) => throw UnimplementedError();
}
