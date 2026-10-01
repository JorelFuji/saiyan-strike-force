import 'dart:async';

import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/completed_session_summary.dart';
import 'package:vulcan_fitness/domain/models/exercise_history.dart';
import 'package:vulcan_fitness/domain/models/exercise_name.dart';
import 'package:vulcan_fitness/domain/repositories/session_repository.dart';
import 'package:vulcan_fitness/domain/usecases/start_session.dart';

/// Hand-written fake for session workflow tests.
final class FakeSessionRepository implements SessionRepository {
  int startCalls = 0;
  int startFreestyleCalls = 0;
  int addExerciseCalls = 0;
  int addSetCalls = 0;
  int resumeCalls = 0;
  int finishCalls = 0;
  int pauseCalls = 0;
  int continueCalls = 0;
  int saveCalls = 0;
  int completeCalls = 0;
  int updateRestCalls = 0;
  int clearRestCalls = 0;
  int getByIdCalls = 0;
  int watchCompletedSummariesCalls = 0;
  int watchExerciseHistoryCalls = 0;
  final Map<String, StreamController<Result<List<ExerciseHistoryEntry>>>>
  exerciseHistoryControllers = {};
  final Map<String, int> exerciseHistoryListenCounts = {};

  Result<int> startResult = const Ok(42);
  Result<int> startFreestyleResult = const Ok(43);
  Result<int> addExerciseResult = const Ok(44);
  Result<int> addSetResult = const Ok(45);
  Result<int?> resumeResult = const Ok(null);
  Result<void> finishResult = const Ok(null);
  Result<void> pauseResult = const Ok(null);
  Result<void> continueResult = const Ok(null);
  Result<void> saveResult = const Ok(null);
  Result<void> completeResult = const Ok(null);
  Result<void> updateRestResult = const Ok(null);
  Result<void> clearRestResult = const Ok(null);
  Result<ActiveSession>? getByIdResult;
  Future<Result<int>> Function(StartSessionCommand command)?
  startFromTemplateOverride;
  Future<Result<int>> Function(StartFreestyleSessionCommand command)?
  startFreestyleOverride;

  Result<ActiveSession>? nextWatchEvent;
  final List<Result<ActiveSession>> watchSeedEvents = [];
  StreamController<Result<ActiveSession>>? watchController;
  final List<Result<List<CompletedSessionSummary>>> summarySeedEvents = [];
  Result<List<CompletedSessionSummary>>? nextSummaryEvent;
  StreamController<Result<List<CompletedSessionSummary>>>? summaryController;
  final List<Result<List<ExerciseHistoryEntry>>> exerciseHistorySeedEvents = [];
  Result<List<ExerciseHistoryEntry>>? nextExerciseHistoryEvent;
  StreamController<Result<List<ExerciseHistoryEntry>>>?
  exerciseHistoryController;
  ExerciseName? lastExerciseHistoryLookup;
  final List<SaveSetActualValuesCommand> savedCommands = [];
  final List<CompleteSetCommand> completedCommands = [];
  final List<AddSessionExerciseCommand> addedExerciseCommands = [];
  final List<AddSessionSetCommand> addedSetCommands = [];
  Completer<Result<int>>? startFreestyleCompleter;
  Completer<Result<int>>? addExerciseCompleter;
  Completer<Result<int>>? addSetCompleter;
  Completer<Result<void>>? saveCompleter;
  Completer<Result<void>>? completeCompleter;
  Completer<Result<void>>? finishCompleter;

  @override
  Future<Result<int>> startFromTemplate(StartSessionCommand command) async {
    startCalls++;
    final override = startFromTemplateOverride;
    if (override != null) {
      return override(command);
    }
    return startResult;
  }

  @override
  Future<Result<int>> startFreestyle(
    StartFreestyleSessionCommand command,
  ) async {
    startFreestyleCalls++;
    final override = startFreestyleOverride;
    if (override != null) return override(command);
    if (startFreestyleCompleter != null) return startFreestyleCompleter!.future;
    return startFreestyleResult;
  }

  @override
  Future<Result<int>> addExercise(AddSessionExerciseCommand command) async {
    addExerciseCalls++;
    addedExerciseCommands.add(command);
    if (addExerciseCompleter != null) return addExerciseCompleter!.future;
    return addExerciseResult;
  }

  @override
  Future<Result<int>> addSet(AddSessionSetCommand command) async {
    addSetCalls++;
    addedSetCommands.add(command);
    if (addSetCompleter != null) return addSetCompleter!.future;
    return addSetResult;
  }

  @override
  Future<Result<int?>> findResumableSessionId() async {
    resumeCalls++;
    return resumeResult;
  }

  @override
  Future<Result<void>> finishSession(FinishSessionCommand command) async {
    finishCalls++;
    if (finishCompleter != null) {
      return finishCompleter!.future;
    }
    return finishResult;
  }

