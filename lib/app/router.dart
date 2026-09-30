import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/clock.dart';
import '../core/result.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/repositories/session_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/repositories/exercise_name_repository.dart';
import '../domain/repositories/workout_repository.dart';
import '../domain/services/notification_service.dart';
import '../domain/services/timezone_service.dart';
import '../domain/usecases/start_session.dart';
import '../domain/usecases/export_data.dart';
import '../ui/active_session/active_session_cubit.dart';
import '../ui/active_session/active_session_page.dart';
import '../ui/core/app_shell.dart';
import '../ui/history/history_list_cubit.dart';
import '../ui/history/history_page.dart';
import '../domain/models/exercise_name.dart';
import '../ui/history/exercise_history_cubit.dart';
import '../ui/history/exercise_history_page.dart';
import '../ui/history/session_detail_cubit.dart';
import '../ui/history/session_detail_page.dart';
import '../ui/planner/planner_cubit.dart';
import '../ui/planner/planner_page.dart';
import '../ui/settings/settings_cubit.dart';
import '../ui/settings/settings_page.dart';
import '../ui/today/today_page.dart';
import '../ui/today/today_cubit.dart';
import '../ui/workouts/workouts_page.dart';
import '../ui/workouts/workout_list_cubit.dart';
import '../ui/workouts/workout_builder_cubit.dart';
import '../ui/workouts/workout_builder_page.dart';
import '../ui/core/theme/theme_controller.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Parses a positive integer route id; rejects null, empty, nonnumeric, and ≤0.
int? parsePositiveRouteId(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final id = int.tryParse(raw);
  if (id == null || id < 1) {
    return null;
  }
  return id;
}

int? parseActiveSessionRouteId(String? raw) => parsePositiveRouteId(raw);

int? parseHistorySessionRouteId(String? raw) => parsePositiveRouteId(raw);

int? parseWorkoutBuilderRouteId(String? raw) => parsePositiveRouteId(raw);

/// Parses the percent-encoded display exercise name from a history route.
ExerciseName? parseExerciseHistoryRouteName(String? raw) {
  if (raw == null) {
    return null;
  }
  final decoded = Uri.decodeComponent(raw);
  final result = ExerciseName.forLookup(decoded);
  return switch (result) {
    Ok(:final value) => value,
    Err() => null,
  };
}

GoRouter createVulcanRouter({
  ThemeController? themeController,
  ExportData? exportData,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/today',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: BlocProvider(
                    create: (context) => TodayCubit(
                      startSession: StartSession(
                        context.read<SessionRepository>(),
                      ),
                      timezoneService: context.read<TimezoneService>(),
                      clock: const SystemClock(),
                    ),
                    child: const TodayPage(),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planner',
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    child: Builder(
                      builder: (context) {
                        final clock = const SystemClock();
                        final today = calendarDateFromClock(clock);
                        final firstDayOfWeekIndex = MaterialLocalizations.of(
                          context,
                        ).firstDayOfWeekIndex;
                        final weekStart = weekStartFor(
                          today: today,
                          firstDayOfWeekIndex: firstDayOfWeekIndex,
                        );
                        return BlocProvider(
                          create: (context) => PlannerCubit(
                            scheduleRepository: context
                                .read<ScheduleRepository>(),
                            workoutRepository: context
                                .read<WorkoutRepository>(),
                            startSession: StartSession(
                              context.read<SessionRepository>(),
                            ),
                            timezoneService: context.read<TimezoneService>(),
                            clock: clock,
                            initialWeekStart: weekStart,
                            firstDayOfWeekIndex: firstDayOfWeekIndex,
                            initialSelectedDate: today,
                          )..initialize(),
                          child: const PlannerPage(),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    child: BlocProvider(
                      create: (context) => HistoryListCubit(
                        sessionRepository: context.read<SessionRepository>(),
                        settingsRepository: context.read<SettingsRepository>(),
                      )..initialize(),
                      child: const HistoryPage(),
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'session/:sessionId',
                    builder: (context, state) {
                      final sessionId = parseHistorySessionRouteId(
                        state.pathParameters['sessionId'],
                      );
                      if (sessionId == null) {
                        return const SessionDetailInvalidRoutePage();
                      }
                      return BlocProvider(
                        create: (context) => SessionDetailCubit(
                          sessionId: sessionId,
                          sessionRepository: context.read<SessionRepository>(),
                          settingsRepository: context
                              .read<SettingsRepository>(),
                        )..initialize(),
                        child: SessionDetailPage(sessionId: sessionId),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'exercise',
                    builder: (context, state) {
                      final exerciseName = parseExerciseHistoryRouteName(
                        state.uri.queryParameters['name'],
                      );
                      if (exerciseName == null) {
                        return const ExerciseHistoryInvalidRoutePage();
                      }
                      return BlocProvider(
                        create: (context) => ExerciseHistoryCubit(
                          exerciseName: exerciseName,
                          sessionRepository: context.read<SessionRepository>(),
                          settingsRepository: context
                              .read<SettingsRepository>(),
                        )..initialize(),
                        child: const ExerciseHistoryPage(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workouts',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: BlocProvider(
                    create: (context) => WorkoutListCubit(
                      workoutRepository: context.read<WorkoutRepository>(),
                    )..initialize(),
                    child: const WorkoutsPage(),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => BlocProvider(
                      create: (context) => WorkoutBuilderCubit(
                        workoutRepository: context.read<WorkoutRepository>(),
                        exerciseNameRepository: context
                            .read<ExerciseNameRepository>(),
                        settingsRepository: context.read<SettingsRepository>(),
                      )..initialize(),
                      child: const WorkoutBuilderPage(),
                    ),
                  ),
                  GoRoute(
                    path: ':workoutId/edit',
                    builder: (context, state) {
                      final workoutId = parseWorkoutBuilderRouteId(
                        state.pathParameters['workoutId'],
                      );
                      if (workoutId == null) {
                        return const WorkoutBuilderInvalidRoutePage();
                      }
                      return BlocProvider(
                        create: (context) => WorkoutBuilderCubit(
                          workoutRepository: context.read<WorkoutRepository>(),
                          exerciseNameRepository: context
                              .read<ExerciseNameRepository>(),
                          settingsRepository: context
                              .read<SettingsRepository>(),
                          workoutId: workoutId,
                        )..initialize(),
                        child: const WorkoutBuilderPage(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/session/:sessionId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final sessionId = parseActiveSessionRouteId(
            state.pathParameters['sessionId'],
          );
          if (sessionId == null) {
            return const ActiveSessionInvalidRoutePage();
          }
          return BlocProvider(
            create: (context) => ActiveSessionCubit(
              sessionId: sessionId,
              sessionRepository: context.read<SessionRepository>(),
              settingsRepository: context.read<SettingsRepository>(),
              notificationService: context.read<NotificationService>(),
              clock: const SystemClock(),
            )..initialize(),
            child: ActiveSessionPage(sessionId: sessionId),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final controller = themeController;
          if (controller == null) {
            return const _SettingsUnavailablePage();
          }
          return BlocProvider(
            create: (_) => SettingsCubit(
              themeController: controller,
              exportData: exportData,
            )..initialize(),
            child: const SettingsPage(),
          );
        },
      ),
    ],
  );
}

class _SettingsUnavailablePage extends StatelessWidget {
  const _SettingsUnavailablePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: const Center(child: Text('Settings are unavailable.')),
    );
  }
}
