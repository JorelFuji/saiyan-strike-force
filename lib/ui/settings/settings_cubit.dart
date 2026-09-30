import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/result.dart';
import '../../domain/models/theme_mode.dart';
import '../../domain/models/export_document.dart';
import '../../domain/usecases/export_data.dart';
import '../core/theme/theme_controller.dart';
import 'settings_state.dart';

final class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required this.themeController, this.exportData})
    : super(const SettingsState.loading());

  final ThemeController themeController;
  final ExportData? exportData;
  VulcanThemeMode? _queuedMode;

  Future<void> export(ExportShareOrigin origin) async {
    final workflow = exportData;
    if (workflow == null || state.isExporting) return;
    emit(
      state.copyWith(
        isExporting: true,
        clearExportOutcome: true,
        clearExportFailureMessage: true,
      ),
    );
    final result = await workflow(origin: origin);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isExporting: false,
            exportOutcome: value,
            clearExportFailureMessage: true,
          ),
        );
      case Err():
        emit(
          state.copyWith(
            isExporting: false,
            exportFailureMessage: 'Unable to export data. Try again.',
          ),
        );
    }
  }

  Future<void> retryExport(ExportShareOrigin origin) => export(origin);

  Future<void> initialize() async {
    if (themeController.committed == null) {
      await themeController.initialize();
    }
    if (isClosed) return;
    final committed = themeController.committed;
    if (committed == null) {
      emit(
        SettingsState(
          phase: SettingsLoadPhase.failure,
          failureMessage:
              themeController.failureMessage ?? 'Unable to load settings.',
        ),
      );
      return;
    }
    emit(
      SettingsState(phase: SettingsLoadPhase.ready, committedMode: committed),
    );
  }

  Future<void> selectTheme(VulcanThemeMode mode) async {
    final committed = state.committedMode;
    if (state.isSaving) {
      _queuedMode = mode;
      emit(state.copyWith(pendingMode: mode));
      return;
    }
    if (committed == mode) return;
    await _save(mode);
  }

  Future<void> retry() async {
    final mode = state.pendingMode;
    if (mode != null && state.committedMode != mode) {
      await _save(mode);
      return;
    }
    await initialize();
  }

  Future<void> _save(VulcanThemeMode mode) async {
    emit(
      state.copyWith(
        phase: SettingsLoadPhase.saving,
        pendingMode: mode,
        clearFailureMessage: true,
      ),
    );
    final result = await themeController.selectTheme(mode);
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(
          SettingsState(
            phase: SettingsLoadPhase.ready,
            committedMode: themeController.committed,
          ),
        );
        final queued = _queuedMode;
        _queuedMode = null;
        if (queued != null && queued != themeController.committed) {
          await _save(queued);
        }
      case Err(:final failure):
        emit(
          SettingsState(
            phase: SettingsLoadPhase.failure,
            committedMode: themeController.committed,
            pendingMode: mode,
            failureMessage: failure.message,
          ),
        );
    }
  }
}
