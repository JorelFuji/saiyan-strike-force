import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/active_session.dart';
import '../../domain/repositories/session_repository.dart';

/// Serializes persistence work for an individual set without knowing UI state.
final class ActiveSessionSetOperations {
  ActiveSessionSetOperations(this._sessions);

  final SessionRepository _sessions;
  final Map<int, Future<void>> _inFlightBySetId = {};

  Future<SetOperationOutcome> save(
    int setId,
    SaveSetActualValuesCommand command,
  ) => _run(setId, () => _sessions.saveSetActualValues(command));

  Future<SetOperationOutcome> complete(int setId, CompleteSetCommand command) =>
      _run(setId, () => _sessions.completeSet(command));

  Future<void>? inFlightFor(int setId) => _inFlightBySetId[setId];

  Future<SetOperationOutcome> _run(
    int setId,
    Future<Result<void>> Function() operation,
  ) async {
    final future = operation();
    _inFlightBySetId[setId] = future.then((_) {});
    final result = await future;
    _inFlightBySetId.remove(setId);
    return switch (result) {
      Ok() => const SetOperationOutcome.success(),
      Err(:final failure) => SetOperationOutcome.failure(failure),
    };
  }
}

sealed class SetOperationOutcome {
  const SetOperationOutcome();
  const factory SetOperationOutcome.success() = SetOperationSucceeded;
  const factory SetOperationOutcome.failure(Failure failure) =
      SetOperationFailed;
}

final class SetOperationSucceeded extends SetOperationOutcome {
  const SetOperationSucceeded();
}

final class SetOperationFailed extends SetOperationOutcome {
  const SetOperationFailed(this.failure);
  final Failure failure;
}
