import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/clock.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/session_status.dart';
import 'package:vulcan_fitness/ui/active_session/active_session_cubit.dart';
import 'package:vulcan_fitness/ui/active_session/active_session_state.dart';

import '../../support/fake_notification_service.dart';
import '../../support/fake_session_repository.dart';
import '../../support/fake_settings_repository.dart';

final class FixedClock implements Clock {
  FixedClock(this.instant);

  DateTime instant;

  @override
  DateTime now() => instant;
}

void main() {
  ActiveSession buildSession({
    int setId = 10,
    SessionStatus status = SessionStatus.running,
    ActualPrescription? actual,
    bool completed = false,
  }) {
    final set = (SessionSetSnapshot.create(
      id: setId,
      sessionExerciseId: 1,
      setIndex: 0,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad: LoadPrescription.bodyweight,
      actual: actual,
      completed: completed,
      completedAt: completed ? DateTime.utc(2026, 9, 26, 12) : null,
    ) as Ok<SessionSetSnapshot>).value;

    final exercise = (SessionExerciseSnapshot.create(
      id: 1,
      sessionId: 7,
      nameSnapshot: 'Squat',
      orderIndex: 0,
      plannedSets: 1,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad: LoadPrescription.bodyweight,
      plannedRestSeconds: 90,
      sets: [set],
    ) as Ok<SessionExerciseSnapshot>).value;

    return (ActiveSession.create(
      id: 7,
      workoutNameSnapshot: 'Leg Day',
      startedAt: DateTime.utc(2026, 9, 26, 10),
      timezone: 'UTC',
      status: status,
      exercises: [exercise],
    ) as Ok<ActiveSession>).value;
  }

  ActiveSessionCubit buildCubit({
    FakeSessionRepository? sessions,
    FakeSettingsRepository? settings,
    FakeNotificationService? notifications,
    FixedClock? clock,
  }) {
    return ActiveSessionCubit(
      sessionId: 7,
      sessionRepository: sessions ?? FakeSessionRepository(),
      settingsRepository: settings ?? FakeSettingsRepository(),
      notificationService: notifications ?? FakeNotificationService(),
      clock: clock ?? FixedClock(DateTime.utc(2026, 9, 26, 12)),
    );
  }

  test('hydrates drafts on first watch emission', () async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()));
    final cubit = buildCubit(sessions: sessions);

    await cubit.initialize();
    await pumpEventQueue();

    expect(cubit.state.loadPhase, ActiveSessionLoadPhase.ready);
    expect(cubit.state.drafts[10]?.repsText, '5');
    await cubit.close();
  });

  test('shows initial read failure with retry path', () async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(const Err(StorageFailure('read failed')));
    final cubit = buildCubit(sessions: sessions);

    await cubit.initialize();
    await pumpEventQueue();

    expect(cubit.state.loadPhase, ActiveSessionLoadPhase.initialError);
    expect(cubit.state.initialReadMessage, 'read failed');
    await cubit.close();
  });

  test('emits saving before repository completes', () async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()))
      ..saveCompleter = Completer<Result<void>>();
    final cubit = buildCubit(sessions: sessions);
    await cubit.initialize();
    await pumpEventQueue();

    cubit.updateDraft(
      10,
      cubit.state.drafts[10]!.copyWith(repsText: '6', dirty: true),
    );
    final saveFuture = cubit.saveSetActualValues(10);
    await pumpEventQueue();
    expect(cubit.state.operations[10]?.kind, SetOperationKind.saving);

    sessions.saveCompleter!.complete(const Ok(null));
    await saveFuture;
    expect(cubit.state.operations[10]?.kind, SetOperationKind.idle);
    await cubit.close();
  });

  test('retains failed save command for retry', () async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()))
      ..saveResult = const Err(StorageFailure('write failed'));
    final cubit = buildCubit(sessions: sessions);
    await cubit.initialize();
    await pumpEventQueue();

    cubit.updateDraft(
      10,
      cubit.state.drafts[10]!.copyWith(repsText: '6', dirty: true),
    );
    await cubit.saveSetActualValues(10);

    final failed = cubit.state.operations[10];
    expect(failed?.isFailed, isTrue);
    expect(failed?.failedSave?.actual.reps, isA<FixedReps>());
    expect(cubit.state.drafts[10]?.repsText, '6');

    sessions.saveResult = const Ok(null);
    await cubit.retrySet(10);
    expect(sessions.saveCalls, 2);
    expect(
      sessions.savedCommands.last.actual.reps,
      failed!.failedSave!.actual.reps,
    );
    await cubit.close();
  });

  test('complete uses one clock instant and reuses on retry', () async {
    final clock = FixedClock(DateTime.utc(2026, 9, 26, 12, 30));
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()))
      ..completeResult = const Err(StorageFailure('complete failed'));
    final cubit = buildCubit(sessions: sessions, clock: clock);
    await cubit.initialize();
    await pumpEventQueue();

    await cubit.completeSet(10);
    final failedCommand = cubit.state.operations[10]?.failedComplete;
    expect(failedCommand?.completedAt, clock.instant);

    sessions.completeResult = const Ok(null);
    await cubit.retrySet(10);
    expect(
      sessions.completedCommands.last.completedAt,
      failedCommand?.completedAt,
    );
    await cubit.close();
  });

  test('editing after failure clears stale retry command', () async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()))
      ..completeResult = const Err(StorageFailure('complete failed'));
    final cubit = buildCubit(sessions: sessions);
    await cubit.initialize();
    await pumpEventQueue();

    await cubit.completeSet(10);
    expect(cubit.state.operations[10]?.isFailed, isTrue);

    cubit.updateDraft(
      10,
      cubit.state.drafts[10]!.copyWith(repsText: '7', dirty: true),
    );
    expect(cubit.state.operations[10]?.kind, SetOperationKind.idle);

    sessions.completeResult = const Ok(null);
    await cubit.completeSet(10);
    expect((sessions.completedCommands.last.actual.reps as FixedReps).reps, 7);
    await cubit.close();
  });

  test('stream refresh does not clobber dirty drafts', () async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()));
    final cubit = buildCubit(sessions: sessions);
    await cubit.initialize();
    await pumpEventQueue();

    cubit.updateDraft(
      10,
      cubit.state.drafts[10]!.copyWith(repsText: '9', dirty: true),
    );
    sessions.emitWatch(Ok(buildSession()));
    await pumpEventQueue();

    expect(cubit.state.drafts[10]?.repsText, '9');
    await cubit.close();
  });

  test('ignores duplicate save while pending', () async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()))
      ..saveCompleter = Completer<Result<void>>();
    final cubit = buildCubit(sessions: sessions);
    await cubit.initialize();
    await pumpEventQueue();

    cubit.updateDraft(
      10,
      cubit.state.drafts[10]!.copyWith(repsText: '6', dirty: true),
    );
    unawaited(cubit.saveSetActualValues(10));
    await pumpEventQueue();
    await cubit.saveSetActualValues(10);
    expect(sessions.saveCalls, 1);
    sessions.saveCompleter!.complete(const Ok(null));
    await pumpEventQueue();
    await cubit.close();
  });

  test('cancels watch subscription on close', () async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()));
    final cubit = buildCubit(sessions: sessions);
    await cubit.initialize();
    await pumpEventQueue();
    await cubit.close();

    sessions.emitWatch(
      Ok(
        buildSession(
          actual: (ActualPrescription.create(
            reps: (RepPrescription.fixed(99) as Ok<RepPrescription>).value,
            load: LoadPrescription.bodyweight,
          ) as Ok<ActualPrescription>).value,
        ),
      ),
    );
    await pumpEventQueue();
    expect(cubit.state.drafts[10]?.repsText, isNot('99'));
  });

  test('complete with auto-start schedules rest after commit', () async {
    final notifications = FakeNotificationService();
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()));
    final cubit = buildCubit(sessions: sessions, notifications: notifications);
    await cubit.initialize();
    await pumpEventQueue();

    await cubit.completeSet(10);

    expect(sessions.completeCalls, 1);
    expect(sessions.completedCommands.single.rest, isNotNull);
    expect(notifications.scheduleCalls, 1);
    await cubit.close();
  });

  test('schedule failure after commit does not fail set completion', () async {
    final notifications = FakeNotificationService()
      ..scheduleResult = const Err(StorageFailure('schedule failed'));
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()));
    final cubit = buildCubit(sessions: sessions, notifications: notifications);
    await cubit.initialize();
    await pumpEventQueue();

    await cubit.completeSet(10);

    expect(cubit.state.operations[10]?.kind, SetOperationKind.idle);
    expect(cubit.state.streamReadMessage, 'schedule failed');
    await cubit.close();
  });

  test(
    'permission denial keeps completion and shows degraded message',
    () async {
      final notifications = FakeNotificationService()
        ..permissionResult = const Ok(false);
      final sessions = FakeSessionRepository()
        ..watchSeedEvents.add(Ok(buildSession()));
      final cubit = buildCubit(
        sessions: sessions,
        notifications: notifications,
      );
      await cubit.initialize();
      await pumpEventQueue();

      await cubit.completeSet(10);

      expect(cubit.state.operations[10]?.kind, SetOperationKind.idle);
      expect(notifications.scheduleCalls, 0);
      expect(cubit.state.restAlertDegradedMessage, isNotNull);
      await cubit.close();
    },
  );

  test('skip rest clears repository then cancels notification', () async {
    final notifications = FakeNotificationService();
    final rest = (AbsoluteRestState.create(
      startedAt: DateTime.utc(2026, 9, 26, 12),
      durationSeconds: 90,
    ) as Ok<AbsoluteRestState>).value;
    final session = buildSession();
    final withRest = (ActiveSession.create(
      id: session.id,
      workoutNameSnapshot: session.workoutNameSnapshot,
      startedAt: session.startedAt,
      timezone: session.timezone,
      status: session.status,
      rest: rest,
      exercises: session.exercises,
    ) as Ok<ActiveSession>).value;
    final sessions = FakeSessionRepository()..watchSeedEvents.add(Ok(withRest));
    final cubit = buildCubit(sessions: sessions, notifications: notifications);
    await cubit.initialize();
    await pumpEventQueue();

    await cubit.skipRest();

    expect(sessions.clearRestCalls, 1);
    expect(notifications.cancelCalls, greaterThanOrEqualTo(1));
    await cubit.close();
  });

  test('finish stays pending until repository ok', () async {
    final sessions = FakeSessionRepository()
      ..watchSeedEvents.add(Ok(buildSession()));
    sessions.finishCompleter = Completer<Result<void>>();
    final cubit = buildCubit(sessions: sessions);
    await cubit.initialize();
    await pumpEventQueue();

    final finishFuture = cubit.finish();
    await pumpEventQueue();
    expect(cubit.state.finishPending, isTrue);
    sessions.finishCompleter!.complete(const Ok(null));
    await finishFuture;
    expect(cubit.state.finishSucceeded, isTrue);
    await cubit.close();
  });

  test(
    'addition operations retain failed commands and retry without drafts',
    () async {
      final sessions = FakeSessionRepository()
        ..watchSeedEvents.add(Ok(buildSession()))
        ..addExerciseResult = const Err(
          StorageFailure('exercise write failed'),
        );
      final cubit = buildCubit(sessions: sessions);
      await cubit.initialize();
      await pumpEventQueue();
      final command = (AddSessionExerciseCommand.create(
        sessionId: 7,
        name: 'Lunge',
        initialSetCount: 2,
        reps: (RepPrescription.fixed(8) as Ok<RepPrescription>).value,
        load: LoadPrescription.bodyweight,
        restSeconds: 60,
      ) as Ok<AddSessionExerciseCommand>).value;
      await cubit.addExercise(command);
      expect(cubit.state.addExercise.failedCommand, command);
      sessions.addExerciseResult = const Ok(99);
      await cubit.retryAddExercise();
      expect(sessions.addExerciseCalls, 2);
      expect(cubit.state.addExercise.isBusy, isFalse);
      await cubit.close();
    },
  );
}
