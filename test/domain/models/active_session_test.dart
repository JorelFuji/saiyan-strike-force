import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/session_status.dart';

void main() {
  ActualPrescription actual() => (ActualPrescription.create(
    reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
    load: (LoadPrescription.absolute(1000) as Ok<LoadPrescription>).value,
  ) as Ok<ActualPrescription>).value;

  SessionSetSnapshot setSnapshot({
    int id = 1,
    int sessionExerciseId = 1,
    bool completed = false,
  }) => (SessionSetSnapshot.create(
    id: id,
    sessionExerciseId: sessionExerciseId,
    setIndex: 0,
    plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
    plannedLoad: LoadPrescription.bodyweight,
    completed: completed,
    completedAt: completed ? DateTime.utc(2026, 9, 26, 16) : null,
  ) as Ok<SessionSetSnapshot>).value;

  SessionExerciseSnapshot exerciseSnapshot({int sessionId = 1}) =>
      (SessionExerciseSnapshot.create(
        id: 1,
        sessionId: sessionId,
        nameSnapshot: 'Bench Press',
        orderIndex: 0,
        plannedSets: 1,
        plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        plannedLoad: LoadPrescription.bodyweight,
        plannedRestSeconds: 90,
        sets: [setSnapshot()],
      ) as Ok<SessionExerciseSnapshot>).value;

  test('builds a valid active session with UTC timestamps', () {
    final localStart = DateTime(2026, 9, 26, 9);
    final result = ActiveSession.create(
      id: 1,
      workoutId: 2,
      workoutNameSnapshot: 'Push',
      startedAt: localStart,
      timezone: 'America/Denver',
      status: SessionStatus.running,
      exercises: [exerciseSnapshot()],
    );
    final session = (result as Ok<ActiveSession>).value;
    expect(session.startedAt, localStart.toUtc());
    expect(session.timezone, 'America/Denver');
    expect(
      session.exercises.single.sets.single.plannedLoad,
      isA<BodyweightLoad>(),
    );
  });

  test('rejects invalid identifiers, names, and child ownership', () {
    expect(
      ActiveSession.create(
        id: 0,
        workoutNameSnapshot: 'Push',
        startedAt: DateTime.utc(2026, 9, 26),
        timezone: 'UTC',
        status: SessionStatus.running,
      ),
      isA<Err<ActiveSession>>(),
    );
    expect(
      ActiveSession.create(
        id: 1,
        workoutId: 0,
        workoutNameSnapshot: 'Push',
        startedAt: DateTime.utc(2026, 9, 26),
        timezone: 'UTC',
        status: SessionStatus.running,
      ),
      isA<Err<ActiveSession>>(),
    );
    expect(
      ActiveSession.create(
        id: 1,
        workoutNameSnapshot: '  ',
        startedAt: DateTime.utc(2026, 9, 26),
        timezone: 'UTC',
        status: SessionStatus.running,
      ),
      isA<Err<ActiveSession>>(),
    );
    expect(
      ActiveSession.create(
        id: 1,
        workoutNameSnapshot: 'Push',
        startedAt: DateTime.utc(2026, 9, 26),
        timezone: 'UTC',
        status: SessionStatus.running,
        exercises: [exerciseSnapshot(sessionId: 2)],
      ),
      isA<Err<ActiveSession>>(),
    );
    expect(
      ActiveSession.create(
        id: 1,
        workoutNameSnapshot: 'Push',
        startedAt: DateTime.utc(2026, 9, 26),
        timezone: 'UTC',
        status: SessionStatus.finished,
      ),
      isA<Err<ActiveSession>>(),
    );
    expect(
      ActiveSession.create(
        id: 1,
        workoutNameSnapshot: 'Push',
        startedAt: DateTime.utc(2026, 9, 26),
        timezone: 'UTC',
        status: SessionStatus.running,
        endedAt: DateTime.utc(2026, 9, 26, 17),
      ),
      isA<Err<ActiveSession>>(),
    );
  });

  test('validates set completion pairing and optional RPE', () {
    expect(
      SessionSetSnapshot.create(
        id: 1,
        sessionExerciseId: 1,
        setIndex: 0,
        plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        plannedLoad: LoadPrescription.bodyweight,
        completed: true,
      ),
      isA<Err<SessionSetSnapshot>>(),
    );
    expect(
      SessionSetSnapshot.create(
        id: 1,
        sessionExerciseId: 1,
        setIndex: 0,
        plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        plannedLoad: LoadPrescription.bodyweight,
        completed: false,
        completedAt: DateTime.utc(2026, 9, 26),
      ),
      isA<Err<SessionSetSnapshot>>(),
    );
    expect(
      SessionSetSnapshot.create(
        id: 1,
        sessionExerciseId: 1,
        setIndex: 0,
        plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        plannedLoad: LoadPrescription.bodyweight,
        completed: false,
        rpe: 11,
      ),
      isA<Err<SessionSetSnapshot>>(),
    );
  });

  test('computes absolute rest target from fixed start and duration', () {
    final start = DateTime.utc(2026, 9, 26, 16);
    final rest = (AbsoluteRestState.create(
      startedAt: start,
      durationSeconds: 90,
    ) as Ok<AbsoluteRestState>).value;
    expect(rest.startedAt, start);
    expect(rest.targetAt, start.add(const Duration(seconds: 90)));
    expect(
      AbsoluteRestState.create(startedAt: start, durationSeconds: -1),
      isA<Err<AbsoluteRestState>>(),
    );
  });

  test('normalizes command timestamps to UTC for stable retry input', () {
    final localCompleted = DateTime(2026, 9, 26, 10, 30);
    final command = (CompleteSetCommand.create(
      sessionId: 1,
      setId: 2,
      actual: actual(),
      completedAt: localCompleted,
    ) as Ok<CompleteSetCommand>).value;
    expect(command.completedAt, localCompleted.toUtc());

    final finish = (FinishSessionCommand.create(
      sessionId: 1,
      currentStatus: SessionStatus.running,
      endedAt: localCompleted,
    ) as Ok<FinishSessionCommand>).value;
    expect(finish.endedAt, localCompleted.toUtc());
  });

  test('rejects invalid command identifiers and RPE', () {
    expect(
      SaveSetActualValuesCommand.create(
        sessionId: 0,
        setId: 1,
        actual: actual(),
      ),
      isA<Err<SaveSetActualValuesCommand>>(),
    );
    expect(
      CompleteSetCommand.create(
        sessionId: 1,
        setId: 1,
        actual: actual(),
        completedAt: DateTime.utc(2026, 9, 26),
        rpe: double.nan,
      ),
      isA<Err<CompleteSetCommand>>(),
    );
  });

  test('validates session-local exercise and set commands', () {
    final reps = (RepPrescription.range(6, 10) as Ok<RepPrescription>).value;
    final load =
        (LoadPrescription.absolute(45000000) as Ok<LoadPrescription>).value;
    final command = AddSessionExerciseCommand.create(
      sessionId: 1,
      name: '  Incline Press  ',
      initialSetCount: 3,
      reps: reps,
      load: load,
      restSeconds: 90,
    );
    expect(command, isA<Ok<AddSessionExerciseCommand>>());
    expect(
      (command as Ok<AddSessionExerciseCommand>).value.name.normalized,
      'incline press',
    );
    expect(
      AddSessionExerciseCommand.create(
        sessionId: 0,
        name: ' ',
        initialSetCount: 0,
        reps: reps,
        load: load,
        restSeconds: -1,
      ),
      isA<Err<AddSessionExerciseCommand>>(),
    );
    expect(
      AddSessionSetCommand.create(sessionId: 1, exerciseId: 2),
      isA<Ok<AddSessionSetCommand>>(),
    );
    expect(
      AddSessionSetCommand.create(sessionId: 0, exerciseId: 2),
      isA<Err<AddSessionSetCommand>>(),
    );
  });

  test('accepts rest state on completion and dedicated rest commands', () {
    final rest = (AbsoluteRestState.create(
      startedAt: DateTime.utc(2026, 9, 26, 16),
      durationSeconds: 60,
    ) as Ok<AbsoluteRestState>).value;
    expect(
      CompleteSetCommand.create(
        sessionId: 1,
        setId: 1,
        actual: actual(),
        completedAt: DateTime.utc(2026, 9, 26, 16),
        rest: rest,
      ),
      isA<Ok<CompleteSetCommand>>(),
    );
    expect(
      UpdateSessionRestCommand.create(sessionId: 1, rest: rest),
      isA<Ok<UpdateSessionRestCommand>>(),
    );
    expect(
      ClearSessionRestCommand.create(sessionId: 1),
      isA<Ok<ClearSessionRestCommand>>(),
    );
  });
}
