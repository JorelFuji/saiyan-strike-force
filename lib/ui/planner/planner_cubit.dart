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

final class PlannerCubit extends Cubit<PlannerState> {
  PlannerCubit({
    required ScheduleRepository scheduleRepository,
    required WorkoutRepository workoutRepository,
    required StartSession startSession,
    required TimezoneService timezoneService,
    required Clock clock,
    required CalendarDate initialWeekStart,
    CalendarDate? initialSelectedDate,
  }) : _schedules = scheduleRepository,
       _workouts = workoutRepository,
       _starts = startSession,
       _timezones = timezoneService,
       _clock = clock,
       super(
         PlannerState(
           weekStart: initialWeekStart,
           selectedDate: initialSelectedDate ?? initialWeekStart,
           today: calendarDateFromClock(clock),
         ),
       );

  final ScheduleRepository _schedules;
  final WorkoutRepository _workouts;
  final StartSession _starts;
  final TimezoneService _timezones;
  final Clock _clock;

  StreamSubscription<Result<List<ScheduledWorkout>>>? _weekSubscription;
  int _watchGeneration = 0;

  WorkoutRepository get workoutRepository => _workouts;

  /// Begins watching the current week. Safe to call once after construction.
  void initialize() {
    _subscribeToWeek(state.weekStart);
  }

  void selectDay(CalendarDate date) {
    emit(state.copyWith(selectedDate: date, clearFailureMessage: true));
  }

  void goToPreviousWeek() => setWeekStart(state.weekStart.addDays(-7));

  void goToNextWeek() => setWeekStart(state.weekStart.addDays(7));

  void setWeekStart(CalendarDate weekStart) {
    final selected = _clampSelectedToWeek(state.selectedDate, weekStart);
    emit(
      state.copyWith(
        weekStart: weekStart,
        selectedDate: selected,
        loadPhase: PlannerLoadPhase.loading,
        clearFailureMessage: true,
      ),
    );
    _subscribeToWeek(weekStart);
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
    final entry = state.weekEntries.where((e) => e.id == entryId).firstOrNull;
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

  void _subscribeToWeek(CalendarDate weekStart) {
    final generation = ++_watchGeneration;
    unawaited(_weekSubscription?.cancel());
    _weekSubscription = _schedules
        .watchRange(
          startInclusive: weekStart,
          endExclusive: weekStart.addDays(7),
        )
        .listen(
          (result) {
            if (isClosed || generation != _watchGeneration) return;
            switch (result) {
              case Ok(:final value):
                emit(
                  state.copyWith(
                    loadPhase: PlannerLoadPhase.ready,
                    weekEntries: value,
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

  static CalendarDate _clampSelectedToWeek(
    CalendarDate selected,
    CalendarDate weekStart,
  ) {
    final end = weekStart.addDays(7);
    if (selected >= weekStart && selected < end) {
      return selected;
    }
    return weekStart;
  }

  @override
  Future<void> close() async {
    await _weekSubscription?.cancel();
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

/// Computes the week-start [CalendarDate] containing [today] for a locale
/// first-day index (`MaterialLocalizations.firstDayOfWeekIndex`: 0=Sun…6=Sat).
CalendarDate weekStartFor({
  required CalendarDate today,
  required int firstDayOfWeekIndex,
}) {
  // Dart DateTime.weekday: Mon=1…Sun=7. Convert today to the same 0=Sun…6=Sat.
  final dartWeekday = DateTime.utc(today.year, today.month, today.day).weekday;
  final todayIndex = dartWeekday % 7; // Sun=0, Mon=1, … Sat=6
  final delta = (todayIndex - firstDayOfWeekIndex + 7) % 7;
  return today.addDays(-delta);
}
