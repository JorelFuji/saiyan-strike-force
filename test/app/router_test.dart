import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/native.dart';
import 'package:vulcan_fitness/app/app.dart';
import 'package:vulcan_fitness/app/dependencies.dart';
import 'package:vulcan_fitness/app/router.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';
import 'package:vulcan_fitness/domain/repositories/exercise_name_repository.dart';
import 'package:vulcan_fitness/domain/repositories/schedule_repository.dart';
import 'package:vulcan_fitness/domain/repositories/session_repository.dart';
import 'package:vulcan_fitness/domain/repositories/settings_repository.dart';
import 'package:vulcan_fitness/domain/repositories/workout_repository.dart';
import 'package:vulcan_fitness/domain/services/notification_service.dart';
import 'package:vulcan_fitness/domain/services/timezone_service.dart';
import 'package:vulcan_fitness/ui/active_session/active_session_page.dart';
import 'package:vulcan_fitness/ui/core/app_shell.dart';
import 'package:vulcan_fitness/ui/planner/planner_page.dart';
import 'package:vulcan_fitness/ui/settings/settings_page.dart';
import 'package:vulcan_fitness/ui/today/today_page.dart';
import 'package:vulcan_fitness/ui/workouts/workout_list_cubit.dart';
import 'package:vulcan_fitness/ui/workouts/workouts_page.dart';

import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/session_status.dart';
import 'package:vulcan_fitness/domain/models/theme_mode.dart';
import 'package:vulcan_fitness/ui/core/theme/theme_controller.dart';
import 'package:vulcan_fitness/ui/core/theme/vulcan_theme.dart';

import '../support/fake_exercise_name_repository.dart';
import '../support/fake_notification_service.dart';
import '../support/fake_schedule_repository.dart';
import '../support/fake_session_repository.dart';
import '../support/fake_timezone_service.dart';

ActiveSession resumeSession(int sessionId) {
  final set = (SessionSetSnapshot.create(
    id: 1,
    sessionExerciseId: 1,
    setIndex: 0,
    plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
    plannedLoad: LoadPrescription.bodyweight,
    completed: false,
  ) as Ok<SessionSetSnapshot>).value;
  final exercise = (SessionExerciseSnapshot.create(
    id: 1,
    sessionId: sessionId,
    nameSnapshot: 'Bench',
    orderIndex: 0,
    plannedSets: 1,
    plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
    plannedLoad: LoadPrescription.bodyweight,
    plannedRestSeconds: 60,
    sets: [set],
  ) as Ok<SessionExerciseSnapshot>).value;
  return (ActiveSession.create(
    id: sessionId,
    workoutNameSnapshot: 'Push',
    startedAt: DateTime.utc(2026, 9, 26),
    timezone: 'UTC',
    status: SessionStatus.running,
    exercises: [exercise],
  ) as Ok<ActiveSession>).value;
}

