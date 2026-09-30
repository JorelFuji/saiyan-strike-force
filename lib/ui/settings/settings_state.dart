import '../../domain/models/theme_mode.dart';
import '../../domain/models/export_document.dart';

enum SettingsLoadPhase { loading, ready, saving, failure }

final class SettingsState {
  const SettingsState({
    required this.phase,
    this.committedMode,
    this.pendingMode,
    this.failureMessage,
    this.isExporting = false,
    this.exportOutcome,
    this.exportFailureMessage,
  });

  const SettingsState.loading() : this(phase: SettingsLoadPhase.loading);

  final SettingsLoadPhase phase;
  final VulcanThemeMode? committedMode;
  final VulcanThemeMode? pendingMode;
  final String? failureMessage;
  final bool isExporting;
  final ExportShareOutcome? exportOutcome;
  final String? exportFailureMessage;

  bool get isSaving => phase == SettingsLoadPhase.saving;

  SettingsState copyWith({
    SettingsLoadPhase? phase,
    VulcanThemeMode? committedMode,
    VulcanThemeMode? pendingMode,
    bool clearPendingMode = false,
    String? failureMessage,
    bool clearFailureMessage = false,
    bool? isExporting,
    ExportShareOutcome? exportOutcome,
    bool clearExportOutcome = false,
    String? exportFailureMessage,
    bool clearExportFailureMessage = false,
  }) {
    return SettingsState(
      phase: phase ?? this.phase,
      committedMode: committedMode ?? this.committedMode,
      pendingMode: clearPendingMode ? null : pendingMode ?? this.pendingMode,
      failureMessage: clearFailureMessage
          ? null
          : failureMessage ?? this.failureMessage,
      isExporting: isExporting ?? this.isExporting,
      exportOutcome: clearExportOutcome
          ? null
          : exportOutcome ?? this.exportOutcome,
      exportFailureMessage: clearExportFailureMessage
          ? null
          : exportFailureMessage ?? this.exportFailureMessage,
    );
  }
}
