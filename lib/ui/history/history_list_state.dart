import '../../domain/models/calendar_date.dart';
import '../../domain/models/completed_session_summary.dart';
import '../../domain/models/mass.dart';

enum HistoryListLoadPhase { loading, ready, empty, failure }

final class HistoryListState {
  const HistoryListState({
    this.loadPhase = HistoryListLoadPhase.loading,
    this.allSummaries = const [],
    this.filteredSummaries = const [],
    this.massUnit = MassUnit.kg,
    this.nameQuery = '',
    this.startDate,
    this.endDate,
    this.failureMessage,
  });

  final HistoryListLoadPhase loadPhase;
  final List<CompletedSessionSummary> allSummaries;
  final List<CompletedSessionSummary> filteredSummaries;
  final MassUnit massUnit;
  final String nameQuery;
  final CalendarDate? startDate;
  final CalendarDate? endDate;
  final String? failureMessage;

  /// Groups [filteredSummaries] by [CompletedSessionSummary.startedOn],
  /// newest date first. Within a day, stream order (`started_at DESC`) is kept.
  List<HistoryDateGroup> get dateGroups {
    final groups = <CalendarDate, List<CompletedSessionSummary>>{};
    final order = <CalendarDate>[];
    for (final summary in filteredSummaries) {
      final existing = groups[summary.startedOn];
      if (existing == null) {
        groups[summary.startedOn] = [summary];
        order.add(summary.startedOn);
      } else {
        existing.add(summary);
      }
    }
    return [
      for (final date in order)
        HistoryDateGroup(date: date, sessions: groups[date]!),
    ];
  }

  HistoryListState copyWith({
    HistoryListLoadPhase? loadPhase,
    List<CompletedSessionSummary>? allSummaries,
    List<CompletedSessionSummary>? filteredSummaries,
    MassUnit? massUnit,
    String? nameQuery,
    CalendarDate? startDate,
    bool clearStartDate = false,
    CalendarDate? endDate,
    bool clearEndDate = false,
    String? failureMessage,
    bool clearFailureMessage = false,
  }) {
    return HistoryListState(
      loadPhase: loadPhase ?? this.loadPhase,
      allSummaries: allSummaries ?? this.allSummaries,
      filteredSummaries: filteredSummaries ?? this.filteredSummaries,
      massUnit: massUnit ?? this.massUnit,
      nameQuery: nameQuery ?? this.nameQuery,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      failureMessage: clearFailureMessage
          ? null
          : (failureMessage ?? this.failureMessage),
    );
  }
}

final class HistoryDateGroup {
  const HistoryDateGroup({required this.date, required this.sessions});

  final CalendarDate date;
  final List<CompletedSessionSummary> sessions;
}
