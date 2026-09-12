import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:vulcan/core/error/failure.dart';
import 'package:vulcan/data/local/preferences/preferences_data_source.dart';
import 'package:vulcan/domain/repositories/settings_repository.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._preferences);

  static const _isDarkModeKey = 'isDarkMode';

  final PreferencesDataSource _preferences;

  @override
  TaskEither<Failure, bool> getIsDarkMode() {
    return TaskEither.tryCatch(
      () async => _preferences.getBool(_isDarkModeKey) ?? false,
      (error, _) => Failure.cache(message: error.toString()),
    );
  }

  @override
  TaskEither<Failure, Unit> setIsDarkMode(bool value) {
    return TaskEither.tryCatch(
      () async {
        final success = await _preferences.setBool(_isDarkModeKey, value);
        if (!success) {
          throw StateError('Failed to persist isDarkMode');
        }
        return unit;
      },
      (error, _) => Failure.cache(message: error.toString()),
    );
  }
}
