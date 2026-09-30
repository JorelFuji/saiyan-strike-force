import 'dart:async';

import '../data/database/app_database.dart';
import '../data/repositories/drift_settings_repository.dart';
import '../data/repositories/drift_workout_repository.dart';
import '../data/repositories/drift_exercise_name_repository.dart';
import '../data/repositories/drift_schedule_repository.dart';
import '../data/repositories/drift_session_repository.dart';
import '../data/repositories/drift_export_snapshot_repository.dart';
import '../data/services/share_plus_export_share_service.dart';
import '../data/services/flutter_local_notification_service.dart';
import '../data/services/flutter_timezone_service.dart';
import '../data/services/mass_unit_default.dart';
import '../domain/repositories/exercise_name_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../ui/core/theme/theme_controller.dart';
import '../domain/repositories/session_repository.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/services/notification_service.dart';
import '../domain/services/timezone_service.dart';
import '../domain/usecases/finish_session.dart';
import '../domain/usecases/resume_session.dart';
import '../domain/usecases/start_session.dart';
import '../domain/repositories/workout_repository.dart';
import '../domain/repositories/export_snapshot_repository.dart';
import '../domain/services/export_share_service.dart';
import '../domain/usecases/export_data.dart';
import '../core/clock.dart';

/// Owns process-long resources created after encrypted startup succeeds.
final class AppDependencies {
  AppDependencies({
    required this.database,
    WorkoutRepository? workoutRepository,
    SessionRepository? sessionRepository,
    ScheduleRepository? scheduleRepository,
    ExerciseNameRepository? exerciseNameRepository,
    SettingsRepository? settingsRepository,
    NotificationService? notificationService,
    TimezoneService? timezoneService,
    String? localeCountryCode,
    ExportSnapshotRepository? exportSnapshotRepository,
    ExportShareService? exportShareService,
    String? appVersion,
  }) {
    this.workoutRepository =
        workoutRepository ??
        DriftWorkoutRepository(database, const SystemClock());
    this.sessionRepository =
        sessionRepository ?? DriftSessionRepository(database);
    this.scheduleRepository =
        scheduleRepository ?? DriftScheduleRepository(database);
    this.exerciseNameRepository =
        exerciseNameRepository ?? DriftExerciseNameRepository(database);
    this.settingsRepository =
        settingsRepository ??
        DriftSettingsRepository(
          database,
          firstUseDefault: massUnitForCountryCode(localeCountryCode),
        );
    this.notificationService =
        notificationService ?? FlutterLocalNotificationService();
    this.timezoneService = timezoneService ?? FlutterTimezoneService();
    this.exportSnapshotRepository =
        exportSnapshotRepository ?? DriftExportSnapshotRepository(database);
    this.exportShareService =
        exportShareService ??
        SharePlusExportShareService(
          directoryProvider: const PathProviderExportTempDirectoryProvider(),
          sharer: const SharePlusExportPlatformSharer(),
        );
    final configuredVersion =
        appVersion ?? const String.fromEnvironment('VULCAN_APP_VERSION');
    exportData = ExportData(
      repository: this.exportSnapshotRepository,
      shareService: this.exportShareService,
      clock: const SystemClock(),
      appVersion: configuredVersion.trim().isEmpty
          ? '1.0.0+1'
          : configuredVersion.trim(),
    );
    themeController = ThemeController(
      settingsRepository: this.settingsRepository,
    );
    startSession = StartSession(this.sessionRepository);
    resumeSession = ResumeSession(this.sessionRepository);
    finishSession = FinishSession(this.sessionRepository);
  }

  final AppDatabase database;
  late final WorkoutRepository workoutRepository;
  late final SessionRepository sessionRepository;
  late final ScheduleRepository scheduleRepository;
  late final ExerciseNameRepository exerciseNameRepository;
  late final SettingsRepository settingsRepository;
  late final NotificationService notificationService;
  late final TimezoneService timezoneService;
  late final ExportSnapshotRepository exportSnapshotRepository;
  late final ExportShareService exportShareService;
  late final ExportData exportData;
  late final StartSession startSession;
  late final ResumeSession resumeSession;
  late final FinishSession finishSession;
  late final ThemeController themeController;

  final StreamController<int> _notificationTapController =
      StreamController<int>.broadcast();

  Stream<int> get notificationTapSessionIds =>
      _notificationTapController.stream;

  void publishNotificationTap(int sessionId) {
    if (!_notificationTapController.isClosed) {
      _notificationTapController.add(sessionId);
    }
  }

  Future<void> close() async {
    themeController.dispose();
    await _notificationTapController.close();
    await database.close();
  }
}
