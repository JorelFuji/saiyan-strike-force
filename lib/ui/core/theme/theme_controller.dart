import 'package:flutter/material.dart';

import '../../../core/result.dart';
import '../../../domain/models/theme_mode.dart';
import '../../../domain/repositories/settings_repository.dart';

enum ThemeControllerPhase { loading, ready, failure }

/// Root-owned theme state: reads on launch, commits before notifying listeners.
final class ThemeController extends ChangeNotifier {
  ThemeController({required SettingsRepository settingsRepository})
    : _settings = settingsRepository;

  final SettingsRepository _settings;

  ThemeControllerPhase _phase = ThemeControllerPhase.loading;
  VulcanThemeMode? _committed;
  String? _failureMessage;

  ThemeControllerPhase get phase => _phase;
  VulcanThemeMode? get committed => _committed;
  String? get failureMessage => _failureMessage;

  ThemeMode get themeMode =>
      (_committed ?? VulcanThemeMode.system).materialThemeMode;

  Future<void> initialize() async {
    _phase = ThemeControllerPhase.loading;
    _failureMessage = null;
    notifyListeners();

    final result = await _settings.readOrCreateThemeMode();
    switch (result) {
      case Ok(:final value):
        _committed = value;
        _phase = ThemeControllerPhase.ready;
        _failureMessage = null;
      case Err(:final failure):
        _phase = ThemeControllerPhase.failure;
        _failureMessage = failure.message;
    }
    notifyListeners();
  }

  /// Persists [mode] first; updates [committed] and [themeMode] only on `Ok`.
  Future<Result<void>> selectTheme(VulcanThemeMode mode) async {
    final result = await _settings.updateThemeMode(mode);
    if (result case Ok()) {
      _committed = mode;
      if (_phase == ThemeControllerPhase.failure) {
        _phase = ThemeControllerPhase.ready;
      }
      _failureMessage = null;
      notifyListeners();
    }
    return result;
  }

  Future<void> retry() => initialize();
}
