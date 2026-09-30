import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/exercise_history.dart';
import '../../domain/models/exercise_name.dart';
import '../../domain/models/mass.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import 'exercise_history_state.dart';

final class ExerciseHistoryCubit extends Cubit<ExerciseHistoryState> {
  ExerciseHistoryCubit({
    required ExerciseName exerciseName,
    required SessionRepository sessionRepository,
    required SettingsRepository settingsRepository,
  }) : _exerciseName = exerciseName,
       _sessions = sessionRepository,
       _settings = settingsRepository,
       super(
         ExerciseHistoryState(
           displayName: exerciseName.display,
           normalizedName: exerciseName.normalized,
         ),
       );

  final ExerciseName _exerciseName;
  final SessionRepository _sessions;
  final SettingsRepository _settings;

  StreamSubscription<Result<List<ExerciseHistoryEntry>>>? _subscription;

  Future<void> initialize() async {
    unawaited(_subscription?.cancel());
    _subscription = null;

    emit(
      state.copyWith(
        loadPhase: ExerciseHistoryLoadPhase.loading,
        clearFailureMessage: true,
      ),
    );

    final unitResult = await _settings.readOrCreateDisplayMassUnit();
    if (isClosed) return;
    if (unitResult case Err(:final failure)) {
      emit(
        state.copyWith(
          loadPhase: ExerciseHistoryLoadPhase.failure,
          failureMessage: failure.message,
        ),
      );
      return;
    }
    final unit = (unitResult as Ok<MassUnit>).value;
    emit(state.copyWith(massUnit: unit));

    _subscription = _sessions
        .watchExerciseHistory(_exerciseName)
        .listen(
          _onEntries,
          onError: (Object error, StackTrace stack) {
            _onEntries(
              Err(
                StorageFailure(
                  'Unable to read exercise history.',
                  cause: error,
                  stackTrace: stack,
                ),
              ),
            );
          },
        );
  }

  Future<void> retry() => initialize();

  void _onEntries(Result<List<ExerciseHistoryEntry>> result) {
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            entries: value,
            loadPhase: value.isEmpty
                ? ExerciseHistoryLoadPhase.empty
                : ExerciseHistoryLoadPhase.ready,
            clearFailureMessage: true,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            loadPhase: ExerciseHistoryLoadPhase.failure,
            failureMessage: failure.message,
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
