import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/clock.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/session_status.dart';
import 'package:vulcan_fitness/ui/active_session/active_session_cubit.dart';
import 'package:vulcan_fitness/ui/active_session/active_session_page.dart';

import '../../support/fake_notification_service.dart';
import '../../support/fake_session_repository.dart';
import '../../support/fake_settings_repository.dart';
import '../../support/vulcan_test_app.dart';

final class FixedClock implements Clock {
  FixedClock(this.instant);

  DateTime instant;

  @override
  DateTime now() => instant;
}

ActiveSession buildSession({
  int sessionId = 7,
  int setId = 10,
  SessionStatus status = SessionStatus.running,
  LoadPrescription plannedLoad = LoadPrescription.bodyweight,
  RepPrescription? plannedReps,
  ActualPrescription? actual,
  bool completed = false,
  List<SessionExerciseSnapshot>? exercises,
}) {
  final reps =
      plannedReps ?? (RepPrescription.fixed(5) as Ok<RepPrescription>).value;
  final set = (SessionSetSnapshot.create(
    id: setId,
    sessionExerciseId: 1,
    setIndex: 0,
    plannedReps: reps,
    plannedLoad: plannedLoad,
    actual: actual,
    completed: completed,
    completedAt: completed ? DateTime.utc(2026, 9, 26, 12) : null,
  ) as Ok<SessionSetSnapshot>).value;

  final exerciseList =
      exercises ??
      [
        (SessionExerciseSnapshot.create(
          id: 1,
          sessionId: sessionId,
          nameSnapshot: 'Squat',
          orderIndex: 0,
          plannedSets: 1,
          plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
          plannedLoad: plannedLoad,
          plannedRestSeconds: 90,
          sets: [set],
        ) as Ok<SessionExerciseSnapshot>).value,
      ];

  return (ActiveSession.create(
    id: sessionId,
    workoutNameSnapshot: 'Leg Day',
    startedAt: DateTime.utc(2026, 9, 26, 10),
    timezone: 'UTC',
    status: status,
    exercises: exerciseList,
  ) as Ok<ActiveSession>).value;
}

Future<ActiveSessionCubit> pumpPage(
  WidgetTester tester, {
  required FakeSessionRepository sessions,
  FakeSettingsRepository? settings,
  int sessionId = 7,
}) async {
  final cubit = ActiveSessionCubit(
    sessionId: sessionId,
    sessionRepository: sessions,
    settingsRepository: settings ?? FakeSettingsRepository(),
    notificationService: FakeNotificationService(),
    clock: FixedClock(DateTime.utc(2026, 9, 26, 12)),
  );
  await tester.pumpWidget(const SizedBox.shrink());
  await cubit.initialize();
  await tester.pumpWidget(
    vulcanMaterialApp(
      child: BlocProvider.value(
        value: cubit,
        child: ActiveSessionPage(sessionId: sessionId),
      ),
    ),
  );
  await tester.pump();
  addTearDown(() async => cubit.close());
  return cubit;
}

