import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/clock.dart';
import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/scheduled_workout.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/services/timezone_service.dart';
import '../../domain/usecases/start_session.dart';
import 'planner_state.dart';

export 'planner_state.dart' show monthRangeFor, weekStartFor;

final class PlannerCubit extends Cubit<PlannerState> {
  PlannerCubit({
    required ScheduleRepository scheduleRepository,
    required WorkoutRepository workoutRepository,
    required StartSession startSession,
    required TimezoneService timezoneService,
    required Clock clock,
    required CalendarDate initialWeekStart,
    required int firstDayOfWeekIndex,
    CalendarDate? initialSelectedDate,
  }) : _schedules = scheduleRepository,
       _workouts = workoutRepository,
       _starts = startSession,
       _timezones = timezoneService,
       _clock = clock,
       super(
         PlannerState(
           weekStart: initialWeekStart,
           monthAnchor: initialSelectedDate ?? initialWeekStart,
           firstDayOfWeekIndex: firstDayOfWeekIndex,
           selectedDate: initialSelectedDate ?? initialWeekStart,
           today: calendarDateFromClock(clock),
         ),
       );

  final ScheduleRepository _schedules;
  final WorkoutRepository _workouts;
  final StartSession _starts;
  final TimezoneService _timezones;
  final Clock _clock;

  StreamSubscription<Result<List<ScheduledWorkout>>>? _visibleRangeSubscription;
  int _watchGeneration = 0;

  WorkoutRepository get workoutRepository => _workouts;

  /// Begins watching the current visible range. Safe to call once after construction.
  void initialize() {
    _subscribeToVisibleRange();
  }

  void selectDay(CalendarDate date) {
    emit(state.copyWith(selectedDate: date, clearFailureMessage: true));
  }

  void goToPreviousWeek() => setWeekStart(state.weekStart.addDays(-7));

  void goToNextWeek() => setWeekStart(state.weekStart.addDays(7));

  void setWeekStart(CalendarDate weekStart) {
    _setVisibleState(
      state.copyWith(
        weekStart: weekStart,
        selectedDate: _clampSelectedToRange(
          state.selectedDate,
          PlannerVisibleRange(
            startInclusive: weekStart,
            endExclusive: weekStart.addDays(7),
          ),
        ),
      ),
    );
  }

  void setViewMode(PlannerViewMode mode) {
    if (state.viewMode == mode) return;
    final selected = state.selectedDate;
    final monthAnchor = monthAnchorForVisibleRange(selected);
    final newWeekStart = weekStartFor(
      today: selected,
      firstDayOfWeekIndex: state.firstDayOfWeekIndex,
    );
    _setVisibleState(
      state.copyWith(
        viewMode: mode,
        weekStart: newWeekStart,
        monthAnchor: monthAnchor,
      ),
    );
  }

  void goToPrevious() => _navigate(-1);

  void goToNext() => _navigate(1);

  void retry() => _setVisibleState(state);

  void _navigate(int direction) {
    if (state.viewMode == PlannerViewMode.week) {
      setWeekStart(state.weekStart.addDays(direction * 7));
      return;
    }
    final anchor = _shiftMonth(state.monthAnchor, direction);
    if (anchor == null) return;
    final range = monthRangeFor(
      monthAnchor: anchor,
      firstDayOfWeekIndex: state.firstDayOfWeekIndex,
    );
    _setVisibleState(
      state.copyWith(
        monthAnchor: anchor,
        selectedDate: _clampSelectedToRange(state.selectedDate, range),
      ),
    );
  }

