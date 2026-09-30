import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../core/failure.dart';
import '../../core/result.dart';

abstract interface class ApplicationSupportDirectory {
  Future<Directory> get();
}

final class PathProviderApplicationSupportDirectory
    implements ApplicationSupportDirectory {
  @override
  Future<Directory> get() => getApplicationSupportDirectory();
}

abstract interface class DirectoryBackupProtection {
  Future<void> excludeFromBackup(Directory directory);
}

final class IosDirectoryBackupProtection implements DirectoryBackupProtection {
  IosDirectoryBackupProtection({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('vulcan_fitness/storage');

  final MethodChannel _channel;

  @override
  Future<void> excludeFromBackup(Directory directory) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod<void>('excludeFromBackup', <String, String>{
        'directoryPath': directory.path,
      });
    }
  }
}

/// Resolves the sole application database directory and protects it first.
class DatabaseDirectoryService {
  DatabaseDirectoryService({
    required this.applicationSupportDirectory,
    required this.backupProtection,
  });

  factory DatabaseDirectoryService.production() => DatabaseDirectoryService(
    applicationSupportDirectory: PathProviderApplicationSupportDirectory(),
    backupProtection: IosDirectoryBackupProtection(),
  );

  static const databaseFilename = 'vulcan_fitness.sqlite';
  final ApplicationSupportDirectory applicationSupportDirectory;
  final DirectoryBackupProtection backupProtection;

  Future<Result<Directory>> resolveAndProtect() async {
    try {
      final support = await applicationSupportDirectory.get();
      final databaseDirectory = Directory(
        path.join(support.path, 'vulcan_fitness'),
      );
      await databaseDirectory.create(recursive: true);
      await backupProtection.excludeFromBackup(databaseDirectory);
      return Ok(databaseDirectory);
    } catch (_) {
      return const Err(StorageFailure('Database storage is unavailable.'));
    }
  }

  File databaseFile(Directory directory) =>
      File(path.join(directory.path, databaseFilename));
}
