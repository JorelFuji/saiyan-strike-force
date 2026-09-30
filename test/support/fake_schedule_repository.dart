import 'dart:async';

import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/domain/models/schedule_status.dart';
import 'package:vulcan_fitness/domain/models/scheduled_workout.dart';
import 'package:vulcan_fitness/domain/repositories/schedule_repository.dart';

/// Hand-written fake for Planner Cubit and widget tests.
final class FakeScheduleRepository implements ScheduleRepository {
  FakeScheduleRepository({List<ScheduledWorkout>? seed}) {
    if (seed != null) {
      _entries.addAll(seed);
    }
  }

  final List<ScheduledWorkout> _entries = [];
  final List<StreamController<Result<List<ScheduledWorkout>>>> _controllers =
      [];

  int watchCalls = 0;
  int addCalls = 0;
  int moveCalls = 0;
  int setSkippedCalls = 0;

  CalendarDate? lastStartInclusive;
  CalendarDate? lastEndExclusive;

  Result<ScheduledWorkout>? addResult;
  Result<void> moveResult = const Ok(null);
  Result<void> setSkippedResult = const Ok(null);

  List<ScheduledWorkout> get entries => List.unmodifiable(_entries);

  void seed(List<ScheduledWorkout> values) {
    _entries
      ..clear()
      ..addAll(values);
    _emit();
  }

  void emitError(Failure failure) {
    for (final controller in _controllers) {
      if (!controller.isClosed) {
        controller.add(Err(failure));
      }
    }
  }

  @override
  Stream<Result<List<ScheduledWorkout>>> watchRange({
    required CalendarDate startInclusive,
    required CalendarDate endExclusive,
  }) {
    watchCalls++;
    lastStartInclusive = startInclusive;
    lastEndExclusive = endExclusive;
    late StreamController<Result<List<ScheduledWorkout>>> controller;
    controller = StreamController<Result<List<ScheduledWorkout>>>.broadcast(
      onListen: () {
        if (!controller.isClosed) {
          controller.add(Ok(_filter(startInclusive, endExclusive)));
        }
      },
      onCancel: () {
        _controllers.remove(controller);
        unawaited(controller.close());
      },
    );
    _controllers.add(controller);
    return controller.stream;
  }

  @override
  Future<Result<ScheduledWorkout>> add(ScheduleDraft draft) async {
    addCalls++;
    if (addResult != null) {
      final result = addResult!;
      if (result case Ok(:final value)) {
        _entries.add(value);
        _emit();
      }
      return result;
    }
    final nextId = _entries.isEmpty
        ? 1
        : _entries.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    final created = (ScheduledWorkout.create(
      id: nextId,
      workoutId: draft.workoutId,
      date: draft.date,
      startTime: draft.startTime,
      label: draft.label,
      status: ScheduleStatus.planned,
      workoutName: 'Workout ${draft.workoutId}',
      workoutArchived: false,
    ) as Ok<ScheduledWorkout>).value;
    _entries.add(created);
    _emit();
    return Ok(created);
  }

  @override
  Future<Result<void>> move(int entryId, CalendarDate date) async {
    moveCalls++;
    if (moveResult is Err) {
      return moveResult;
    }
    final index = _entries.indexWhere((e) => e.id == entryId);
    if (index < 0) {
      return const Err(NotFoundFailure('Schedule entry was not found.'));
    }
    final current = _entries[index];
    final updated = (ScheduledWorkout.create(
      id: current.id,
      workoutId: current.workoutId,
      date: date,
      startTime: current.startTime,
      label: current.label,
      status: current.status,
      sessionId: current.sessionId,
      workoutName: current.workoutName,
      workoutArchived: current.workoutArchived,
    ) as Ok<ScheduledWorkout>).value;
    _entries[index] = updated;
    _emit();
    return const Ok(null);
  }

  @override
  Future<Result<void>> setSkipped(int entryId, {required bool skipped}) async {
    setSkippedCalls++;
    if (setSkippedResult is Err) {
      return setSkippedResult;
    }
    final index = _entries.indexWhere((e) => e.id == entryId);
    if (index < 0) {
      return const Err(NotFoundFailure('Schedule entry was not found.'));
    }
    final current = _entries[index];
    final updated = (ScheduledWorkout.create(
      id: current.id,
      workoutId: current.workoutId,
      date: current.date,
      startTime: current.startTime,
      label: current.label,
      status: skipped ? ScheduleStatus.skipped : ScheduleStatus.planned,
      sessionId: null,
      workoutName: current.workoutName,
      workoutArchived: current.workoutArchived,
    ) as Ok<ScheduledWorkout>).value;
    _entries[index] = updated;
    _emit();
    return const Ok(null);
  }

  List<ScheduledWorkout> _filter(
    CalendarDate startInclusive,
    CalendarDate endExclusive,
  ) {
    return _entries
        .where(
          (entry) => entry.date >= startInclusive && entry.date < endExclusive,
        )
        .toList()
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) return byDate;
        final aStart = a.startTime?.minutesFromMidnight;
        final bStart = b.startTime?.minutesFromMidnight;
        if (aStart == null && bStart != null) return -1;
        if (aStart != null && bStart == null) return 1;
        if (aStart != null && bStart != null) {
          final byStart = aStart.compareTo(bStart);
          if (byStart != 0) return byStart;
        }
        return a.id.compareTo(b.id);
      });
  }

  void _emit() {
    for (final controller in List.of(_controllers)) {
      if (controller.isClosed) continue;
      final start = lastStartInclusive;
      final end = lastEndExclusive;
      if (start == null || end == null) continue;
      controller.add(Ok(_filter(start, end)));
    }
  }
}
