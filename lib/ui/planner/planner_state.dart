import '../../core/result.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/schedule_status.dart';
import '../../domain/models/scheduled_workout.dart';

enum PlannerLoadPhase { loading, ready, error }

/// The planner has one operational week view and one read-only month overview.
enum PlannerViewMode { week, month }

/// A half-open, locale-aligned range of real calendar dates.
final class PlannerVisibleRange {
  const PlannerVisibleRange({
    required this.startInclusive,
    required this.endExclusive,
  });

  final CalendarDate startInclusive;
  final CalendarDate endExclusive;

  int get dayCount =>
      DateTime.utc(endExclusive.year, endExclusive.month, endExclusive.day)
          .difference(
            DateTime.utc(
              startInclusive.year,
              startInclusive.month,
              startInclusive.day,
            ),
          )
          .inDays;

  List<CalendarDate> get dates => [
    for (var offset = 0; offset < dayCount; offset++)
      startInclusive.addDays(offset),
  ];

  bool contains(CalendarDate date) =>
      date >= startInclusive && date < endExclusive;
}

/// Computes the locale week containing [date].
CalendarDate weekStartFor({
  required CalendarDate today,
  required int firstDayOfWeekIndex,
}) {
  // Dart DateTime.weekday: Mon=1…Sun=7. Convert to Sun=0…Sat=6.
  final dartWeekday = DateTime.utc(today.year, today.month, today.day).weekday;
  final todayIndex = dartWeekday % 7;
  final delta = (todayIndex - firstDayOfWeekIndex + 7) % 7;
  return today.addDays(-delta);
}

/// Computes all complete locale weeks that intersect [monthAnchor]'s month.
PlannerVisibleRange monthRangeFor({
  required CalendarDate monthAnchor,
  required int firstDayOfWeekIndex,
}) {
  final safeAnchor = monthAnchorForVisibleRange(monthAnchor);
  final firstDay = _validDate(safeAnchor.year, safeAnchor.month);
  final nextMonth = _validDate(
    firstDay.month == 12 ? firstDay.year + 1 : firstDay.year,
    firstDay.month == 12 ? 1 : firstDay.month + 1,
  );
  final start = weekStartFor(
    today: firstDay,
    firstDayOfWeekIndex: firstDayOfWeekIndex,
  );
  final end = weekStartFor(
    today: nextMonth.addDays(-1),
    firstDayOfWeekIndex: firstDayOfWeekIndex,
  ).addDays(7);
  return PlannerVisibleRange(startInclusive: start, endExclusive: end);
}

/// Clamps anchors where a full leading or trailing week cannot be represented
/// by [CalendarDate]'s 1…9999 year range.
CalendarDate monthAnchorForVisibleRange(CalendarDate anchor) {
  if (anchor.year == 1 && anchor.month == 1) return _validDate(1, 2);
  if (anchor.year == 9999 && anchor.month == 12) return _validDate(9999, 11);
  return anchor;
}

CalendarDate _validDate(int year, int month) =>
    switch (CalendarDate.create(year: year, month: month, day: 1)) {
      Ok(:final value) => value,
      Err() => throw ArgumentError('Calendar month is out of range.'),
    };

/// Display status for a schedule row. `missed` is UI-only.
enum PlannerDisplayStatus { planned, skipped, completed, missed }

final class PlannerEntryView {
  const PlannerEntryView({required this.workout, required this.displayStatus});

  final ScheduledWorkout workout;
  final PlannerDisplayStatus displayStatus;
}

final class PlannerState {
  const PlannerState({
    this.loadPhase = PlannerLoadPhase.loading,
    required this.weekStart,
    required this.monthAnchor,
    required this.firstDayOfWeekIndex,
    this.viewMode = PlannerViewMode.week,
    required this.selectedDate,
    required this.today,
    this.visibleRangeEntries = const [],
    this.actionPending = false,
    this.startPendingEntryId,
    this.failureMessage,
    this.startedSessionId,
    this.copySuccessCount,
  });

  final PlannerLoadPhase loadPhase;
  final CalendarDate weekStart;
  final CalendarDate monthAnchor;
  final int firstDayOfWeekIndex;
  final PlannerViewMode viewMode;
  final CalendarDate selectedDate;
  final CalendarDate today;
  final List<ScheduledWorkout> visibleRangeEntries;
  final bool actionPending;
  final int? startPendingEntryId;
  final String? failureMessage;
  final int? startedSessionId;
  final int? copySuccessCount;

  PlannerVisibleRange get visibleRange => switch (viewMode) {
    PlannerViewMode.week => PlannerVisibleRange(
      startInclusive: weekStart,
      endExclusive: weekStart.addDays(7),
    ),
    PlannerViewMode.month => monthRangeFor(
      monthAnchor: monthAnchor,
      firstDayOfWeekIndex: firstDayOfWeekIndex,
    ),
  };

  List<CalendarDate> get weekDays => [
    for (var offset = 0; offset < 7; offset++) weekStart.addDays(offset),
  ];

  List<PlannerEntryView> get selectedDayEntries {
    return [
      for (final entry in visibleRangeEntries)
        if (entry.date == selectedDate)
          PlannerEntryView(
            workout: entry,
            displayStatus: displayStatusFor(entry),
          ),
    ];
  }

  PlannerDisplayStatus displayStatusFor(ScheduledWorkout entry) {
    if (entry.status == ScheduleStatus.planned && entry.date < today) {
      return PlannerDisplayStatus.missed;
    }
    return switch (entry.status) {
      ScheduleStatus.planned => PlannerDisplayStatus.planned,
      ScheduleStatus.skipped => PlannerDisplayStatus.skipped,
      ScheduleStatus.completedBySession => PlannerDisplayStatus.completed,
    };
  }

  int entryCountFor(CalendarDate date) =>
      visibleRangeEntries.where((entry) => entry.date == date).length;

  PlannerState copyWith({
    PlannerLoadPhase? loadPhase,
    CalendarDate? weekStart,
    CalendarDate? monthAnchor,
    PlannerViewMode? viewMode,
    CalendarDate? selectedDate,
    CalendarDate? today,
    List<ScheduledWorkout>? visibleRangeEntries,
    bool? actionPending,
    int? startPendingEntryId,
    bool clearStartPendingEntryId = false,
    String? failureMessage,
    bool clearFailureMessage = false,
    int? startedSessionId,
    bool clearStartedSessionId = false,
    int? copySuccessCount,
    bool clearCopySuccessCount = false,
  }) {
    return PlannerState(
      loadPhase: loadPhase ?? this.loadPhase,
      weekStart: weekStart ?? this.weekStart,
      monthAnchor: monthAnchor ?? this.monthAnchor,
      firstDayOfWeekIndex: firstDayOfWeekIndex,
      viewMode: viewMode ?? this.viewMode,
      selectedDate: selectedDate ?? this.selectedDate,
      today: today ?? this.today,
      visibleRangeEntries: visibleRangeEntries ?? this.visibleRangeEntries,
      actionPending: actionPending ?? this.actionPending,
      startPendingEntryId: clearStartPendingEntryId
          ? null
          : (startPendingEntryId ?? this.startPendingEntryId),
      failureMessage: clearFailureMessage
          ? null
          : (failureMessage ?? this.failureMessage),
      startedSessionId: clearStartedSessionId
          ? null
          : (startedSessionId ?? this.startedSessionId),
      copySuccessCount: clearCopySuccessCount
          ? null
          : (copySuccessCount ?? this.copySuccessCount),
    );
  }
}
