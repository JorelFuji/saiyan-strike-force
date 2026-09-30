import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/workout_template.dart';
import '../../domain/repositories/workout_repository.dart';
import 'workout_list_state.dart';

final class WorkoutListCubit extends Cubit<WorkoutListState> {
  WorkoutListCubit({required WorkoutRepository workoutRepository})
    : _workouts = workoutRepository,
      super(WorkoutListState());

  final WorkoutRepository _workouts;
  StreamSubscription<Result<List<WorkoutTemplate>>>? _subscription;

  Future<void> initialize({bool force = false}) async {
    if (_subscription != null && !force) return;
    await _subscription?.cancel();
    _subscription = null;
    if (isClosed) return;
    emit(
      state.copyWith(
        loadPhase: WorkoutListLoadPhase.loading,
        clearFailure: true,
      ),
    );
    _subscription = _workouts
        .watchAll(includeArchived: true)
        .listen(
          _onTemplates,
          onError: (Object error, StackTrace stack) => _onTemplates(
            Err(
              StorageFailure(
                'Unable to load workout templates.',
                cause: error,
                stackTrace: stack,
              ),
            ),
          ),
        );
  }

  Future<void> retryLoad() => initialize(force: true);

  void setFilter(WorkoutListFilter filter) =>
      emit(state.copyWith(filter: filter));
  void setQuery(String query) => emit(state.copyWith(query: query.trim()));

  Future<void> archive(int id) => _run(id, WorkoutTemplateAction.archive);
  Future<void> restore(int id) => _run(id, WorkoutTemplateAction.restore);

  Future<void> retry() async {
    final id = state.retryTemplateId;
    final action = state.retryAction;
    if (id == null || action == null) return;
    await _run(id, action);
  }

  void consumePostCommitArchive() {
    if (state.postCommitArchiveId != null) {
      emit(state.copyWith(clearPostCommitArchive: true));
    }
  }

  Future<void> _run(int id, WorkoutTemplateAction action) async {
    if (state.pendingTemplateId != null) return;
    emit(
      state.copyWith(
        pendingTemplateId: id,
        pendingAction: action,
        clearFailure: true,
        clearRetry: true,
      ),
    );
    final result = action == WorkoutTemplateAction.archive
        ? await _workouts.archive(id)
        : await _workouts.restore(id);
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(
          state.copyWith(
            clearPending: true,
            postCommitArchiveId: action == WorkoutTemplateAction.archive
                ? id
                : null,
            clearPostCommitArchive: action == WorkoutTemplateAction.restore,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            clearPending: true,
            failureMessage: failure.message,
            retryTemplateId: id,
            retryAction: action,
          ),
        );
    }
  }

  void _onTemplates(Result<List<WorkoutTemplate>> result) {
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            loadPhase: WorkoutListLoadPhase.ready,
            templates: value,
            clearFailure: true,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            loadPhase: WorkoutListLoadPhase.failure,
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
