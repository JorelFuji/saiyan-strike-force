import '../../core/result.dart';
import '../models/mass.dart';
import '../models/theme_mode.dart';

abstract interface class SettingsRepository {
  /// Reads the app-wide display mass unit, creating a locale-derived default on
  /// first use without mutating stored training values.
  Future<Result<MassUnit>> readOrCreateDisplayMassUnit();

  /// Whether completing a set should arm rest from the exercise prescription.
  Future<Result<bool>> readOrCreateRestAutoStart();

  /// Reads the app theme mode, creating `system` on first use.
  Future<Result<VulcanThemeMode>> readOrCreateThemeMode();

  /// Persists [mode]; success means the SQLite transaction committed.
  Future<Result<void>> updateThemeMode(VulcanThemeMode mode);
}