  Future<void> addWorkout(int workoutId) async {
    if (state.actionPending) return;
    emit(state.copyWith(actionPending: true, clearFailureMessage: true));
    final draft = ScheduleDraft.create(
      workoutId: workoutId,
      date: state.selectedDate,
    );
    if (draft case Err(:final failure)) {
      emit(
        state.copyWith(actionPending: false, failureMessage: failure.message),
      );
      return;
    }
    final result = await _schedules.add((draft as Ok<ScheduleDraft>).value);
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(state.copyWith(actionPending: false, clearFailureMessage: true));
      case Err(:final failure):
        emit(
          state.copyWith(actionPending: false, failureMessage: failure.message),
        );
    }
  }

  Future<void> moveEntry(int entryId, CalendarDate date) async {
    if (state.actionPending) return;
    emit(state.copyWith(actionPending: true, clearFailureMessage: true));
    final result = await _schedules.move(entryId, date);
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(state.copyWith(actionPending: false, clearFailureMessage: true));
      case Err(:final failure):
        emit(
          state.copyWith(actionPending: false, failureMessage: failure.message),
        );
    }
  }

  Future<void> setSkipped(int entryId, {required bool skipped}) async {
    if (state.actionPending) return;
    emit(state.copyWith(actionPending: true, clearFailureMessage: true));
    final result = await _schedules.setSkipped(entryId, skipped: skipped);
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(state.copyWith(actionPending: false, clearFailureMessage: true));
      case Err(:final failure):
        emit(
          state.copyWith(actionPending: false, failureMessage: failure.message),
        );
    }
  }

  Future<void> copyWeekForward() async {
    if (state.actionPending) return;
    emit(
      state.copyWith(
        actionPending: true,
        clearFailureMessage: true,
        clearCopySuccessCount: true,
      ),
    );
    final result = await _schedules.copyWeekForward(state.weekStart);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            actionPending: false,
            copySuccessCount: value,
            clearFailureMessage: true,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(actionPending: false, failureMessage: failure.message),
        );
    }
  }

  Future<void> startEntry(int entryId) async {
    if (state.actionPending || state.startPendingEntryId != null) return;
    final entry = state.visibleRangeEntries
        .where((e) => e.id == entryId)
        .firstOrNull;
    if (entry == null) {
      emit(state.copyWith(failureMessage: 'Schedule entry was not found.'));
      return;
    }
    emit(
      state.copyWith(
        actionPending: true,
        startPendingEntryId: entryId,
        clearFailureMessage: true,
        clearStartedSessionId: true,
      ),
    );

    final timezoneResult = await _timezones.localIanaIdentifier();
    if (isClosed) return;
    if (timezoneResult case Err(:final failure)) {
      emit(
        state.copyWith(
          actionPending: false,
          clearStartPendingEntryId: true,
          failureMessage: failure.message,
        ),
      );
      return;
    }
    final timezone = (timezoneResult as Ok<String>).value;
    final command = StartSessionCommand.create(
      workoutId: entry.workoutId,
      scheduleEntryId: entry.id,
      startedAt: _clock.now(),
      timezone: timezone,
    );
    if (command case Err(:final failure)) {
      emit(
        state.copyWith(
          actionPending: false,
          clearStartPendingEntryId: true,
          failureMessage: failure.message,
        ),
      );
      return;
    }
    final result = await _starts((command as Ok<StartSessionCommand>).value);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            actionPending: false,
            clearStartPendingEntryId: true,
            startedSessionId: value,
            clearFailureMessage: true,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            actionPending: false,
            clearStartPendingEntryId: true,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void clearStartedSessionId() {
    if (state.startedSessionId == null) return;
    emit(state.copyWith(clearStartedSessionId: true));
  }

  void clearCopySuccessCount() {
    if (state.copySuccessCount == null) return;
    emit(state.copyWith(clearCopySuccessCount: true));
  }

  void clearFailureMessage() {
    if (state.failureMessage == null) return;
    emit(state.copyWith(clearFailureMessage: true));
  }

  void _setVisibleState(PlannerState nextState) {
    emit(
      nextState.copyWith(
        loadPhase: PlannerLoadPhase.loading,
        clearFailureMessage: true,
      ),
    );
    _subscribeToVisibleRange();
  }

  void _subscribeToVisibleRange() {
    final generation = ++_watchGeneration;
    final range = state.visibleRange;
    unawaited(_visibleRangeSubscription?.cancel());
    _visibleRangeSubscription = _schedules
        .watchRange(
          startInclusive: range.startInclusive,
          endExclusive: range.endExclusive,
        )
        .listen(
          (result) {
            if (isClosed || generation != _watchGeneration) return;
            switch (result) {
              case Ok(:final value):
                emit(
                  state.copyWith(
                    loadPhase: PlannerLoadPhase.ready,
                    visibleRangeEntries: value,
                    today: calendarDateFromClock(_clock),
                  ),
                );
              case Err(:final failure):
                emit(
                  state.copyWith(
                    loadPhase: PlannerLoadPhase.error,
                    failureMessage: failure.message,
                  ),
                );
            }
          },
          onError: (Object error, StackTrace stack) {
            if (isClosed || generation != _watchGeneration) return;
            emit(
              state.copyWith(
                loadPhase: PlannerLoadPhase.error,
                failureMessage: StorageFailure(
                  'Schedule watch failed.',
                  cause: error,
                  stackTrace: stack,
                ).message,
              ),
            );
          },
        );
  }

  static CalendarDate _clampSelectedToRange(
    CalendarDate selected,
    PlannerVisibleRange range,
  ) {
    if (range.contains(selected)) {
      return selected;
    }
    return range.startInclusive;
  }

  @override
  Future<void> close() async {
    await _visibleRangeSubscription?.cancel();
    return super.close();
  }
}

/// Builds a local [CalendarDate] from [clock.now] for missed-day derivation.
///
/// Device clocks always yield a civil date in range. Extreme test clocks that
/// fall outside year 1…9999 fall back to 1970-01-01 instead of throwing.
CalendarDate calendarDateFromClock(Clock clock) {
  final local = clock.now().toLocal();
  final result = CalendarDate.create(
    year: local.year,
    month: local.month,
    day: local.day,
  );
  return switch (result) {
    Ok(:final value) => value,
    Err() => (CalendarDate.create(
      year: 1970,
      month: 1,
      day: 1,
    ) as Ok<CalendarDate>).value,
  };
}

CalendarDate? _shiftMonth(CalendarDate anchor, int delta) {
  final rawMonth = anchor.month + delta;
  final year = anchor.year + ((rawMonth - 1) ~/ 12);
  final month = (rawMonth - 1) % 12 + 1;
  // Month anchors are always day one; this keeps navigation valid at bounds.
  final result = CalendarDate.create(year: year, month: month, day: 1);
  return switch (result) {
    Ok(:final value) =>
      monthAnchorForVisibleRange(value) == anchor
          ? null
          : monthAnchorForVisibleRange(value),
    Err() => null,
  };
}