  @override
  Future<Result<ActiveSession>> getById(int sessionId) async {
    getByIdCalls++;
    final configured = getByIdResult;
    if (configured != null) {
      return configured;
    }
    throw UnimplementedError('getById not configured');
  }

  @override
  Stream<Result<ActiveSession>> watchById(int sessionId) {
    StreamController<Result<ActiveSession>>? controller;
    controller = StreamController<Result<ActiveSession>>.broadcast(
      onListen: () {
        final active = controller;
        if (active == null || active.isClosed) {
          return;
        }
        for (final event in watchSeedEvents) {
          if (!active.isClosed) {
            active.add(event);
          }
        }
        final next = nextWatchEvent;
        if (next != null && !active.isClosed) {
          active.add(next);
        }
      },
      onCancel: () {
        scheduleMicrotask(() {
          final active = controller;
          if (active != null && !active.isClosed) {
            active.close();
          }
        });
      },
    );
    watchController = controller;
    return controller.stream;
  }

  void emitWatch(Result<ActiveSession> event) {
    final controller = watchController;
    if (controller != null && !controller.isClosed) {
      controller.add(event);
    }
  }

  @override
  Stream<Result<List<CompletedSessionSummary>>> watchCompletedSummaries() {
    watchCompletedSummariesCalls++;
    late final StreamController<Result<List<CompletedSessionSummary>>>
    controller;
    controller =
        StreamController<Result<List<CompletedSessionSummary>>>.broadcast(
          sync: true,
          onListen: () {
            for (final event in summarySeedEvents) {
              controller.add(event);
            }
            final next = nextSummaryEvent;
            if (next != null) {
              controller.add(next);
            }
          },
        );
    summaryController = controller;
    return controller.stream;
  }

  void emitSummaries(Result<List<CompletedSessionSummary>> event) {
    final controller = summaryController;
    if (controller != null && !controller.isClosed) {
      controller.add(event);
    }
  }

  @override
  Stream<Result<List<ExerciseHistoryEntry>>> watchExerciseHistory(
    ExerciseName exerciseName,
  ) {
    watchExerciseHistoryCalls++;
    lastExerciseHistoryLookup = exerciseName;
    final normalized = exerciseName.normalized;
    exerciseHistoryListenCounts[normalized] =
        (exerciseHistoryListenCounts[normalized] ?? 0) + 1;
    late final StreamController<Result<List<ExerciseHistoryEntry>>> controller;
    controller = StreamController<Result<List<ExerciseHistoryEntry>>>.broadcast(
      sync: true,
      onListen: () {
        for (final event in exerciseHistorySeedEvents) {
          controller.add(event);
        }
        final next = nextExerciseHistoryEvent;
        if (next != null) controller.add(next);
      },
      onCancel: () {
        scheduleMicrotask(() {
          if (!controller.isClosed) controller.close();
        });
      },
    );
    exerciseHistoryControllers[normalized] = controller;
    exerciseHistoryController = controller;
    return controller.stream;
  }

  void emitExerciseHistoryFor(
    String normalized,
    Result<List<ExerciseHistoryEntry>> event,
  ) {
    final controller = exerciseHistoryControllers[normalized];
    if (controller != null && !controller.isClosed) controller.add(event);
  }

  int exerciseHistoryListenCount(String normalized) =>
      exerciseHistoryListenCounts[normalized] ?? 0;

  void emitExerciseHistory(Result<List<ExerciseHistoryEntry>> event) {
    final controller = exerciseHistoryController;
    if (controller != null && !controller.isClosed) {
      controller.add(event);
    }
  }

  @override
  Future<Result<void>> saveSetActualValues(
    SaveSetActualValuesCommand command,
  ) async {
    saveCalls++;
    savedCommands.add(command);
    if (saveCompleter != null) {
      return saveCompleter!.future;
    }
    return saveResult;
  }

  @override
  Future<Result<void>> completeSet(CompleteSetCommand command) async {
    completeCalls++;
    completedCommands.add(command);
    if (completeCompleter != null) {
      return completeCompleter!.future;
    }
    return completeResult;
  }

  @override
  Future<Result<void>> updateSessionRest(
    UpdateSessionRestCommand command,
  ) async {
    updateRestCalls++;
    return updateRestResult;
  }

  @override
  Future<Result<void>> clearSessionRest(ClearSessionRestCommand command) async {
    clearRestCalls++;
    return clearRestResult;
  }

  @override
  Future<Result<void>> updateSessionNotes(UpdateSessionNotesCommand command) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> pauseSession(PauseSessionCommand command) async {
    pauseCalls++;
    return pauseResult;
  }

  @override
  Future<Result<void>> continueSession(ContinueSessionCommand command) async {
    continueCalls++;
    return continueResult;
  }

  @override
  Future<Result<void>> abandonSession(AbandonSessionCommand command) =>
      throw UnimplementedError();
}
