import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/app/dependencies.dart';
import 'package:vulcan_fitness/app/router.dart';
import 'package:drift/native.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/session_status.dart';
import 'package:vulcan_fitness/domain/repositories/schedule_repository.dart';
import 'package:vulcan_fitness/domain/repositories/session_repository.dart';
import 'package:vulcan_fitness/domain/repositories/settings_repository.dart';
import 'package:vulcan_fitness/domain/repositories/workout_repository.dart';
import 'package:vulcan_fitness/domain/services/notification_service.dart';
import 'package:vulcan_fitness/domain/services/timezone_service.dart';

import '../../support/fake_notification_service.dart';
import '../../support/fake_schedule_repository.dart';

import 'package:vulcan_fitness/ui/history/session_detail_cubit.dart';
import 'package:vulcan_fitness/ui/history/session_detail_page.dart';

import '../../support/fake_session_repository.dart';
import '../../support/fake_settings_repository.dart';
import '../../support/fake_timezone_service.dart';
import '../../support/vulcan_test_app.dart';

void main() {
  ActiveSession finishedSession() {
    final completed = (SessionSetSnapshot.create(
      id: 1,
      sessionExerciseId: 1,
      setIndex: 0,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad:
          (LoadPrescription.absolute(1000000) as Ok<LoadPrescription>).value,
      actual: (ActualPrescription.create(
        reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        load:
            (LoadPrescription.absolute(1000000) as Ok<LoadPrescription>).value,
      ) as Ok<ActualPrescription>).value,
      rpe: 8,
      completed: true,
      completedAt: DateTime.utc(2026, 9, 1, 15, 30),
    ) as Ok<SessionSetSnapshot>).value;
    final incomplete = (SessionSetSnapshot.create(
      id: 2,
      sessionExerciseId: 1,
      setIndex: 1,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad:
          (LoadPrescription.absolute(1000000) as Ok<LoadPrescription>).value,
      completed: false,
    ) as Ok<SessionSetSnapshot>).value;
    final exercise = (SessionExerciseSnapshot.create(
      id: 1,
      sessionId: 7,
      nameSnapshot: 'Bench Press',
      orderIndex: 0,
      plannedSets: 2,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad:
          (LoadPrescription.absolute(1000000) as Ok<LoadPrescription>).value,
      plannedRestSeconds: 90,
      sets: [completed, incomplete],
    ) as Ok<SessionExerciseSnapshot>).value;
    return (ActiveSession.create(
      id: 7,
      workoutNameSnapshot: 'Push',
      startedAt: DateTime.utc(2026, 9, 1, 15),
      endedAt: DateTime.utc(2026, 9, 1, 16, 30),
      timezone: 'America/Denver',
      status: SessionStatus.finished,
      notes: 'Felt strong',
      exercises: [exercise],
    ) as Ok<ActiveSession>).value;
  }

  Future<void> pumpDetail(
    WidgetTester tester, {
    required FakeSessionRepository sessions,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SessionRepository>.value(value: sessions),
          RepositoryProvider<SettingsRepository>.value(
            value: FakeSettingsRepository(),
          ),
        ],
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: vulcanMaterialApp(
            child: BlocProvider(
              create: (_) => SessionDetailCubit(
                sessionId: 7,
                sessionRepository: sessions,
                settingsRepository: FakeSettingsRepository(),
              )..initialize(),
              child: const SessionDetailPage(sessionId: 7),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders finished breakdown with planned vs actual', (
    tester,
  ) async {
    final sessions = FakeSessionRepository()
      ..getByIdResult = Ok(finishedSession());
    await pumpDetail(tester, sessions: sessions);

    expect(find.text('Push'), findsWidgets);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.textContaining('Felt strong'), findsOneWidget);
    expect(find.textContaining('Completed'), findsWidgets);
    expect(find.textContaining('Incomplete'), findsWidgets);
    expect(find.textContaining('RPE 8'), findsWidgets);
  });

  testWidgets('shows not-found for non-finished sessions', (tester) async {
    final running = (ActiveSession.create(
      id: 7,
      workoutNameSnapshot: 'Push',
      startedAt: DateTime.utc(2026, 9, 1, 15),
      timezone: 'UTC',
      status: SessionStatus.running,
    ) as Ok<ActiveSession>).value;
    final sessions = FakeSessionRepository()..getByIdResult = Ok(running);
    await pumpDetail(tester, sessions: sessions);
    expect(
      find.text('This session is not available in History.'),
      findsOneWidget,
    );
  });

  testWidgets('shows failure with retry', (tester) async {
    final sessions = FakeSessionRepository()
      ..getByIdResult = const Err(StorageFailure('detail failed'));
    await pumpDetail(tester, sessions: sessions);
    expect(find.text('detail failed'), findsOneWidget);

    sessions.getByIdResult = Ok(finishedSession());
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Bench Press'), findsOneWidget);
  });

  testWidgets('invalid route page is safe', (tester) async {
    await tester.pumpWidget(
      vulcanMaterialApp(child: const SessionDetailInvalidRoutePage()),
    );
    expect(find.text('This session link is invalid.'), findsOneWidget);
  });

  testWidgets('large text smoke', (tester) async {
    final sessions = FakeSessionRepository()
      ..getByIdResult = Ok(finishedSession());
    await pumpDetail(tester, sessions: sessions, textScale: 1.6);
    expect(find.text('Bench Press'), findsOneWidget);
  });

  testWidgets('exercise heading opens exercise history route', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final sessions = FakeSessionRepository()
      ..getByIdResult = Ok(finishedSession())
      ..exerciseHistorySeedEvents.add(const Ok([]));
    final dependencies = AppDependencies(
      database: database,
      sessionRepository: sessions,
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
        child: vulcanMaterialAppRouter(routerConfig: router),
      ),
    );
    router.go('/history/session/7');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bench Press'));
    await tester.pumpAndSettle();
    expect(
      find.text('No prior performance logged for this exercise.'),
      findsOneWidget,
    );
    expect(sessions.watchExerciseHistoryCalls, 1);
  });
}