void main() {
  testWidgets('opens Settings above the four-tab shell and returns with back', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final dependencies = AppDependencies(
      database: database,
      notificationService: FakeNotificationService(),
    );

    await tester.pumpWidget(VulcanApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsNothing);
    expect(find.byType(TodayPage), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
  });

  testWidgets('mounts four-branch shell at today without resume routing', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final dependencies = AppDependencies(
      database: database,
      notificationService: FakeNotificationService(),
    );

    await tester.pumpWidget(VulcanApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(TodayPage), findsOneWidget);
    expect(find.byType(PlannerPage), findsNothing);
    expect(find.byType(ActiveSessionPage), findsNothing);

    final context = tester.element(find.byType(AppShell));
    expect(context.read<WorkoutRepository>(), dependencies.workoutRepository);
    expect(context.read<SessionRepository>(), dependencies.sessionRepository);
    expect(context.read<SettingsRepository>(), dependencies.settingsRepository);
    expect(context.read<ScheduleRepository>(), dependencies.scheduleRepository);
    expect(
      context.read<ExerciseNameRepository>(),
      dependencies.exerciseNameRepository,
    );
  });

  testWidgets('uses an injected exercise-name repository', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fake = FakeExerciseNameRepository();
    final dependencies = AppDependencies(
      database: database,
      exerciseNameRepository: fake,
      notificationService: FakeNotificationService(),
    );

    await tester.pumpWidget(VulcanApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(AppShell));
    expect(context.read<ExerciseNameRepository>(), same(fake));
  });

  testWidgets('pushes active session once above shell on startup resume', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fakeSessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(resumeSession(42)));
    final dependencies = AppDependencies(
      database: database,
      sessionRepository: fakeSessions,
      notificationService: FakeNotificationService(),
    );

    await tester.pumpWidget(
      VulcanApp(dependencies: dependencies, startupResumeSessionId: 42),
    );
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(ActiveSessionPage), findsNothing);

    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(ActiveSessionPage), findsOneWidget);
    expect(fakeSessions.startCalls, 0);

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(ActiveSessionPage), findsOneWidget);
  });

  testWidgets('returns to shell after finishing active session', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fakeSessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(resumeSession(9)));
    final dependencies = AppDependencies(
      database: database,
      sessionRepository: fakeSessions,
      notificationService: FakeNotificationService(),
    );

    await tester.pumpWidget(
      VulcanApp(dependencies: dependencies, startupResumeSessionId: 9),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ActiveSessionPage), findsOneWidget);
    expect(fakeSessions.startCalls, 0);

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish').last);
    await tester.pumpAndSettle();

    expect(find.byType(ActiveSessionPage), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
    expect(fakeSessions.finishCalls, 1);
    expect(fakeSessions.startCalls, 0);
  });

  testWidgets('returns to shell after popping active session route', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final dependencies = AppDependencies(
      database: database,
      sessionRepository: FakeSessionRepository()
        ..watchSeedEvents.add(Ok(resumeSession(7))),
      notificationService: FakeNotificationService(),
    );

    await tester.pumpWidget(
      VulcanApp(dependencies: dependencies, startupResumeSessionId: 7),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ActiveSessionPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(ActiveSessionPage), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets('malformed session route renders safe error without cubit', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final dependencies = AppDependencies(
      database: database,
      notificationService: FakeNotificationService(),
    );

    final router = createVulcanRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SessionRepository>.value(
            value: dependencies.sessionRepository,
          ),
          RepositoryProvider<ExerciseNameRepository>.value(
            value: dependencies.exerciseNameRepository,
          ),
          RepositoryProvider<SettingsRepository>.value(
            value: dependencies.settingsRepository,
          ),
          RepositoryProvider<WorkoutRepository>.value(
            value: dependencies.workoutRepository,
          ),
          RepositoryProvider<NotificationService>.value(
            value: dependencies.notificationService,
          ),
          RepositoryProvider<TimezoneService>.value(
            value: FakeTimezoneService(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.go('/session/not-a-number');
    await tester.pumpAndSettle();

    expect(find.byType(ActiveSessionPage), findsNothing);
    expect(find.text('This session link is invalid.'), findsOneWidget);
  });

  testWidgets('valid session route creates one active session page', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final dependencies = AppDependencies(
      database: database,
      sessionRepository: FakeSessionRepository()
        ..watchSeedEvents.add(Ok(resumeSession(7))),
      notificationService: FakeNotificationService(),
    );
    final router = createVulcanRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SessionRepository>.value(
            value: dependencies.sessionRepository,
          ),
          RepositoryProvider<ExerciseNameRepository>.value(
            value: dependencies.exerciseNameRepository,
          ),
          RepositoryProvider<SettingsRepository>.value(
            value: dependencies.settingsRepository,
          ),
          RepositoryProvider<WorkoutRepository>.value(
            value: dependencies.workoutRepository,
          ),
          RepositoryProvider<NotificationService>.value(
            value: dependencies.notificationService,
          ),
          RepositoryProvider<TimezoneService>.value(
            value: FakeTimezoneService(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go('/session/7');
    await tester.pumpAndSettle();

    expect(find.byType(ActiveSessionPage), findsOneWidget);
  });

  testWidgets('switches shell branches through the navigation bar', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      VulcanApp(
        dependencies: AppDependencies(
          database: database,
          scheduleRepository: FakeScheduleRepository(),
          notificationService: FakeNotificationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Planner'));
    await tester.pumpAndSettle();
    expect(find.byType(PlannerPage), findsOneWidget);
    expect(find.byTooltip('Add workout'), findsOneWidget);

    await tester.tap(find.text('Workouts'));
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutsPage), findsOneWidget);
    expect(
      tester.element(find.byType(WorkoutsPage)).read<WorkoutListCubit>(),
      isA<WorkoutListCubit>(),
    );
    expect(find.text('No active workouts.'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('History'), findsWidgets);
    expect(find.text('No completed sessions yet.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('history detail nested route stays on history shell branch', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final finished = (ActiveSession.create(
      id: 3,
      workoutNameSnapshot: 'Push',
      startedAt: DateTime.utc(2026, 9, 1, 15),
      endedAt: DateTime.utc(2026, 9, 1, 16),
      timezone: 'UTC',
      status: SessionStatus.finished,
    ) as Ok<ActiveSession>).value;
    final fakeSessions = FakeSessionRepository()
      ..summarySeedEvents.add(const Ok([]))
      ..getByIdResult = Ok(finished);
    final dependencies = AppDependencies(
      database: database,
      sessionRepository: fakeSessions,
      scheduleRepository: FakeScheduleRepository(),
      notificationService: FakeNotificationService(),
    );

    final router = createVulcanRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SessionRepository>.value(
            value: dependencies.sessionRepository,
          ),
          RepositoryProvider<ExerciseNameRepository>.value(
            value: dependencies.exerciseNameRepository,
          ),
          RepositoryProvider<SettingsRepository>.value(
            value: dependencies.settingsRepository,
          ),
          RepositoryProvider<WorkoutRepository>.value(
            value: dependencies.workoutRepository,
          ),
          RepositoryProvider<ScheduleRepository>.value(
            value: dependencies.scheduleRepository,
          ),
          RepositoryProvider<NotificationService>.value(
            value: dependencies.notificationService,
          ),
          RepositoryProvider<TimezoneService>.value(
            value: FakeTimezoneService(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go('/history');
    await tester.pumpAndSettle();
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('No completed sessions yet.'), findsOneWidget);

    router.go('/history/session/3');
    await tester.pumpAndSettle();
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('Push'), findsWidgets);

    router.go('/history/session/0');
    await tester.pumpAndSettle();
    expect(find.text('This session link is invalid.'), findsOneWidget);

    router.go('/history/session/abc');
    await tester.pumpAndSettle();
    expect(find.text('This session link is invalid.'), findsOneWidget);
  });

  test('parseExerciseHistoryRouteName validates display names', () {
    expect(parseExerciseHistoryRouteName(null), isNull);
    expect(parseExerciseHistoryRouteName(''), isNull);
    expect(parseExerciseHistoryRouteName('   '), isNull);
    expect(parseExerciseHistoryRouteName('%20%20'), isNull);
    expect(parseExerciseHistoryRouteName('Bench%2FPress'), isNotNull);
    expect(
      parseExerciseHistoryRouteName('Bench%20Press')?.normalized,
      'bench press',
    );
    expect(parseExerciseHistoryRouteName('%C3%89lev%C3%A9')?.display, 'Élevé');
  });

  testWidgets('history exercise route accepts encoded names', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fakeSessions = FakeSessionRepository()
      ..exerciseHistorySeedEvents.add(const Ok([]));
    final dependencies = AppDependencies(
      database: database,
      sessionRepository: fakeSessions,
      scheduleRepository: FakeScheduleRepository(),
      notificationService: FakeNotificationService(),
    );
    final router = createVulcanRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SessionRepository>.value(
            value: dependencies.sessionRepository,
          ),
          RepositoryProvider<ExerciseNameRepository>.value(
            value: dependencies.exerciseNameRepository,
          ),
          RepositoryProvider<SettingsRepository>.value(
            value: dependencies.settingsRepository,
          ),
          RepositoryProvider<WorkoutRepository>.value(
            value: dependencies.workoutRepository,
          ),
          RepositoryProvider<ScheduleRepository>.value(
            value: dependencies.scheduleRepository,
          ),
          RepositoryProvider<NotificationService>.value(
            value: dependencies.notificationService,
          ),
          RepositoryProvider<TimezoneService>.value(
            value: FakeTimezoneService(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go('/history/exercise?name=${Uri.encodeComponent('Bench Press')}');
    await tester.pumpAndSettle();
    expect(
      find.text('No prior performance logged for this exercise.'),
      findsOneWidget,
    );

    router.go('/history/exercise');
    await tester.pumpAndSettle();
    expect(find.text('This exercise history link is invalid.'), findsOneWidget);
  });

  test('parseHistorySessionRouteId rejects invalid ids', () {
    expect(parseHistorySessionRouteId(null), isNull);
    expect(parseHistorySessionRouteId(''), isNull);
    expect(parseHistorySessionRouteId('0'), isNull);
    expect(parseHistorySessionRouteId('-1'), isNull);
    expect(parseHistorySessionRouteId('abc'), isNull);
    expect(parseHistorySessionRouteId('42'), 42);
  });

  test('router exposes shell route and active session route', () {
    final router = createVulcanRouter();
    addTearDown(router.dispose);

    expect(router.configuration.routes, hasLength(3));
    final shell = router.configuration.routes.first;
    expect(shell, isA<StatefulShellRoute>());
    expect((shell as StatefulShellRoute).branches, hasLength(4));
    expect(router.configuration.routes.last, isA<GoRoute>());
  });

  test('parseActiveSessionRouteId rejects malformed values', () {
    expect(parseActiveSessionRouteId(null), isNull);
    expect(parseActiveSessionRouteId(''), isNull);
    expect(parseActiveSessionRouteId('0'), isNull);
    expect(parseActiveSessionRouteId('-1'), isNull);
    expect(parseActiveSessionRouteId('abc'), isNull);
    expect(parseActiveSessionRouteId('42'), 42);
  });

  testWidgets('restores theme mode at root without breaking shell routing', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final dependencies = AppDependencies(
      database: database,
      notificationService: FakeNotificationService(),
    );
    addTearDown(dependencies.close);

    await tester.pumpWidget(VulcanApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(dependencies.themeController.phase, ThemeControllerPhase.ready);
    expect(dependencies.themeController.committed, VulcanThemeMode.system);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(
      app.theme?.colorScheme.primary,
      VulcanTheme.light().colorScheme.primary,
    );
    expect(
      app.darkTheme?.colorScheme.primary,
      VulcanTheme.dark().colorScheme.primary,
    );
    expect(app.themeMode, ThemeMode.system);
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(TodayPage), findsOneWidget);
  });
}
