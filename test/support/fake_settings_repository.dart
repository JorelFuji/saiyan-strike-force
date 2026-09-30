import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/domain/models/theme_mode.dart';
import 'package:vulcan_fitness/domain/repositories/settings_repository.dart';

final class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({
    this.unitResult = const Ok(MassUnit.kg),
    this.themeModeResult = const Ok(VulcanThemeMode.system),
    this.updateThemeModeResult = const Ok(null),
  });

  Result<MassUnit> unitResult;
  Result<bool> restAutoStartResult = const Ok(true);
  Result<VulcanThemeMode> themeModeResult;
  Result<void> updateThemeModeResult;
  VulcanThemeMode? lastUpdatedThemeMode;

  int readCalls = 0;
  int restAutoStartReadCalls = 0;
  int themeModeReadCalls = 0;
  int updateThemeModeCalls = 0;

  @override
  Future<Result<MassUnit>> readOrCreateDisplayMassUnit() async {
    readCalls++;
    return unitResult;
  }

  @override
  Future<Result<bool>> readOrCreateRestAutoStart() async {
    restAutoStartReadCalls++;
    return restAutoStartResult;
  }

  @override
  Future<Result<VulcanThemeMode>> readOrCreateThemeMode() async {
    themeModeReadCalls++;
    return themeModeResult;
  }

  @override
  Future<Result<void>> updateThemeMode(VulcanThemeMode mode) async {
    updateThemeModeCalls++;
    lastUpdatedThemeMode = mode;
    if (updateThemeModeResult case Ok()) {
      themeModeResult = Ok(mode);
    }
    return updateThemeModeResult;
  }
}
