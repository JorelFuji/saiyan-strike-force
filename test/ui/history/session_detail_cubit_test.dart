import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/session_status.dart';
import 'package:vulcan_fitness/ui/history/session_detail_cubit.dart';
import 'package:vulcan_fitness/ui/history/session_detail_state.dart';

import '../../support/fake_session_repository.dart';
import '../../support/fake_settings_repository.dart';

void main() {
  ActiveSession session({
    int id = 1,
    SessionStatus status = SessionStatus.finished,
    DateTime? endedAt,
  }) {
    final set = (SessionSetSnapshot.create(
      id: 1,
      sessionExerciseId: 1,
      setIndex: 0,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad:
          (LoadPrescription.absolute(1000) as Ok<LoadPrescription>).value,
      actual: (ActualPrescription.create(
        reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        load: (LoadPrescription.absolute(1000) as Ok<LoadPrescription>).value,
      ) as Ok<ActualPrescription>).value,
      completed: status == SessionStatus.finished,
      completedAt: status == SessionStatus.finished
          ? DateTime.utc(2026, 9, 1, 15, 30)
          : null,
    ) as Ok<SessionSetSnapshot>).value;
    final exercise = (SessionExerciseSnapshot.create(
      id: 1,
      sessionId: id,
      nameSnapshot: 'Bench',
      orderIndex: 0,
      plannedSets: 1,
      plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad:
          (LoadPrescription.absolute(1000) as Ok<LoadPrescription>).value,
      plannedRestSeconds: 90,
      sets: [set],
    ) as Ok<SessionExerciseSnapshot>).value;
    return (ActiveSession.create(
      id: id,
      workoutNameSnapshot: 'Push',
      startedAt: DateTime.utc(2026, 9, 1, 15),
      endedAt:
          endedAt ??
          (status == SessionStatus.finished || status == SessionStatus.abandoned
              ? DateTime.utc(2026, 9, 1, 16)
              : null),
      timezone: 'America/Denver',
      status: status,
      exercises: [exercise],
    ) as Ok<ActiveSession>).value;
  }

  SessionDetailCubit buildCubit({
    required FakeSessionRepository sessions,
    FakeSettingsRepository? settings,
    int sessionId = 1,
  }) {
    return SessionDetailCubit(
      sessionId: sessionId,
      sessionRepository: sessions,
      settingsRepository: settings ?? FakeSettingsRepository(),
    );
  }

  test('loads finished session and mass unit', () async {
    final sessions = FakeSessionRepository()..getByIdResult = Ok(session());
    final settings = FakeSettingsRepository(unitResult: const Ok(MassUnit.lb));
    final cubit = buildCubit(sessions: sessions, settings: settings);

    await cubit.initialize();
    expect(cubit.state.loadPhase, SessionDetailLoadPhase.ready);
    expect(cubit.state.session?.workoutNameSnapshot, 'Push');
    expect(cubit.state.massUnit, MassUnit.lb);
    expect(sessions.getByIdCalls, 1);
  });

  test('rejects running, paused, abandoned, and missing sessions', () async {
    for (final status in [
      SessionStatus.running,
      SessionStatus.paused,
      SessionStatus.abandoned,
    ]) {
      final sessions = FakeSessionRepository()
        ..getByIdResult = Ok(session(status: status));
      final cubit = buildCubit(sessions: sessions);
      await cubit.initialize();
      expect(cubit.state.loadPhase, SessionDetailLoadPhase.notFound);
      expect(cubit.state.session, isNull);
    }

    final missing = FakeSessionRepository()
      ..getByIdResult = const Err(NotFoundFailure('Session was not found.'));
    final cubit = buildCubit(sessions: missing);
    await cubit.initialize();
    expect(cubit.state.loadPhase, SessionDetailLoadPhase.notFound);
  });

  test('surfaces corrupt mapping as failure and retry reloads', () async {
    final sessions = FakeSessionRepository()
      ..getByIdResult = const Err(ValidationFailure('corrupt'));
    final cubit = buildCubit(sessions: sessions);
    await cubit.initialize();
    expect(cubit.state.loadPhase, SessionDetailLoadPhase.failure);
    expect(cubit.state.failureMessage, 'corrupt');

    sessions.getByIdResult = Ok(session());
    await cubit.retry();
    expect(cubit.state.loadPhase, SessionDetailLoadPhase.ready);
  });
}
