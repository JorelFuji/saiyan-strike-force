import 'dart:async';

import '../../core/result.dart';
import '../../domain/models/exercise_history.dart';
import '../../domain/models/exercise_name.dart';
import '../../domain/repositories/session_repository.dart';
import 'workout_builder_state.dart';

/// Owns the builder's long-lived exercise-history stream subscriptions.
final class WorkoutHistorySubscriptions {
  WorkoutHistorySubscriptions(this._sessions, this._onChanged);

  final SessionRepository _sessions;
  final void Function(Map<String, Map<int, ExerciseHistoryCompletedSet>>)
  _onChanged;
  final Map<String, StreamSubscription<Result<List<ExerciseHistoryEntry>>>>
  _subscriptions = {};
  Map<String, Map<int, ExerciseHistoryCompletedSet>> _previous = {};
  bool _closed = false;

  void reconcile(Iterable<DraftExerciseRow> rows) {
    if (_closed) return;
    final names = rows
        .map((row) => normalizeExerciseName(row.exercise.name))
        .toSet();
    for (final name in _subscriptions.keys.toList()) {
      if (!names.contains(name)) {
        _subscriptions.remove(name)?.cancel();
        _previous = {..._previous}..remove(name);
        _publish();
      }
    }
    for (final name in names) {
      if (_subscriptions.containsKey(name)) continue;
      final lookup = ExerciseName.forLookup(name);
      if (lookup case Err()) continue;
      _subscriptions[name] = _sessions
          .watchExerciseHistory((lookup as Ok).value)
          .listen(
            (result) {
              if (_closed) return;
              final previous = {..._previous};
              switch (result) {
                case Ok(:final value) when value.isNotEmpty:
                  previous[name] = {
                    for (final set in value.first.completedSets)
                      set.setIndex: set,
                  };
                case Ok() || Err():
                  previous.remove(name);
              }
              _previous = previous;
              _publish();
            },
            onError: (_) {
              if (_closed) return;
              _previous = {..._previous}..remove(name);
              _publish();
            },
          );
    }
  }

  void _publish() => _onChanged({
    for (final item in _previous.entries) item.key: {...item.value},
  });

  Future<void> close() async {
    _closed = true;
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}
