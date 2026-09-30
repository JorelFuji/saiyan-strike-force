import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../domain/repositories/exercise_name_repository.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/repositories/session_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/repositories/workout_repository.dart';
import '../domain/services/notification_service.dart';
import '../domain/services/timezone_service.dart';
import '../domain/repositories/export_snapshot_repository.dart';
import '../domain/services/export_share_service.dart';
import '../domain/usecases/export_data.dart';
import '../ui/core/theme/vulcan_theme.dart';
import 'dependencies.dart';
import 'router.dart';
import 'startup_resume_coordinator.dart';

class VulcanApp extends StatefulWidget {
  const VulcanApp({
    required this.dependencies,
    this.startupResumeSessionId,
    super.key,
  });

  final AppDependencies dependencies;

  /// Optional resumable session id discovered at startup for resume routing.
  final int? startupResumeSessionId;

  @override
  State<VulcanApp> createState() => _VulcanAppState();
}

class _VulcanAppState extends State<VulcanApp> {
  late final GoRouter _router = createVulcanRouter(
    themeController: widget.dependencies.themeController,
    exportData: widget.dependencies.exportData,
  );

  @override
  void initState() {
    super.initState();
    unawaited(widget.dependencies.themeController.initialize());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = widget.dependencies.themeController;
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WorkoutRepository>.value(
          value: widget.dependencies.workoutRepository,
        ),
        RepositoryProvider<SessionRepository>.value(
          value: widget.dependencies.sessionRepository,
        ),
        RepositoryProvider<ScheduleRepository>.value(
          value: widget.dependencies.scheduleRepository,
        ),
        RepositoryProvider<ExerciseNameRepository>.value(
          value: widget.dependencies.exerciseNameRepository,
        ),
        RepositoryProvider<SettingsRepository>.value(
          value: widget.dependencies.settingsRepository,
        ),
        RepositoryProvider<NotificationService>.value(
          value: widget.dependencies.notificationService,
        ),
        RepositoryProvider<TimezoneService>.value(
          value: widget.dependencies.timezoneService,
        ),
        RepositoryProvider<ExportSnapshotRepository>.value(
          value: widget.dependencies.exportSnapshotRepository,
        ),
        RepositoryProvider<ExportShareService>.value(
          value: widget.dependencies.exportShareService,
        ),
        RepositoryProvider<ExportData>.value(
          value: widget.dependencies.exportData,
        ),
      ],
      child: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) {
          return MaterialApp.router(
            title: 'Vulcan Fitness',
            theme: VulcanTheme.light(),
            darkTheme: VulcanTheme.dark(),
            themeMode: themeController.themeMode,
            routerConfig: _router,
            builder: (context, child) {
              return StartupResumeCoordinator(
                router: _router,
                sessionRepository: widget.dependencies.sessionRepository,
                resumeSessionId: widget.startupResumeSessionId,
                notificationTapSessionIds:
                    widget.dependencies.notificationTapSessionIds,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

class FatalStorageApp extends StatelessWidget {
  const FatalStorageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Vulcan Fitness',
      home: Scaffold(body: Center(child: Text('Unable to open storage.'))),
    );
  }
}