Future<void> settlePage(WidgetTester tester) async {
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows loading then ready session content', (tester) async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()));
    await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    expect(find.text('Leg Day'), findsOneWidget);
    expect(find.text('Squat'), findsWidgets);
    expect(find.text('Complete set 1'), findsOneWidget);
  });

  testWidgets('tap reps field and submit saves draft', (tester) async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()));
    final cubit = await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    await tester.tap(find.byType(TextField).last);
    await settlePage(tester);
    await tester.enterText(find.byType(TextField).last, '8');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settlePage(tester);

    expect(sessions.saveCalls, 1);
    expect(cubit.state.drafts[10]?.repsText, '8');
  });

  testWidgets('complete shows pending then success after repository ack', (
    tester,
  ) async {
    final session = buildSession();
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(session))
      ..completeCompleter = Completer<Result<void>>();
    final cubit = await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    await tester.tap(find.text('Complete set 1'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(currentSetIdFor(cubit.state), 10);

    sessions.completeCompleter!.complete(const Ok(null));
    await tester.pump();
    final completedSet = (SessionSetSnapshot.create(
      id: 10,
      sessionExerciseId: 1,
      setIndex: 0,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad: LoadPrescription.bodyweight,
      actual: (ActualPrescription.create(
        reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        load: LoadPrescription.bodyweight,
      ) as Ok<ActualPrescription>).value,
      completed: true,
      completedAt: DateTime.utc(2026, 9, 26, 12),
    ) as Ok<SessionSetSnapshot>).value;
    sessions.emitWatch(
      Ok(
        buildSession(
          actual: completedSet.actual,
          completed: true,
          exercises: [
            (SessionExerciseSnapshot.create(
              id: 1,
              sessionId: 7,
              nameSnapshot: 'Squat',
              orderIndex: 0,
              plannedSets: 1,
              plannedReps:
                  (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
              plannedLoad: LoadPrescription.bodyweight,
              plannedRestSeconds: 90,
              sets: [completedSet],
            ) as Ok<SessionExerciseSnapshot>).value,
          ],
        ),
      ),
    );
    await settlePage(tester);

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('Complete set 1'), findsNothing);
  });

  testWidgets('failed complete retains retry', (tester) async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()))
      ..completeResult = const Err(StorageFailure('complete failed'));
    await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    await tester.tap(find.text('Complete set 1'));
    await settlePage(tester);

    expect(find.text('complete failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    sessions.completeResult = const Ok(null);
    await tester.tap(find.text('Retry'));
    await settlePage(tester);
    expect(sessions.completeCalls, 2);
  });

  testWidgets('AMRAP planned reps require entry before complete', (
    tester,
  ) async {
    final amrapSession = buildSession(plannedReps: RepPrescription.amrap);
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(amrapSession));
    await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    await tester.tap(find.text('Complete set 1'));
    await settlePage(tester);
    expect(
      find.text('Performed reps must be a positive whole number.'),
      findsOneWidget,
    );
    expect(sessions.completeCalls, 0);
  });

  testWidgets('absolute load editor accepts decimal input', (tester) async {
    final session = buildSession(
      plannedLoad:
          (LoadPrescription.absolute(100000000) as Ok<LoadPrescription>).value,
    );
    final sessions = FakeSessionRepository()..watchSeedEvents.add(Ok(session));
    final cubit = await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    expect(find.text('Load (kg)'), findsOneWidget);
    await tester.tap(find.byType(TextField).first);
    await settlePage(tester);
    await tester.enterText(find.byType(TextField).first, '100');
    await settlePage(tester);
    expect(cubit.state.drafts[10]?.absoluteMassText, '100');
  });

  testWidgets('paused session shows continue instead of pause', (tester) async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession(status: SessionStatus.paused)));
    await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    expect(find.text('Paused'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Continue'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Pause'), findsNothing);
  });

  testWidgets('finish confirms and pops when cubit succeeds', (tester) async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()));
    final cubit = await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    await tester.tap(find.text('Finish'));
    await settlePage(tester);
    await tester.tap(find.text('Finish').last);
    await settlePage(tester);

    expect(cubit.state.finishSucceeded, isTrue);
  });

  testWidgets('back semantics label is present on app bar', (tester) async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()));
    await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    expect(find.bySemanticsLabel('Back'), findsOneWidget);
  });

  testWidgets('reflows at large text scale without overflow', (tester) async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()));
    final cubit = await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: BlocProvider.value(
          value: cubit,
          child: vulcanMaterialApp(
            child: const ActiveSessionPage(sessionId: 7),
          ),
        ),
      ),
    );
    await settlePage(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('marks current incomplete set with primary border', (
    tester,
  ) async {
    final set1 = (SessionSetSnapshot.create(
      id: 10,
      sessionExerciseId: 1,
      setIndex: 0,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad: LoadPrescription.bodyweight,
      completed: false,
    ) as Ok<SessionSetSnapshot>).value;
    final set2 = (SessionSetSnapshot.create(
      id: 11,
      sessionExerciseId: 1,
      setIndex: 1,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad: LoadPrescription.bodyweight,
      completed: false,
    ) as Ok<SessionSetSnapshot>).value;
    final exercise = (SessionExerciseSnapshot.create(
      id: 1,
      sessionId: 7,
      nameSnapshot: 'Squat',
      orderIndex: 0,
      plannedSets: 2,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad: LoadPrescription.bodyweight,
      plannedRestSeconds: 90,
      sets: [set1, set2],
    ) as Ok<SessionExerciseSnapshot>).value;
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession(exercises: [exercise])));
    final cubit = await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    expect(currentSetIdFor(cubit.state), 10);
  });

  testWidgets('current set stays first incomplete while complete is pending', (
    tester,
  ) async {
    final set1 = (SessionSetSnapshot.create(
      id: 10,
      sessionExerciseId: 1,
      setIndex: 0,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad: LoadPrescription.bodyweight,
      completed: false,
    ) as Ok<SessionSetSnapshot>).value;
    final set2 = (SessionSetSnapshot.create(
      id: 11,
      sessionExerciseId: 1,
      setIndex: 1,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad: LoadPrescription.bodyweight,
      completed: false,
    ) as Ok<SessionSetSnapshot>).value;
    final exercise = (SessionExerciseSnapshot.create(
      id: 1,
      sessionId: 7,
      nameSnapshot: 'Squat',
      orderIndex: 0,
      plannedSets: 2,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad: LoadPrescription.bodyweight,
      plannedRestSeconds: 90,
      sets: [set1, set2],
    ) as Ok<SessionExerciseSnapshot>).value;
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession(exercises: [exercise])))
      ..completeCompleter = Completer<Result<void>>();
    final cubit = await pumpPage(tester, sessions: sessions);
    await settlePage(tester);

    await tester.tap(find.text('Complete set 1'));
    await tester.pump();

    expect(currentSetIdFor(cubit.state), 10);
    sessions.completeCompleter!.complete(const Ok(null));
  });
}
