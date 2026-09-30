import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';
import 'package:vulcan_fitness/data/repositories/drift_schedule_repository.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/domain/models/local_start_time.dart';
import 'package:vulcan_fitness/domain/models/schedule_status.dart';
import 'package:vulcan_fitness/domain/models/scheduled_workout.dart';

import '../database/database_fixture.dart';

void main() {
  late AppDatabase database;
  late DriftScheduleRepository repository;

  final weekStart =
      (CalendarDate.fromIso('2026-09-21') as Ok<CalendarDate>).value;
  final weekEnd = weekStart.addDays(7);

  setUp(() {
    database = openTestDatabase();
    repository = DriftScheduleRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<List<ScheduledWorkout>> takeRange() async {
    final result = await repository
        .watchRange(startInclusive: weekStart, endExclusive: weekEnd)
        .first;
    return (result as Ok<List<ScheduledWorkout>>).value;
  }

  test('watchRange is half-open and ordered by date, start_time, id', () async {
    final workoutId = await insertWorkout(database);
    await insertSchedule(
      database,
      workoutId: workoutId,
      date: '2026-09-22',
      startTime: 120,
    );
    await insertSchedule(
      database,
      workoutId: workoutId,
      date: '2026-09-22',
      startTime: null,
    );
    await insertSchedule(
      database,
      workoutId: workoutId,
      date: '2026-09-22',
      startTime: 60,
    );
    await insertSchedule(database, workoutId: workoutId, date: '2026-09-20');
    await insertSchedule(database, workoutId: workoutId, date: '2026-09-28');

    final entries = await takeRange();
    expect(entries.map((e) => e.date.toIso()).toList(), [
      '2026-09-22',
      '2026-09-22',
      '2026-09-22',
    ]);
    expect(entries.map((e) => e.startTime?.minutesFromMidnight).toList(), [
      null,
      60,
      120,
    ]);
  });

  test('join includes archived workout name and archive flag', () async {
    final workoutId = await insertWorkout(database, name: 'Old Push');
    await (database.update(database.workout)
          ..where((row) => row.id.equals(workoutId)))
        .write(WorkoutCompanion(archivedAt: Value(startedAt)));
    await insertSchedule(database, workoutId: workoutId, date: '2026-09-23');

    final entries = await takeRange();
    expect(entries, hasLength(1));
    expect(entries.single.workoutName, 'Old Push');
    expect(entries.single.workoutArchived, isTrue);
  });

  test('add inserts planned entry and rejects missing workout', () async {
    final workoutId = await insertWorkout(database, name: 'Pull');
    final date = (CalendarDate.fromIso('2026-09-24') as Ok<CalendarDate>).value;
    final draft = (ScheduleDraft.create(
      workoutId: workoutId,
      date: date,
      startTime: (LocalStartTime.create(480) as Ok<LocalStartTime>).value,
      label: 'AM',
    ) as Ok<ScheduleDraft>).value;

    final added = await repository.add(draft);
    final value = (added as Ok<ScheduledWorkout>).value;
    expect(value.status, ScheduleStatus.planned);
    expect(value.workoutName, 'Pull');
    expect(value.label, 'AM');
    expect(value.startTime?.minutesFromMidnight, 480);
    expect(value.sessionId, isNull);

    final missing = await repository.add(
      (ScheduleDraft.create(
        workoutId: 999,
        date: date,
      ) as Ok<ScheduleDraft>).value,
    );
    expect(missing, isA<Err<ScheduledWorkout>>());
    expect((missing as Err).failure, isA<NotFoundFailure>());
  });

  test('add allows archived workouts; picker is what filters active', () async {
    final workoutId = await insertWorkout(database, name: 'Archive Me');
    await (database.update(database.workout)
          ..where((row) => row.id.equals(workoutId)))
        .write(WorkoutCompanion(archivedAt: Value(startedAt)));
    final date = (CalendarDate.fromIso('2026-09-24') as Ok<CalendarDate>).value;
    final result = await repository.add(
      (ScheduleDraft.create(
        workoutId: workoutId,
        date: date,
      ) as Ok<ScheduleDraft>).value,
    );
    expect(result, isA<Ok<ScheduledWorkout>>());
    expect((result as Ok).value.workoutArchived, isTrue);
  });

  test('move updates date and rejects running linked sessions', () async {
    final workoutId = await insertWorkout(database);
    final entryId = await insertSchedule(
      database,
      workoutId: workoutId,
      date: '2026-09-22',
    );
    final target =
        (CalendarDate.fromIso('2026-09-25') as Ok<CalendarDate>).value;

    final moved = await repository.move(entryId, target);
    expect(moved, isA<Ok<void>>());
    final afterMove = await takeRange();
    expect(afterMove.single.date.toIso(), '2026-09-25');

    await insertSession(
      database,
      workoutId: workoutId,
      scheduleEntryId: entryId,
      status: 'running',
    );
    final blocked = await repository.move(
      entryId,
      (CalendarDate.fromIso('2026-09-26') as Ok<CalendarDate>).value,
    );
    expect(blocked, isA<Err<void>>());
    expect((blocked as Err).failure, isA<ValidationFailure>());
  });

  test('move allows completed entries and rejects missing ids', () async {
    final workoutId = await insertWorkout(database);
    final entryId = await insertSchedule(
      database,
      workoutId: workoutId,
      date: '2026-09-22',
    );
    final sessionId = await insertSession(
      database,
      workoutId: workoutId,
      scheduleEntryId: entryId,
      status: 'finished',
    );
    await (database.update(
      database.scheduleEntry,
    )..where((row) => row.id.equals(entryId))).write(
      ScheduleEntryCompanion(
        status: const Value('completed_by_session'),
        sessionId: Value(sessionId),
      ),
    );

    final moved = await repository.move(
      entryId,
      (CalendarDate.fromIso('2026-09-27') as Ok<CalendarDate>).value,
    );
    expect(moved, isA<Ok<void>>());

    final missing = await repository.move(
      999,
      (CalendarDate.fromIso('2026-09-27') as Ok<CalendarDate>).value,
    );
    expect(missing, isA<Err<void>>());
    expect((missing as Err).failure, isA<NotFoundFailure>());
  });

  test('setSkipped toggles planned and skipped only', () async {
    final workoutId = await insertWorkout(database);
    final entryId = await insertSchedule(
      database,
      workoutId: workoutId,
      date: '2026-09-22',
    );

    expect(
      await repository.setSkipped(entryId, skipped: true),
      isA<Ok<void>>(),
    );
    expect((await takeRange()).single.status, ScheduleStatus.skipped);

    expect(
      await repository.setSkipped(entryId, skipped: false),
      isA<Ok<void>>(),
    );
    expect((await takeRange()).single.status, ScheduleStatus.planned);

    final sessionId = await insertSession(
      database,
      workoutId: workoutId,
      scheduleEntryId: entryId,
      status: 'finished',
    );
    await (database.update(
      database.scheduleEntry,
    )..where((row) => row.id.equals(entryId))).write(
      ScheduleEntryCompanion(
        status: const Value('completed_by_session'),
        sessionId: Value(sessionId),
      ),
    );
    final completedSkip = await repository.setSkipped(entryId, skipped: true);
    expect(completedSkip, isA<Err<void>>());
    expect((completedSkip as Err).failure, isA<ValidationFailure>());
  });

  test('setSkipped rejects running or paused linked sessions', () async {
    final workoutId = await insertWorkout(database);
    final entryId = await insertSchedule(
      database,
      workoutId: workoutId,
      date: '2026-09-22',
    );
    await insertSession(
      database,
      workoutId: workoutId,
      scheduleEntryId: entryId,
      status: 'paused',
    );

    final blocked = await repository.setSkipped(entryId, skipped: true);
    expect(blocked, isA<Err<void>>());
    expect((blocked as Err).failure, isA<ValidationFailure>());
  });

  test('watchRange yields ValidationFailure for corrupt status', () async {
    final workoutId = await insertWorkout(database);
    await database.customStatement('PRAGMA ignore_check_constraints = ON');
    await database.customStatement(
      "INSERT INTO schedule_entry (workout_id, date, status) "
      "VALUES (?, '2026-09-22', 'bogus')",
      [workoutId],
    );
    await database.customStatement('PRAGMA ignore_check_constraints = OFF');

    final result = await repository
        .watchRange(startInclusive: weekStart, endExclusive: weekEnd)
        .first;
    expect(result, isA<Err<List<ScheduledWorkout>>>());
    expect((result as Err).failure, isA<ValidationFailure>());
  });

  test('watchRange reflects add and workout rename', () async {
    final workoutId = await insertWorkout(database, name: 'Push');
    expect(await takeRange(), isEmpty);

    final date = (CalendarDate.fromIso('2026-09-22') as Ok<CalendarDate>).value;
    await repository.add(
      (ScheduleDraft.create(
        workoutId: workoutId,
        date: date,
      ) as Ok<ScheduleDraft>).value,
    );
    expect((await takeRange()).single.workoutName, 'Push');

    await (database.update(database.workout)
          ..where((row) => row.id.equals(workoutId)))
        .write(const WorkoutCompanion(name: Value('Push v2')));
    expect((await takeRange()).single.workoutName, 'Push v2');
  });

  test('watchRange emits reactively after add and workout rename', () async {
    final workoutId = await insertWorkout(database, name: 'Push');
    final events = <Result<List<ScheduledWorkout>>>[];
    final sub = repository
        .watchRange(startInclusive: weekStart, endExclusive: weekEnd)
        .listen(events.add);

    await pumpEventQueue();
    expect(events, isNotEmpty);
    expect((events.last as Ok).value, isEmpty);

    final date = (CalendarDate.fromIso('2026-09-22') as Ok<CalendarDate>).value;
    await repository.add(
      (ScheduleDraft.create(
        workoutId: workoutId,
        date: date,
      ) as Ok<ScheduleDraft>).value,
    );
    await pumpEventQueue();
    expect((events.last as Ok).value.single.workoutName, 'Push');

    await (database.update(database.workout)
          ..where((row) => row.id.equals(workoutId)))
        .write(const WorkoutCompanion(name: Value('Push v2')));
    await pumpEventQueue();
    expect((events.last as Ok).value.single.workoutName, 'Push v2');
    await sub.cancel();
  });
}
