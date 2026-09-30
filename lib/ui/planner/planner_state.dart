import '../../domain/models/calendar_date.dart';
import '../../domain/models/schedule_status.dart';
import '../../domain/models/scheduled_workout.dart';

enum PlannerLoadPhase { loading, ready, error }

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
    required this.selectedDate,
    required this.today,
    this.weekEntries = const [],
    this.actionPending = false,
    this.startPendingEntryId,
    this.failureMessage,
    this.startedSessionId,
    this.copySuccessCount,
  });

  final PlannerLoadPhase loadPhase;
  final CalendarDate weekStart;
  final CalendarDate selectedDate;
  final CalendarDate today;
  final List<ScheduledWorkout> weekEntries;
  final bool actionPending;
  final int? startPendingEntryId;
  final String? failureMessage;
  final int? startedSessionId;
  final int? copySuccessCount;

  CalendarDate get weekEndExclusive => weekStart.addDays(7);

  List<CalendarDate> get weekDays => [
    for (var offset = 0; offset < 7; offset++) weekStart.addDays(offset),
  ];

  List<PlannerEntryView> get selectedDayEntries {
    return [
      for (final entry in weekEntries)
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
      weekEntries.where((entry) => entry.date == date).length;

  PlannerState copyWith({
    PlannerLoadPhase? loadPhase,
    CalendarDate? weekStart,
    CalendarDate? selectedDate,
    CalendarDate? today,
    List<ScheduledWorkout>? weekEntries,
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
      selectedDate: selectedDate ?? this.selectedDate,
      today: today ?? this.today,
      weekEntries: weekEntries ?? this.weekEntries,
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
