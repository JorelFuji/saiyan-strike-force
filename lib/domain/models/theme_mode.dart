import 'package:flutter/material.dart';

import '../../core/failure.dart';
import '../../core/result.dart';

/// User-selected app appearance persisted in SQLite settings.
enum VulcanThemeMode {
  dark('dark'),
  light('light'),
  system('system');

  const VulcanThemeMode(this.wireValue);
  final String wireValue;

  ThemeMode get materialThemeMode => switch (this) {
    VulcanThemeMode.dark => ThemeMode.dark,
    VulcanThemeMode.light => ThemeMode.light,
    VulcanThemeMode.system => ThemeMode.system,
  };

  static Result<VulcanThemeMode> fromWire(String value) {
    final wire = value.trim();
    if (wire.isEmpty) {
      return const Err(
        ValidationFailure('Theme mode wire value must not be blank.'),
      );
    }
    return switch (wire) {
      'dark' => const Ok(VulcanThemeMode.dark),
      'light' => const Ok(VulcanThemeMode.light),
      'system' => const Ok(VulcanThemeMode.system),
      _ => Err(ValidationFailure('Unknown theme mode wire value: $wire')),
    };
  }
}
