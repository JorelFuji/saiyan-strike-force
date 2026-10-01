import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/clock.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/theme_mode.dart';
import 'package:vulcan_fitness/domain/models/export_document.dart';
import 'package:vulcan_fitness/domain/repositories/export_snapshot_repository.dart';
import 'package:vulcan_fitness/domain/services/export_share_service.dart';
import 'package:vulcan_fitness/domain/usecases/export_data.dart';
import 'package:vulcan_fitness/ui/core/theme/theme_controller.dart';
import 'package:vulcan_fitness/ui/settings/settings_cubit.dart';
import 'package:vulcan_fitness/ui/settings/settings_state.dart';

import '../../support/fake_settings_repository.dart';

final class _ExportRepo implements ExportSnapshotRepository {
  final Completer<Result<ExportCollections>> pending = Completer();
  int calls = 0;
  @override
  Future<Result<ExportCollections>> readSnapshot() {
    calls++;
    return pending.future;
  }
}

final class _ExportShare implements ExportShareService {
  int calls = 0;
  ExportShareOrigin? origin;
  @override
  Future<Result<ExportShareOutcome>> share(
    ExportDocument document, {
    required ExportShareOrigin origin,
  }) async {
    calls++;
    this.origin = origin;
    return const Ok(ExportShareOutcome.shared);
  }
}

final class _ExportClock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026);
}

void main() {
  test(
    'export is single-flight and forwards share origin and outcome',
    () async {
      final settings = FakeSettingsRepository(
        themeModeResult: const Ok(VulcanThemeMode.system),
      );
      final controller = ThemeController(settingsRepository: settings);
      await controller.initialize();
      final repository = _ExportRepo();
      final share = _ExportShare();
      final workflow = ExportData(
        repository: repository,
        shareService: share,
        clock: _ExportClock(),
        appVersion: '1.0.0+1',
      );
      final cubit = SettingsCubit(
        themeController: controller,
        exportData: workflow,
      );
      addTearDown(() {
        cubit.close();
        controller.dispose();
      });
      await cubit.initialize();
      const origin = ExportShareOrigin(x: 4, y: 8, width: 48, height: 48);

      final first = cubit.export(origin);
      await cubit.export(origin);
      expect(cubit.state.isExporting, isTrue);
      expect(repository.calls, 1);
      repository.pending.complete(
        Ok(
          ExportCollections(
            settings: const [],
            workouts: const [],
            workoutExercises: const [],
            workoutSets: const [],
            scheduleEntries: const [],
            sessions: const [],
            sessionExercises: const [],
            sessionSets: const [],
          ),
        ),
      );
      await first;

      expect(cubit.state.isExporting, isFalse);
      expect(cubit.state.exportOutcome, ExportShareOutcome.shared);
      expect(share.calls, 1);
      expect(share.origin, origin);
    },
  );
  test(
    'loads the committed theme and saves after persistence succeeds',
    () async {
      final settings = FakeSettingsRepository(
        themeModeResult: const Ok(VulcanThemeMode.system),
      );
      final controller = ThemeController(settingsRepository: settings);
      await controller.initialize();
      final cubit = SettingsCubit(themeController: controller);
      addTearDown(() {
        cubit.close();
        controller.dispose();
      });

      await cubit.initialize();
      expect(cubit.state.phase, SettingsLoadPhase.ready);
      expect(cubit.state.committedMode, VulcanThemeMode.system);

      await cubit.selectTheme(VulcanThemeMode.dark);
      expect(cubit.state.committedMode, VulcanThemeMode.dark);
      expect(settings.lastUpdatedThemeMode, VulcanThemeMode.dark);
    },
  );

  test('failed save retains committed theme and exposes retry state', () async {
    final settings = FakeSettingsRepository(
      themeModeResult: const Ok(VulcanThemeMode.light),
      updateThemeModeResult: const Err(StorageFailure('write failed')),
    );
    final controller = ThemeController(settingsRepository: settings);
    await controller.initialize();
    final cubit = SettingsCubit(themeController: controller);
    addTearDown(() {
      cubit.close();
      controller.dispose();
    });

    await cubit.initialize();
    await cubit.selectTheme(VulcanThemeMode.dark);

    expect(cubit.state.phase, SettingsLoadPhase.failure);
    expect(cubit.state.committedMode, VulcanThemeMode.light);
    expect(cubit.state.pendingMode, VulcanThemeMode.dark);
    expect(cubit.state.failureMessage, 'write failed');
  });

  test(
    'retry commits the pending selection after a transient failure',
    () async {
      final settings = FakeSettingsRepository(
        themeModeResult: const Ok(VulcanThemeMode.system),
        updateThemeModeResult: const Err(StorageFailure('temporary failure')),
      );
      final controller = ThemeController(settingsRepository: settings);
      await controller.initialize();
      final cubit = SettingsCubit(themeController: controller);
      addTearDown(() {
        cubit.close();
        controller.dispose();
      });

      await cubit.initialize();
      await cubit.selectTheme(VulcanThemeMode.light);
      settings.updateThemeModeResult = const Ok(null);
      await cubit.retry();

      expect(cubit.state.phase, SettingsLoadPhase.ready);
      expect(cubit.state.committedMode, VulcanThemeMode.light);
    },
  );
}
