import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/domain/models/exercise_history.dart';
import 'package:vulcan_fitness/domain/models/exercise_name.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/ui/history/exercise_history_cubit.dart';
import 'package:vulcan_fitness/ui/history/exercise_history_state.dart';

import '../../support/fake_session_repository.dart';
import '../../support/fake_settings_repository.dart';

void main() {
  final exerciseName =
      (ExerciseName.forLookup('Bench Press') as Ok<ExerciseName>).value;
  final day = (CalendarDate.fromIso('2026-09-01') as Ok<CalendarDate>).value;

  ExerciseHistoryEntry entry({int id = 1}) {
    final set = (ExerciseHistoryCompletedSet.create(
      setIndex: 0,
      actual: (ActualPrescription.create(
        reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        load:
            (LoadPrescription.absolute(1000000) as Ok<LoadPrescription>).value,
      ) as Ok<ActualPrescription>).value,
    ) as Ok<ExerciseHistoryCompletedSet>).value;
    return (ExerciseHistoryEntry.create(
      sessionExerciseId: id,
      sessionId: 10,
      nameSnapshot: 'Bench Press',
      normalizedName: 'bench press',
      startedAt: DateTime.utc(2026, 9, 1, 15),
      sessionOn: day,
      completedSets: [set],
    ) as Ok<ExerciseHistoryEntry>).value;
  }

  ExerciseHistoryCubit buildCubit({
    FakeSessionRepository? sessions,
    FakeSettingsRepository? settings,
  }) {
    return ExerciseHistoryCubit(
      exerciseName: exerciseName,
      sessionRepository: sessions ?? FakeSessionRepository(),
      settingsRepository: settings ?? FakeSettingsRepository(),
    );
  }

  test('initialize reads unit before subscribing and loads entries', () async {
    final sessions = FakeSessionRepository()
      ..exerciseHistorySeedEvents.add(Ok([entry()]));
    final settings = FakeSettingsRepository(unitResult: const Ok(MassUnit.lb));
    final cubit = buildCubit(sessions: sessions, settings: settings);

    await cubit.initialize();
    await pumpEventQueue();

    expect(settings.readCalls, 1);
    expect(sessions.watchExerciseHistoryCalls, 1);
    expect(sessions.lastExerciseHistoryLookup?.normalized, 'bench press');
    expect(cubit.state.massUnit, MassUnit.lb);
    expect(cubit.state.loadPhase, ExerciseHistoryLoadPhase.ready);
    expect(cubit.state.entries, hasLength(1));

    await cubit.close();
    sessions.emitExerciseHistory(Ok([entry(id: 2)]));
    await pumpEventQueue();
    expect(cubit.state.entries.single.sessionExerciseId, 1);
  });

  test('settings failure prevents subscription', () async {
    final sessions = FakeSessionRepository();
    final settings = FakeSettingsRepository(
      unitResult: const Err(StorageFailure('settings failed')),
    );
    final cubit = buildCubit(sessions: sessions, settings: settings);

    await cubit.initialize();
    expect(sessions.watchExerciseHistoryCalls, 0);
    expect(cubit.state.loadPhase, ExerciseHistoryLoadPhase.failure);
    await cubit.close();
  });

  test('empty stream emission shows empty phase', () async {
    final sessions = FakeSessionRepository()
      ..exerciseHistorySeedEvents.add(const Ok([]));
    final cubit = buildCubit(sessions: sessions);

    await cubit.initialize();
    await pumpEventQueue();
    expect(cubit.state.loadPhase, ExerciseHistoryLoadPhase.empty);
    await cubit.close();
  });

  test('stream error and retry recover', () async {
    final sessions = FakeSessionRepository()
      ..exerciseHistorySeedEvents.add(
        const Err(StorageFailure('history failed')),
      );
    final cubit = buildCubit(sessions: sessions);

    await cubit.initialize();
    await pumpEventQueue();
    expect(cubit.state.loadPhase, ExerciseHistoryLoadPhase.failure);

    sessions.exerciseHistorySeedEvents.clear();
    sessions.exerciseHistorySeedEvents.add(Ok([entry()]));
    await cubit.retry();
    await pumpEventQueue();
    expect(cubit.state.loadPhase, ExerciseHistoryLoadPhase.ready);
    await cubit.close();
  });
}
