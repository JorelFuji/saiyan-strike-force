import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/clock.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/domain/models/schedule_status.dart';
import 'package:vulcan_fitness/domain/models/scheduled_workout.dart';
import 'package:vulcan_fitness/domain/services/timezone_service.dart';
import 'package:vulcan_fitness/domain/usecases/start_session.dart';
import 'package:vulcan_fitness/ui/planner/planner_cubit.dart';
import 'package:vulcan_fitness/ui/planner/planner_state.dart';

import '../../support/fake_schedule_repository.dart';
import '../../support/fake_session_repository.dart';
import '../../support/fake_timezone_service.dart';
import '../../support/fake_workout_repository.dart';

final class FixedClock implements Clock {
  FixedClock(this.instant);

  DateTime instant;

  @override
  DateTime now() => instant;
}

void main() {
  final weekStart =
      (CalendarDate.fromIso('2026-09-21') as Ok<CalendarDate>).value;
  // Fixed UTC instant whose local calendar date is asserted explicitly below.
  final clock = FixedClock(DateTime.utc(2026, 9, 24, 18));

  CalendarDate expectedToday() {
    final local = clock.now().toLocal();
    return (CalendarDate.create(
      year: local.year,
      month: local.month,
      day: local.day,
    ) as Ok<CalendarDate>).value;
  }

  ScheduledWorkout entry({
    int id = 1,
    String date = '2026-09-24',
    ScheduleStatus status = ScheduleStatus.planned,
    String name = 'Push',
  }) {
    return (ScheduledWorkout.create(
      id: id,
      workoutId: 10,
      date: (CalendarDate.fromIso(date) as Ok<CalendarDate>).value,
      status: status,
      workoutName: name,
      workoutArchived: false,
    ) as Ok<ScheduledWorkout>).value;
  }

  PlannerCubit buildCubit({
    FakeScheduleRepository? schedules,
    FakeSessionRepository? sessions,
    FakeTimezoneService? timezones,
    CalendarDate? selected,
  }) {
    final sessionRepo = sessions ?? FakeSessionRepository();
    return PlannerCubit(
      scheduleRepository: schedules ?? FakeScheduleRepository(),
      workoutRepository: FakeWorkoutRepository(),
      startSession: StartSession(sessionRepo),
      timezoneService: timezones ?? FakeTimezoneService(),
      clock: clock,
      initialWeekStart: weekStart,
      initialSelectedDate: selected ?? expectedToday(),
    );
  }

  test(
    'initialize watches week and replaces subscription on week change',
    () async {
      final schedules = FakeScheduleRepository(seed: [entry()]);
      final cubit = buildCubit(schedules: schedules);

      cubit.initialize();
      await pumpEventQueue();
      expect(schedules.watchCalls, 1);
      expect(cubit.state.loadPhase, PlannerLoadPhase.ready);
      expect(cubit.state.weekEntries, hasLength(1));
      expect(schedules.lastEndExclusive, weekStart.addDays(7));

      cubit.goToNextWeek();
      await pumpEventQueue();
      expect(schedules.watchCalls, 2);
      expect(cubit.state.weekStart, weekStart.addDays(7));
      await cubit.close();
    },
  );

  test('derives missed for planned entries before local today', () async {
    final today = expectedToday();
    final past = today.addDays(-1);
    final schedules = FakeScheduleRepository(
      seed: [
        entry(id: 1, date: past.toIso()),
        entry(id: 2, date: today.toIso()),
      ],
    );
    final cubit = buildCubit(schedules: schedules, selected: today)
      ..initialize();
    await pumpEventQueue();

    cubit.selectDay(past);
    expect(
      cubit.state.selectedDayEntries.single.displayStatus,
      PlannerDisplayStatus.missed,
    );
    cubit.selectDay(today);
    expect(
      cubit.state.selectedDayEntries.single.displayStatus,
      PlannerDisplayStatus.planned,
    );
    await cubit.close();
  });

  test('add, move, and skip surface repository failures', () async {
    final schedules = FakeScheduleRepository()
      ..addResult = const Err(StorageFailure('add failed'))
      ..moveResult = const Err(ValidationFailure('move blocked'))
      ..setSkippedResult = const Err(ValidationFailure('skip blocked'));
    final cubit = buildCubit(schedules: schedules)..initialize();
    await pumpEventQueue();

    await cubit.addWorkout(1);
    expect(cubit.state.failureMessage, 'add failed');

    await cubit.moveEntry(1, weekStart);
    expect(cubit.state.failureMessage, 'move blocked');

    await cubit.setSkipped(1, skipped: true);
    expect(cubit.state.failureMessage, 'skip blocked');
    await cubit.close();
  });

  test(
    'startEntry emits session id on success and keeps week stream',
    () async {
      final schedules = FakeScheduleRepository(seed: [entry()]);
      final sessions = FakeSessionRepository()..startResult = const Ok(77);
      final cubit = buildCubit(schedules: schedules, sessions: sessions)
        ..initialize();
      await pumpEventQueue();

      await cubit.startEntry(1);
      expect(cubit.state.startedSessionId, 77);
      expect(sessions.startCalls, 1);
      expect(cubit.state.weekEntries, hasLength(1));
      await cubit.close();
    },
  );

  test('startEntry ignores concurrent starts while pending', () async {
    final schedules = FakeScheduleRepository(seed: [entry()]);
    final sessions = FakeSessionRepository();
    final completer = Completer<Result<int>>();
    sessions.startFromTemplateOverride = (_) => completer.future;
    final cubit = buildCubit(schedules: schedules, sessions: sessions)
      ..initialize();
    await pumpEventQueue();

    final first = cubit.startEntry(1);
    final second = cubit.startEntry(1);
    completer.complete(const Ok(55));
    await Future.wait([first, second]);
    expect(sessions.startCalls, 1);
    expect(cubit.state.startedSessionId, 55);
    await cubit.close();
  });

  test('startEntry surfaces timezone and start failures', () async {
    final schedules = FakeScheduleRepository(seed: [entry()]);
    final sessions = FakeSessionRepository()
      ..startResult = const Err(ValidationFailure('cannot start'));

    final failingCubit = PlannerCubit(
      scheduleRepository: schedules,
      workoutRepository: FakeWorkoutRepository(),
      startSession: StartSession(sessions),
      timezoneService: _FailingTimezoneService(),
      clock: clock,
      initialWeekStart: weekStart,
      initialSelectedDate: expectedToday(),
    )..initialize();
    await pumpEventQueue();
    await failingCubit.startEntry(1);
    expect(failingCubit.state.failureMessage, 'timezone unavailable');
    expect(sessions.startCalls, 0);
    await failingCubit.close();

    final cubit = buildCubit(schedules: schedules, sessions: sessions)
      ..initialize();
    await pumpEventQueue();
    await cubit.startEntry(1);
    expect(cubit.state.failureMessage, 'cannot start');
    expect(cubit.state.startedSessionId, isNull);
    await cubit.close();
  });

  test('weekStartFor respects locale first-day index', () {
    final wednesday =
        (CalendarDate.fromIso('2026-09-23') as Ok<CalendarDate>).value;
    // Sunday-first (US): week starts 2026-09-20
    expect(
      weekStartFor(today: wednesday, firstDayOfWeekIndex: 0).toIso(),
      '2026-09-20',
    );
    // Monday-first: week starts 2026-09-21
    expect(
      weekStartFor(today: wednesday, firstDayOfWeekIndex: 1).toIso(),
      '2026-09-21',
    );
  });
}

final class _FailingTimezoneService implements TimezoneService {
  @override
  Future<Result<String>> localIanaIdentifier() async {
    return const Err(StorageFailure('timezone unavailable'));
  }
}
