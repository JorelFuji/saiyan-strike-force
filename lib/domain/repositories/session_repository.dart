import '../../core/result.dart';
import '../models/active_session.dart';
import '../models/completed_session_summary.dart';
import '../models/exercise_history.dart';
import '../models/exercise_name.dart';
import '../usecases/start_session.dart';

abstract interface class SessionRepository {
  Future<Result<int>> startFromTemplate(StartSessionCommand command);

  Future<Result<int>> startFreestyle(StartFreestyleSessionCommand command);

  Future<Result<int>> addExercise(AddSessionExerciseCommand command);

  Future<Result<int>> addSet(AddSessionSetCommand command);

  Future<Result<ActiveSession>> getById(int sessionId);

  Stream<Result<ActiveSession>> watchById(int sessionId);

  /// Reactive finished-session list projections for History.
  ///
  /// Emits only `status = finished` rows, ordered by `started_at DESC, id DESC`.
  /// Metrics use left joins so zero-exercise/zero-set sessions remain visible.
  /// Corrupt row mapping yields `Err` rather than crashing the stream.
  Stream<Result<List<CompletedSessionSummary>>> watchCompletedSummaries();

  /// Reactive prior-performance rows for [exerciseName.normalized].
  ///
  /// Only finished sessions with completed sets and valid actual prescriptions
  /// are included. Corrupt mapping yields `Err` on the stream.
  Stream<Result<List<ExerciseHistoryEntry>>> watchExerciseHistory(
    ExerciseName exerciseName,
  );

  Future<Result<int?>> findResumableSessionId();

  Future<Result<void>> saveSetActualValues(SaveSetActualValuesCommand command);

  Future<Result<void>> completeSet(CompleteSetCommand command);

  Future<Result<void>> updateSessionRest(UpdateSessionRestCommand command);

  Future<Result<void>> clearSessionRest(ClearSessionRestCommand command);

  Future<Result<void>> updateSessionNotes(UpdateSessionNotesCommand command);

  Future<Result<void>> pauseSession(PauseSessionCommand command);

  Future<Result<void>> continueSession(ContinueSessionCommand command);

  Future<Result<void>> finishSession(FinishSessionCommand command);

  Future<Result<void>> abandonSession(AbandonSessionCommand command);
}
