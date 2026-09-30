import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/domain/models/local_start_time.dart';
import 'package:vulcan_fitness/domain/models/schedule_status.dart';
import 'package:vulcan_fitness/domain/models/scheduled_workout.dart';

void main() {
  final date = (CalendarDate.fromIso('2026-09-26') as Ok<CalendarDate>).value;
  final start = (LocalStartTime.create(90) as Ok<LocalStartTime>).value;

  test('ScheduleDraft validates workout id and trims blank labels', () {
    final ok = (ScheduleDraft.create(
      workoutId: 1,
      date: date,
      startTime: start,
      label: '  AM  ',
    ) as Ok<ScheduleDraft>).value;
    expect(ok.workoutId, 1);
    expect(ok.label, 'AM');
    expect(ok.startTime, start);

    final blankLabel = (ScheduleDraft.create(
      workoutId: 2,
      date: date,
      label: '   ',
    ) as Ok<ScheduleDraft>).value;
    expect(blankLabel.label, isNull);

    expect(
      ScheduleDraft.create(workoutId: 0, date: date),
      isA<Err<ScheduleDraft>>(),
    );
  });

  test('ScheduledWorkout validates identifiers and blank names', () {
    final ok = (ScheduledWorkout.create(
      id: 1,
      workoutId: 2,
      date: date,
      startTime: start,
      label: 'PM',
      status: ScheduleStatus.planned,
      sessionId: null,
      workoutName: ' Push ',
      workoutArchived: false,
    ) as Ok<ScheduledWorkout>).value;
    expect(ok.workoutName, 'Push');
    expect(ok.status, ScheduleStatus.planned);

    expect(
      ScheduledWorkout.create(
        id: 0,
        workoutId: 1,
        date: date,
        status: ScheduleStatus.planned,
        workoutName: 'Push',
        workoutArchived: false,
      ),
      isA<Err<ScheduledWorkout>>(),
    );
    expect(
      ScheduledWorkout.create(
        id: 1,
        workoutId: 1,
        date: date,
        status: ScheduleStatus.planned,
        sessionId: 0,
        workoutName: 'Push',
        workoutArchived: false,
      ),
      isA<Err<ScheduledWorkout>>(),
    );
    expect(
      ScheduledWorkout.create(
        id: 1,
        workoutId: 1,
        date: date,
        status: ScheduleStatus.planned,
        workoutName: '   ',
        workoutArchived: false,
      ),
      isA<Err<ScheduledWorkout>>(),
    );
  });
}
