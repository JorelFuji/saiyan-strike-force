import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/domain/models/completed_session_summary.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/ui/history/history_list_cubit.dart';
import 'package:vulcan_fitness/ui/history/history_list_state.dart';

import '../../support/fake_session_repository.dart';
import '../../support/fake_settings_repository.dart';

void main() {
  final day1 = (CalendarDate.fromIso('2026-09-01') as Ok<CalendarDate>).value;
  final day2 = (CalendarDate.fromIso('2026-09-02') as Ok<CalendarDate>).value;

  CompletedSessionSummary summary({
    int id = 1,
    String name = 'Push',
    CalendarDate? on,
    DateTime? startedAt,
  }) {
    final start = startedAt ?? DateTime.utc(2026, 9, 1, 15);
    return (CompletedSessionSummary.create(
      id: id,
      workoutNameSnapshot: name,
      startedOn: on ?? day1,
      startedAt: start,
      endedAt: start.add(const Duration(hours: 1)),
      timezone: 'America/Denver',
      completedSetCount: 2,
      totalSetCount: 3,
      absoluteVolumeMilligramReps: 1000,
    ) as Ok<CompletedSessionSummary>).value;
  }

  HistoryListCubit buildCubit({
    FakeSessionRepository? sessions,
    FakeSettingsRepository? settings,
  }) {
    return HistoryListCubit(
      sessionRepository: sessions ?? FakeSessionRepository(),
      settingsRepository: settings ?? FakeSettingsRepository(),
    );
  }

  test(
    'initialize loads mass unit and summaries; close cancels subscription',
    () async {
      final sessions = FakeSessionRepository()
        ..summarySeedEvents.add(Ok([summary()]));
      final settings = FakeSettingsRepository(
        unitResult: const Ok(MassUnit.lb),
      );
      final cubit = buildCubit(sessions: sessions, settings: settings);

      await cubit.initialize();
      await pumpEventQueue();

      expect(settings.readCalls, 1);
      expect(sessions.watchCompletedSummariesCalls, 1);
      expect(cubit.state.massUnit, MassUnit.lb);
      expect(cubit.state.loadPhase, HistoryListLoadPhase.ready);
      expect(cubit.state.filteredSummaries, hasLength(1));

      await cubit.close();
      sessions.emitSummaries(Ok([summary(id: 2, name: 'Pull')]));
      await pumpEventQueue();
      expect(cubit.state.filteredSummaries.single.workoutNameSnapshot, 'Push');
    },
  );

  test('name and date filters apply over typed summaries', () async {
    final sessions = FakeSessionRepository()
      ..summarySeedEvents.add(
        Ok([
          summary(id: 1, name: 'Push Day', on: day1),
          summary(
            id: 2,
            name: 'Pull Day',
            on: day2,
            startedAt: DateTime.utc(2026, 9, 2, 15),
          ),
        ]),
      );
    final cubit = buildCubit(sessions: sessions);
    await cubit.initialize();
    await pumpEventQueue();

    cubit.setNameQuery('pull');
    expect(cubit.state.filteredSummaries.map((s) => s.id), [2]);

    cubit.setNameQuery('');
    cubit.setDateRange(start: day2, end: day2);
    expect(cubit.state.filteredSummaries.map((s) => s.id), [2]);

    cubit.clearDateRange();
    expect(cubit.state.filteredSummaries, hasLength(2));
    await cubit.close();
  });

  test(
    'empty history and empty filters are distinct from stream errors',
    () async {
      final sessions = FakeSessionRepository()
        ..summarySeedEvents.add(const Ok([]));
      final cubit = buildCubit(sessions: sessions);
      await cubit.initialize();
      await pumpEventQueue();
      expect(cubit.state.loadPhase, HistoryListLoadPhase.empty);
      expect(cubit.state.allSummaries, isEmpty);

      sessions.emitSummaries(Ok([summary(name: 'Push')]));
      await pumpEventQueue();
      cubit.setNameQuery('zzz');
      expect(cubit.state.loadPhase, HistoryListLoadPhase.empty);
      expect(cubit.state.allSummaries, hasLength(1));

      sessions.emitSummaries(const Err(StorageFailure('boom')));
      await pumpEventQueue();
      expect(cubit.state.loadPhase, HistoryListLoadPhase.failure);
      expect(cubit.state.failureMessage, 'boom');
      await cubit.close();
    },
  );

  test('retry reloads after failure', () async {
    final sessions = FakeSessionRepository()
      ..summarySeedEvents.add(const Err(StorageFailure('first')));
    final cubit = buildCubit(sessions: sessions);
    await cubit.initialize();
    await pumpEventQueue();
    expect(cubit.state.loadPhase, HistoryListLoadPhase.failure);

    sessions.summarySeedEvents
      ..clear()
      ..add(Ok([summary()]));
    await cubit.retry();
    await pumpEventQueue();
    expect(cubit.state.loadPhase, HistoryListLoadPhase.ready);
    await cubit.close();
  });

  test('settings failure surfaces without watching summaries', () async {
    final sessions = FakeSessionRepository();
    final settings = FakeSettingsRepository(
      unitResult: const Err(StorageFailure('unit failed')),
    );
    final cubit = buildCubit(sessions: sessions, settings: settings);
    await cubit.initialize();
    await pumpEventQueue();
    expect(cubit.state.loadPhase, HistoryListLoadPhase.failure);
    expect(sessions.watchCompletedSummariesCalls, 0);
    await cubit.close();
  });

  test('filters while loading do not flip to empty', () async {
    final sessions = FakeSessionRepository();
    final cubit = buildCubit(sessions: sessions);
    await cubit.initialize();
    // No seed events → still loading after subscribe.
    expect(cubit.state.loadPhase, HistoryListLoadPhase.loading);

    cubit.setNameQuery('push');
    expect(cubit.state.loadPhase, HistoryListLoadPhase.loading);

    sessions.emitSummaries(Ok([summary(name: 'Push')]));
    await pumpEventQueue();
    expect(cubit.state.loadPhase, HistoryListLoadPhase.ready);
    await cubit.close();
  });
}
