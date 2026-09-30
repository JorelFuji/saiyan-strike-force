import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../core/result.dart';
import '../data/database/app_database.dart';
import '../data/database/encrypted_database_factory.dart';
import '../data/services/database_directory_service.dart';
import '../data/services/flutter_local_notification_service.dart';
import '../data/services/secure_key_service.dart';
import 'app.dart';
import 'dependencies.dart';
import 'startup_session_route.dart';

typedef AppRunner = void Function(Widget app);
typedef BindingInitializer = void Function();
typedef AppDependenciesBuilder = AppDependencies Function(AppDatabase database);

/// Fail-closed composition root for the encrypted application database.
final class Bootstrap {
  Bootstrap({
    required this.directoryService,
    required this.keyService,
    required this.databaseFactory,
    BindingInitializer? initializeBindings,
    AppRunner? runApplication,
    this.createDependencies,
  }) : _initializeBindings =
           initializeBindings ?? WidgetsFlutterBinding.ensureInitialized,
       _runApplication = runApplication ?? runApp;

  factory Bootstrap.production() => Bootstrap(
    directoryService: DatabaseDirectoryService.production(),
    keyService: SecureKeyService.production(),
    databaseFactory: EncryptedDatabaseFactory(),
  );

  final DatabaseDirectoryService directoryService;
  final SecureKeyService keyService;
  final EncryptedDatabaseFactory databaseFactory;
  final BindingInitializer _initializeBindings;
  final AppRunner _runApplication;

  /// Optional test seam to inject repositories without changing startup order.
  final AppDependenciesBuilder? createDependencies;

  Future<void> start() async {
    AppDependencies? dependencies;
    try {
      _initializeBindings();
      initializeTimezoneDatabase();
      final directoryResult = await directoryService.resolveAndProtect();
      final directory = _valueOrNull(directoryResult);
      if (directory == null) return _showFatal();

      final databaseFile = directoryService.databaseFile(directory);
      final keyResult = await keyService.loadOrCreate(
        databaseExists: await databaseFile.exists(),
      );
      final key = _valueOrNull(keyResult);
      if (key == null) return _showFatal();

      final databaseResult = await databaseFactory.open(
        file: databaseFile,
        key: key,
      );
      final database = _valueOrNull(databaseResult);
      if (database == null) return _showFatal();

      final localeCountryCode = PlatformDispatcher.instance.locale.countryCode;
      dependencies =
          createDependencies?.call(database) ??
          AppDependencies(
            database: database,
            localeCountryCode:
                localeCountryCode == null || localeCountryCode.isEmpty
                ? null
                : localeCountryCode,
          );

      await dependencies.notificationService.initialize(
        onTap: dependencies.publishNotificationTap,
      );

      final launchIdResult = await dependencies.notificationService
          .readColdStartSessionId();
      final notificationSessionId = switch (launchIdResult) {
        Ok(:final value) => value,
        Err() => null,
      };

      final resumeResult = await dependencies.resumeSession();
      if (resumeResult case Err()) {
        await dependencies.close();
        dependencies = null;
        return _showFatal();
      }
      final resumableSessionId = (resumeResult as Ok<int?>).value;
      final startupResumeSessionId = resolveStartupSessionRoute(
        notificationSessionId: notificationSessionId,
        resumableSessionId: resumableSessionId,
      );

      _runApplication(
        VulcanApp(
          dependencies: dependencies,
          startupResumeSessionId: startupResumeSessionId,
        ),
      );
    } catch (_) {
      await dependencies?.close();
      _showFatal();
    }
  }

  T? _valueOrNull<T>(Result<T> result) => switch (result) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  void _showFatal() => _runApplication(const FatalStorageApp());
}
