import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/domain/models/completed_session_summary.dart';

void main() {
  final startedOn =
      (CalendarDate.fromIso('2026-09-01') as Ok<CalendarDate>).value;
  final startedAt = DateTime.utc(2026, 9, 1, 15);
  final endedAt = DateTime.utc(2026, 9, 1, 16, 30);

  CompletedSessionSummary valid({
    int id = 1,
    String name = 'Push',
    CalendarDate? on,
    DateTime? start,
    DateTime? end,
    String timezone = 'America/Denver',
    int completed = 2,
    int total = 3,
    int volume = 1000,
  }) {
    return (CompletedSessionSummary.create(
      id: id,
      workoutNameSnapshot: name,
      startedOn: on ?? startedOn,
      startedAt: start ?? startedAt,
      endedAt: end ?? endedAt,
      timezone: timezone,
      completedSetCount: completed,
      totalSetCount: total,
      absoluteVolumeMilligramReps: volume,
    ) as Ok<CompletedSessionSummary>).value;
  }

  test('create accepts valid finished summary fields', () {
    final summary = valid();
    expect(summary.id, 1);
    expect(summary.workoutNameSnapshot, 'Push');
    expect(summary.startedOn, startedOn);
    expect(summary.duration, const Duration(hours: 1, minutes: 30));
    expect(summary.completionLabel, '2/3');
    expect(summary.absoluteVolumeMilligramReps, 1000);
  });

  test('create rejects invalid identifiers, names, and timezones', () {
    expect(
      CompletedSessionSummary.create(
        id: 0,
        workoutNameSnapshot: 'Push',
        startedOn: startedOn,
        startedAt: startedAt,
        endedAt: endedAt,
        timezone: 'America/Denver',
        completedSetCount: 0,
        totalSetCount: 0,
        absoluteVolumeMilligramReps: 0,
      ),
      isA<Err<CompletedSessionSummary>>(),
    );
    expect(
      CompletedSessionSummary.create(
        id: 1,
        workoutNameSnapshot: '  ',
        startedOn: startedOn,
        startedAt: startedAt,
        endedAt: endedAt,
        timezone: 'America/Denver',
        completedSetCount: 0,
        totalSetCount: 0,
        absoluteVolumeMilligramReps: 0,
      ),
      isA<Err<CompletedSessionSummary>>(),
    );
    expect(
      CompletedSessionSummary.create(
        id: 1,
        workoutNameSnapshot: 'Push',
        startedOn: startedOn,
        startedAt: startedAt,
        endedAt: endedAt,
        timezone: 'not-a-zone',
        completedSetCount: 0,
        totalSetCount: 0,
        absoluteVolumeMilligramReps: 0,
      ),
      isA<Err<CompletedSessionSummary>>(),
    );
  });

  test('create rejects endedAt before startedAt', () {
    final result = CompletedSessionSummary.create(
      id: 1,
      workoutNameSnapshot: 'Push',
      startedOn: startedOn,
      startedAt: endedAt,
      endedAt: startedAt,
      timezone: 'UTC',
      completedSetCount: 0,
      totalSetCount: 0,
      absoluteVolumeMilligramReps: 0,
    );
    expect(result, isA<Err<CompletedSessionSummary>>());
    expect(
      (result as Err<CompletedSessionSummary>).failure,
      isA<ValidationFailure>(),
    );
  });

  test(
    'create rejects negative counts, completed over total, and negative volume',
    () {
      expect(
        CompletedSessionSummary.create(
          id: 1,
          workoutNameSnapshot: 'Push',
          startedOn: startedOn,
          startedAt: startedAt,
          endedAt: endedAt,
          timezone: 'UTC',
          completedSetCount: -1,
          totalSetCount: 1,
          absoluteVolumeMilligramReps: 0,
        ),
        isA<Err<CompletedSessionSummary>>(),
      );
      expect(
        CompletedSessionSummary.create(
          id: 1,
          workoutNameSnapshot: 'Push',
          startedOn: startedOn,
          startedAt: startedAt,
          endedAt: endedAt,
          timezone: 'UTC',
          completedSetCount: 2,
          totalSetCount: 1,
          absoluteVolumeMilligramReps: 0,
        ),
        isA<Err<CompletedSessionSummary>>(),
      );
      expect(
        CompletedSessionSummary.create(
          id: 1,
          workoutNameSnapshot: 'Push',
          startedOn: startedOn,
          startedAt: startedAt,
          endedAt: endedAt,
          timezone: 'UTC',
          completedSetCount: 0,
          totalSetCount: 0,
          absoluteVolumeMilligramReps: -1,
        ),
        isA<Err<CompletedSessionSummary>>(),
      );
    },
  );

  test('duration and completion helpers use validated fields', () {
    final summary = valid(completed: 18, total: 20);
    expect(summary.duration.inMinutes, 90);
    expect(summary.completionLabel, '18/20');
  });
}
