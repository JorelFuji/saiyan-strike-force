import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/theme_mode.dart';

void main() {
  test('fromWire accepts stable values and rejects invalid data', () {
    for (final mode in VulcanThemeMode.values) {
      final decoded = VulcanThemeMode.fromWire(mode.wireValue);
      expect(decoded, isA<Ok<VulcanThemeMode>>());
      expect((decoded as Ok<VulcanThemeMode>).value, mode);
    }
    final trimmed = VulcanThemeMode.fromWire('  light ');
    expect(trimmed, isA<Ok<VulcanThemeMode>>());
    expect((trimmed as Ok<VulcanThemeMode>).value, VulcanThemeMode.light);
    expect(VulcanThemeMode.fromWire(''), isA<Err<VulcanThemeMode>>());
    expect(VulcanThemeMode.fromWire('auto'), isA<Err<VulcanThemeMode>>());
    expect(
      (VulcanThemeMode.fromWire('bogus') as Err<VulcanThemeMode>).failure,
      isA<ValidationFailure>(),
    );
  });

  test('maps to Material ThemeMode', () {
    expect(VulcanThemeMode.dark.materialThemeMode, ThemeMode.dark);
    expect(VulcanThemeMode.light.materialThemeMode, ThemeMode.light);
    expect(VulcanThemeMode.system.materialThemeMode, ThemeMode.system);
  });
}
