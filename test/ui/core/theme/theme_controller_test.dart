import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/theme_mode.dart';
import 'package:vulcan_fitness/ui/core/theme/theme_controller.dart';

import '../../../support/fake_settings_repository.dart';

void main() {
  test('initialize restores committed theme from settings', () async {
    final settings = FakeSettingsRepository(
      themeModeResult: const Ok(VulcanThemeMode.dark),
    );
    final controller = ThemeController(settingsRepository: settings);

    await controller.initialize();

    expect(settings.themeModeReadCalls, 1);
    expect(controller.phase, ThemeControllerPhase.ready);
    expect(controller.committed, VulcanThemeMode.dark);
    expect(controller.themeMode, ThemeMode.dark);
    controller.dispose();
  });

  test('selectTheme notifies only after successful commit', () async {
    final settings = FakeSettingsRepository(
      themeModeResult: const Ok(VulcanThemeMode.system),
    );
    final controller = ThemeController(settingsRepository: settings);
    await controller.initialize();

    var notifications = 0;
    controller.addListener(() => notifications++);

    final result = await controller.selectTheme(VulcanThemeMode.light);
    expect(result, isA<Ok<void>>());
    expect(settings.updateThemeModeCalls, 1);
    expect(controller.committed, VulcanThemeMode.light);
    expect(controller.themeMode, ThemeMode.light);
    expect(notifications, greaterThan(0));

    controller.dispose();
  });

  test('failed update keeps previous committed selection', () async {
    final settings = FakeSettingsRepository(
      themeModeResult: const Ok(VulcanThemeMode.light),
      updateThemeModeResult: const Err(StorageFailure('write failed')),
    );
    final controller = ThemeController(settingsRepository: settings);
    await controller.initialize();

    final result = await controller.selectTheme(VulcanThemeMode.dark);
    expect(result, isA<Err<void>>());
    expect(controller.committed, VulcanThemeMode.light);
    expect(controller.themeMode, ThemeMode.light);

    controller.dispose();
  });

  test('initialize failure is recoverable via retry', () async {
    final settings = FakeSettingsRepository(
      themeModeResult: const Err(StorageFailure('read failed')),
    );
    final controller = ThemeController(settingsRepository: settings);
    await controller.initialize();
    expect(controller.phase, ThemeControllerPhase.failure);

    settings.themeModeResult = const Ok(VulcanThemeMode.system);
    await controller.retry();
    expect(controller.phase, ThemeControllerPhase.ready);
    expect(controller.committed, VulcanThemeMode.system);

    controller.dispose();
  });

  test('dispose completes after initialize', () async {
    final settings = FakeSettingsRepository();
    final controller = ThemeController(settingsRepository: settings);
    await controller.initialize();
    controller.dispose();
  });
}
