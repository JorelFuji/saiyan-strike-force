import 'package:drift/drift.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/local_start_time.dart';
import '../../domain/models/schedule_status.dart';
import '../../domain/models/scheduled_workout.dart';
import '../../domain/models/session_status.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../database/app_database.dart';

final class DriftScheduleRepository implements ScheduleRepository {
  DriftScheduleRepository(this.database);

  final AppDatabase database;

  @override
  Stream<Result<List<ScheduledWorkout>>> watchRange({
    required CalendarDate startInclusive,
    required CalendarDate endExclusive,
  }) {
    final startIso = startInclusive.toIso();
    final endIso = endExclusive.toIso();
    final query =
        database.select(database.scheduleEntry).join([
            innerJoin(
              database.workout,
              database.workout.id.equalsExp(database.scheduleEntry.workoutId),
            ),
          ])
          ..where(
            database.scheduleEntry.date.isBiggerOrEqualValue(startIso) &
                database.scheduleEntry.date.isSmallerThanValue(endIso),
          )
          ..orderBy([
            OrderingTerm.asc(database.scheduleEntry.date),
            OrderingTerm.asc(database.scheduleEntry.startTime),
            OrderingTerm.asc(database.scheduleEntry.id),
          ]);

    return query.watch().map((rows) {
      try {
        final values = <ScheduledWorkout>[];
        for (final row in rows) {
          final entry = row.readTable(database.scheduleEntry);
          final workout = row.readTable(database.workout);
          final mapped = _mapJoined(entry, workout);
          if (mapped case Err(:final failure)) {
            return Err<List<ScheduledWorkout>>(failure);
          }
          values.add((mapped as Ok<ScheduledWorkout>).value);
        }
        return Ok<List<ScheduledWorkout>>(values);
      } on Exception catch (error, stack) {
        return Err<List<ScheduledWorkout>>(_storageFailure(error, stack));
      }
    });
  }

  @override
  Future<Result<ScheduledWorkout>> add(ScheduleDraft draft) async {
    try {
      final workout = await (database.select(
        database.workout,
      )..where((row) => row.id.equals(draft.workoutId))).getSingleOrNull();
      if (workout == null) {
        return const Err(NotFoundFailure('Workout template was not found.'));
      }

      final id = await database
          .into(database.scheduleEntry)
          .insert(
            ScheduleEntryCompanion.insert(
              workoutId: draft.workoutId,
              date: draft.date.toIso(),
              startTime: Value(draft.startTime?.minutesFromMidnight),
              label: Value(draft.label),
              status: ScheduleStatus.planned.wireValue,
            ),
          );

      final mapped = _mapJoined(
        ScheduleEntryData(
          id: id,
          workoutId: draft.workoutId,
          date: draft.date.toIso(),
          startTime: draft.startTime?.minutesFromMidnight,
          label: draft.label,
          status: ScheduleStatus.planned.wireValue,
          sessionId: null,
        ),
        workout,
      );
      return mapped;
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> move(int entryId, CalendarDate date) async {
    try {
      return await database.transaction(() async {
        final entry = await _loadEntry(entryId);
        if (entry == null) {
          return const Err(NotFoundFailure('Schedule entry was not found.'));
        }
        final blocked = await _hasActiveLinkedSession(entryId);
        if (blocked) {
          return const Err(
            ValidationFailure(
              'Cannot move a schedule entry while its session is running or paused.',
            ),
          );
        }
        await (database.update(database.scheduleEntry)
              ..where((row) => row.id.equals(entryId)))
            .write(ScheduleEntryCompanion(date: Value(date.toIso())));
        return const Ok(null);
      });
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> setSkipped(int entryId, {required bool skipped}) async {
    try {
      return await database.transaction(() async {
        final entry = await _loadEntry(entryId);
        if (entry == null) {
          return const Err(NotFoundFailure('Schedule entry was not found.'));
        }
        final status = ScheduleStatus.fromWire(entry.status);
        if (status case Err(:final failure)) {
          return Err(failure);
        }
        final wire = (status as Ok<ScheduleStatus>).value;
        if (wire == ScheduleStatus.completedBySession) {
          return const Err(
            ValidationFailure('Completed schedule entries cannot be skipped.'),
          );
        }
        final target = skipped
            ? ScheduleStatus.skipped
            : ScheduleStatus.planned;
        if (wire == target) {
          return const Err(
            ValidationFailure('Schedule entry is already in the target state.'),
          );
        }
        if (wire != ScheduleStatus.planned && wire != ScheduleStatus.skipped) {
          return const Err(
            ValidationFailure(
              'Only planned or skipped entries can change skip.',
            ),
          );
        }
        final blocked = await _hasActiveLinkedSession(entryId);
        if (blocked) {
          return const Err(
            ValidationFailure(
              'Cannot change skip while a linked session is running or paused.',
            ),
          );
        }
        await (database.update(
          database.scheduleEntry,
        )..where((row) => row.id.equals(entryId))).write(
          ScheduleEntryCompanion(
            status: Value(target.wireValue),
            sessionId: const Value(null),
          ),
        );
        return const Ok(null);
      });
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  Future<ScheduleEntryData?> _loadEntry(int entryId) {
    return (database.select(
      database.scheduleEntry,
    )..where((row) => row.id.equals(entryId))).getSingleOrNull();
  }

  Future<bool> _hasActiveLinkedSession(int entryId) async {
    final active =
        await (database.select(database.session)..where(
              (row) =>
                  row.scheduleEntryId.equals(entryId) &
                  (row.status.equals(SessionStatus.running.wireValue) |
                      row.status.equals(SessionStatus.paused.wireValue)),
            ))
            .get();
    return active.isNotEmpty;
  }

  Result<ScheduledWorkout> _mapJoined(
    ScheduleEntryData entry,
    WorkoutData workout,
  ) {
    final date = CalendarDate.fromIso(entry.date);
    if (date case Err(:final failure)) {
      return Err(failure);
    }
    final status = ScheduleStatus.fromWire(entry.status);
    if (status case Err(:final failure)) {
      return Err(failure);
    }
    LocalStartTime? startTime;
    if (entry.startTime != null) {
      final parsed = LocalStartTime.create(entry.startTime!);
      if (parsed case Err(:final failure)) {
        return Err(failure);
      }
      startTime = (parsed as Ok<LocalStartTime>).value;
    }
    return ScheduledWorkout.create(
      id: entry.id,
      workoutId: entry.workoutId,
      date: (date as Ok<CalendarDate>).value,
      startTime: startTime,
      label: entry.label,
      status: (status as Ok<ScheduleStatus>).value,
      sessionId: entry.sessionId,
      workoutName: workout.name,
      workoutArchived: workout.archivedAt != null,
    );
  }

  StorageFailure _storageFailure(Object error, StackTrace stack) =>
      StorageFailure(
        'Schedule storage operation failed.',
        cause: error,
        stackTrace: stack,
      );
}
