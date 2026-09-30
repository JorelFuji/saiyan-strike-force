import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vulcan_fitness/core/clock.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/schedule_status.dart';
import 'package:vulcan_fitness/domain/models/scheduled_workout.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';
import 'package:vulcan_fitness/domain/repositories/schedule_repository.dart';
import 'package:vulcan_fitness/domain/repositories/session_repository.dart';
import 'package:vulcan_fitness/domain/repositories/workout_repository.dart';
import 'package:vulcan_fitness/domain/services/timezone_service.dart';
import 'package:vulcan_fitness/domain/usecases/start_session.dart';
import 'package:vulcan_fitness/ui/planner/planner_cubit.dart';
import 'package:vulcan_fitness/ui/planner/planner_page.dart';

import '../../support/fake_schedule_repository.dart';
import '../../support/fake_session_repository.dart';
import '../../support/fake_timezone_service.dart';
import '../../support/fake_workout_repository.dart';
import '../../support/vulcan_test_app.dart';

final class FixedClock implements Clock {
  FixedClock(this.instant);

  final DateTime instant;

  @override
  DateTime now() => instant;
}

void main() {
  // Noon local avoids day-boundary flakiness across host timezones.
  final clock = FixedClock(DateTime(2026, 9, 24, 12));
  final today = calendarDateFromClock(clock);
  final weekStart = weekStartFor(today: today, firstDayOfWeekIndex: 1);

  ScheduledWorkout plannedEntry() {
    return (ScheduledWorkout.create(
      id: 1,
      workoutId: 10,
      date: today,
      status: ScheduleStatus.planned,
      workoutName: 'Push',
      workoutArchived: false,
    ) as Ok<ScheduledWorkout>).value;
  }

  WorkoutTemplate template() {
    return (WorkoutTemplate.create(
      id: 10,
      name: 'Push',
      createdAt: DateTime.utc(2026, 9, 1),
    ) as Ok<WorkoutTemplate>).value;
  }

  Future<void> pumpPlanner(
    WidgetTester tester, {
    FakeScheduleRepository? schedules,
    FakeWorkoutRepository? workouts,
    FakeSessionRepository? sessions,
    double textScale = 1,
  }) async {
    final scheduleRepo =
        schedules ?? FakeScheduleRepository(seed: [plannedEntry()]);
    final workoutRepo = workouts ?? FakeWorkoutRepository(seed: [template()]);
    final sessionRepo = sessions ?? FakeSessionRepository();
    final router = GoRouter(
      initialLocation: '/planner',
      routes: [
        GoRoute(
          path: '/planner',
          builder: (context, state) => BlocProvider(
            create: (_) => PlannerCubit(
              scheduleRepository: scheduleRepo,
              workoutRepository: workoutRepo,
              startSession: StartSession(sessionRepo),
              timezoneService: FakeTimezoneService(),
              clock: clock,
              initialWeekStart: weekStart,
              firstDayOfWeekIndex: 1,
              initialSelectedDate: today,
            )..initialize(),
            child: const PlannerPage(),
          ),
        ),
        GoRoute(
          path: '/session/:sessionId',
          builder: (context, state) => Scaffold(
            body: Text('Session ${state.pathParameters['sessionId']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ScheduleRepository>.value(value: scheduleRepo),
          RepositoryProvider<WorkoutRepository>.value(value: workoutRepo),
          RepositoryProvider<SessionRepository>.value(value: sessionRepo),
          RepositoryProvider<TimezoneService>.value(
            value: FakeTimezoneService(),
          ),
        ],
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: vulcanMaterialAppRouter(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows week strip, entry actions, and add affordance', (
    tester,
  ) async {
    await pumpPlanner(tester);

    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('Push'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Move'), findsOneWidget);
    expect(find.byTooltip('Add workout'), findsOneWidget);
    expect(find.byTooltip('Copy week forward'), findsOneWidget);
    expect(find.byTooltip('Previous week'), findsOneWidget);
  });

  testWidgets('add sheet lists active templates', (tester) async {
    await pumpPlanner(
      tester,
      workouts: FakeWorkoutRepository(
        seed: [
          template(),
          (WorkoutTemplate.create(
            id: 11,
            name: 'Archived',
            createdAt: DateTime.utc(2026, 9, 1),
            archivedAt: DateTime.utc(2026, 9, 29),
          ) as Ok<WorkoutTemplate>).value,
        ],
      ),
    );

    await tester.tap(find.byTooltip('Add workout'));
    await tester.pumpAndSettle();
    expect(find.text('Add workout'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Push'), findsOneWidget);
    expect(find.text('Archived'), findsNothing);
  });

  testWidgets('start navigates to session route', (tester) async {
    final sessions = FakeSessionRepository()..startResult = const Ok(99);
    await pumpPlanner(tester, sessions: sessions);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Session 99'), findsOneWidget);
    expect(sessions.startCalls, 1);
  });

  testWidgets('large text scale keeps planner usable', (tester) async {
    await pumpPlanner(tester, textScale: 1.3);
    expect(find.text('Planner'), findsOneWidget);
    expect(find.byTooltip('Add workout'), findsOneWidget);
    expect(find.byTooltip('Copy week forward'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('month toggle keeps one drill-in and hides copy-week action', (
    tester,
  ) async {
    await pumpPlanner(tester);

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Previous month'), findsOneWidget);
    expect(find.byTooltip('Copy week forward'), findsNothing);
    expect(find.byType(CustomScrollView), findsOneWidget);

    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();
    expect(find.text('No workouts planned'), findsOneWidget);
    expect(find.byTooltip('Add workout'), findsOneWidget);

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Copy week forward'), findsOneWidget);
  });

  testWidgets('month retry preserves the active range', (tester) async {
    final schedules = FakeScheduleRepository(seed: [plannedEntry()]);
    await pumpPlanner(tester, schedules: schedules);
    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    final monthStart = schedules.lastStartInclusive;
    schedules.emitError(const StorageFailure('month unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('month unavailable'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(schedules.lastStartInclusive, monthStart);
    expect(find.byTooltip('Previous month'), findsOneWidget);
  });

  testWidgets('copy week requires confirmation and shows success feedback', (
    tester,
  ) async {
    final schedules = FakeScheduleRepository(seed: [plannedEntry()]);
    await pumpPlanner(tester, schedules: schedules);

    await tester.tap(find.byTooltip('Copy week forward'));
    await tester.pumpAndSettle();
    expect(find.text('Copy week forward?'), findsOneWidget);
    expect(
      find.textContaining('existing next-week workouts are not replaced'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(schedules.copyWeekForwardCalls, 0);

    await tester.tap(find.byTooltip('Copy week forward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy week'));
    await tester.pumpAndSettle();
    expect(schedules.copyWeekForwardCalls, 1);
    expect(find.text('Copied 1 workout to next week.'), findsOneWidget);
  });

  testWidgets('copy week shows zero and failure feedback', (tester) async {
    final schedules = FakeScheduleRepository()
      ..copyWeekForwardResult = const Ok(0);
    await pumpPlanner(tester, schedules: schedules);
    await tester.tap(find.byTooltip('Copy week forward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy week'));
    await tester.pumpAndSettle();
    expect(find.text('No planned workouts to copy.'), findsOneWidget);

    schedules.copyWeekForwardResult = const Err(
      StorageFailure('copy unavailable'),
    );
    await tester.tap(find.byTooltip('Copy week forward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy week'));
    await tester.pumpAndSettle();
    expect(find.text('copy unavailable'), findsOneWidget);
  });
}
