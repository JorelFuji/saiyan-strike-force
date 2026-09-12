// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:vulcan/core/di/register_module.dart' as _i919;
import 'package:vulcan/data/csv/csv_service.dart' as _i751;
import 'package:vulcan/data/local/preferences/preferences_data_source.dart'
    as _i111;
import 'package:vulcan/data/local/secure_storage/secure_storage_data_source.dart'
    as _i265;
import 'package:vulcan/data/repositories/settings_repository_impl.dart' as _i50;
import 'package:vulcan/domain/repositories/settings_repository.dart' as _i385;
import 'package:vulcan/features/settings/cubit/settings_cubit.dart' as _i254;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.flutterSecureStorage,
    );
    gh.lazySingleton<_i751.CsvService>(() => _i751.CsvService());
    gh.lazySingleton<_i265.SecureStorageDataSource>(
      () => _i265.SecureStorageDataSource(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i111.PreferencesDataSource>(
      () => _i111.PreferencesDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i385.SettingsRepository>(
      () => _i50.SettingsRepositoryImpl(gh<_i111.PreferencesDataSource>()),
    );
    gh.factory<_i254.SettingsCubit>(
      () => _i254.SettingsCubit(gh<_i385.SettingsRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i919.RegisterModule {}
