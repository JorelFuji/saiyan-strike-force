import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/completed_session_summary.dart';
import '../../domain/models/mass.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import 'history_list_state.dart';

final class HistoryListCubit extends Cubit<HistoryListState> {
  HistoryListCubit({
    required SessionRepository sessionRepository,
    required SettingsRepository settingsRepository,
  }) : _sessions = sessionRepository,
       _settings = settingsRepository,
       super(const HistoryListState());

  final SessionRepository _sessions;
  final SettingsRepository _settings;

  StreamSubscription<Result<List<CompletedSessionSummary>>>? _subscription;

  Future<void> initialize() async {
    unawaited(_subscription?.cancel());
    _subscription = null;

    emit(
      state.copyWith(
        loadPhase: HistoryListLoadPhase.loading,
        clearFailureMessage: true,
      ),
    );

    final unitResult = await _settings.readOrCreateDisplayMassUnit();
    if (isClosed) return;
    if (unitResult case Err(:final failure)) {
      emit(
        state.copyWith(
          loadPhase: HistoryListLoadPhase.failure,
          failureMessage: failure.message,
        ),
      );
      return;
    }
    final unit = (unitResult as Ok<MassUnit>).value;
    emit(state.copyWith(massUnit: unit));

    _subscription = _sessions.watchCompletedSummaries().listen(
      _onSummaries,
      onError: (Object error, StackTrace stack) {
        _onSummaries(
          Err(
            StorageFailure(
              'Unable to read completed sessions.',
              cause: error,
              stackTrace: stack,
            ),
          ),
        );
      },
    );
  }

  Future<void> retry() => initialize();

  void setNameQuery(String query) {
    emit(
      _applyFilters(state.copyWith(nameQuery: query), allowPhaseChange: false),
    );
  }

  void setDateRange({CalendarDate? start, CalendarDate? end}) {
    emit(
      _applyFilters(
        state.copyWith(
          startDate: start,
          clearStartDate: start == null,
          endDate: end,
          clearEndDate: end == null,
        ),
        allowPhaseChange: false,
      ),
    );
  }

  void clearDateRange() {
    emit(
      _applyFilters(
        state.copyWith(clearStartDate: true, clearEndDate: true),
        allowPhaseChange: false,
      ),
    );
  }

  void _onSummaries(Result<List<CompletedSessionSummary>> result) {
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          _applyFilters(
            state.copyWith(allSummaries: value, clearFailureMessage: true),
            allowPhaseChange: true,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            loadPhase: HistoryListLoadPhase.failure,
            failureMessage: failure.message,
          ),
        );
    }
  }

  HistoryListState _applyFilters(
    HistoryListState base, {
    required bool allowPhaseChange,
  }) {
    final query = base.nameQuery.trim().toLowerCase();
    final filtered = [
      for (final summary in base.allSummaries)
        if (_matches(summary, query, base.startDate, base.endDate)) summary,
    ];
    // Filter edits during loading/failure must not pretend the list is empty.
    if (!allowPhaseChange &&
        (base.loadPhase == HistoryListLoadPhase.loading ||
            base.loadPhase == HistoryListLoadPhase.failure)) {
      return base.copyWith(filteredSummaries: filtered);
    }
    return base.copyWith(
      filteredSummaries: filtered,
      loadPhase: filtered.isEmpty
          ? HistoryListLoadPhase.empty
          : HistoryListLoadPhase.ready,
    );
  }

  static bool _matches(
    CompletedSessionSummary summary,
    String queryLower,
    CalendarDate? start,
    CalendarDate? end,
  ) {
    if (queryLower.isNotEmpty &&
        !summary.workoutNameSnapshot.toLowerCase().contains(queryLower)) {
      return false;
    }
    if (start != null && summary.startedOn < start) {
      return false;
    }
    if (end != null && summary.startedOn > end) {
      return false;
    }
    return true;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
