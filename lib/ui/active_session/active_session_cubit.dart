import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/clock.dart';
import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/active_session.dart';
import '../../domain/models/session_status.dart';
import '../../domain/rest/rest_notification_mapping.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/services/notification_service.dart';
import 'active_session_state.dart';
import 'set_draft.dart';
import 'superset_rounds.dart';

final class ActiveSessionCubit extends Cubit<ActiveSessionState> {
  ActiveSessionCubit({
    required this.sessionId,
    required SessionRepository sessionRepository,
    required SettingsRepository settingsRepository,
    required NotificationService notificationService,
    required this.clock,
  }) : _sessions = sessionRepository,
       _settings = settingsRepository,
       _notifications = notificationService,
       super(const ActiveSessionState());

  final int sessionId;
  final SessionRepository _sessions;
  final SettingsRepository _settings;
  final NotificationService _notifications;
  final Clock clock;

  StreamSubscription<Result<ActiveSession>>? _subscription;
  final Map<int, Future<void>> _inFlightBySetId = {};
  Timer? _restUiTimer;
  bool _restAutoStart = true;
  var _requestedNotificationPermission = false;
  var _notificationsPermitted = true;
  var _promptedExactAlarmSettings = false;
  DateTime? _lastScheduledRestTarget;

  Future<void> initialize() async {
    await _subscription?.cancel();
    _subscription = null;

    final unitResult = await _settings.readOrCreateDisplayMassUnit();
    if (isClosed) {
      return;
    }
    if (unitResult case Err(:final failure)) {
      _emit(
        state.copyWith(
          loadPhase: ActiveSessionLoadPhase.initialError,
          initialReadMessage: failure.message,
        ),
      );
      return;
    }
    final unit = (unitResult as Ok).value;

    final autoStartResult = await _settings.readOrCreateRestAutoStart();
    if (isClosed) {
      return;
    }
    if (autoStartResult case Err(:final failure)) {
      _emit(
        state.copyWith(
          loadPhase: ActiveSessionLoadPhase.initialError,
          initialReadMessage: failure.message,
        ),
      );
      return;
    }
    _restAutoStart = (autoStartResult as Ok<bool>).value;

    _emit(state.copyWith(massUnit: unit));

    _subscription = _sessions
        .watchById(sessionId)
        .listen(
          _onSessionEvent,
          onError: (_) => _onSessionEvent(
            const Err(StorageFailure('Unable to read session.')),
          ),
        );
  }

  void _onSessionEvent(Result<ActiveSession> result) {
    if (isClosed) {
      return;
    }
    switch (result) {
      case Ok(:final value):
        final previousRest = state.session?.rest;
        final merged = _mergeSession(value);
        _syncRestUiTimer(merged);
        _emit(
          merged.copyWith(
            loadPhase: ActiveSessionLoadPhase.ready,
            clearStreamReadMessage: true,
          ),
        );
        if (previousRest != null && value.rest == null) {
          unawaited(_cancelRestNotification());
        }
        if (value.rest case final rest?) {
          unawaited(_reconcileRestNotification(rest, value.timezone));
        }
      case Err(:final failure):
        if (!state.hasCommittedSession) {
          _emit(
            state.copyWith(
              loadPhase: ActiveSessionLoadPhase.initialError,
              initialReadMessage: failure.message,
            ),
          );
        } else {
          _emit(state.copyWith(streamReadMessage: failure.message));
        }
    }
  }

  void _syncRestUiTimer(ActiveSessionState next) {
    if (next.hasArmedRest) {
      _restUiTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (isClosed) {
          return;
        }
        _emit(state.copyWith(restUiTick: state.restUiTick + 1));
      });
    } else {
      _restUiTimer?.cancel();
      _restUiTimer = null;
    }
  }

  ActiveSessionState _mergeSession(ActiveSession session) {
    final drafts = <int, SetDraft>{...state.drafts};
    final operations = <int, SetOperationState>{...state.operations};

    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        final setId = set.id;
        final draft = drafts[setId];
        final operation = operations[setId] ?? const SetOperationState.idle();

        if (operation.isBusy) {
          continue;
        }

        if (operation.isFailed) {
          if (draft != null && draft.matchesCommitted(set, state.massUnit)) {
            operations[setId] = const SetOperationState.idle();
            drafts[setId] = SetDraft.seed(set, state.massUnit);
          }
          continue;
        }

        if (draft == null || !draft.dirty) {
          drafts[setId] = SetDraft.seed(set, state.massUnit);
        }
      }
    }

    return state.copyWith(
      session: session,
      drafts: drafts,
      operations: operations,
    );
  }

  void updateDraft(int setId, SetDraft draft) {
    _emit(
      state.copyWith(
        drafts: {...state.drafts, setId: draft.copyWith(dirty: true)},
        operations: _clearFailedOperation(setId),
      ),
    );
  }

  Map<int, SetOperationState> _clearFailedOperation(int setId) {
    final operation = state.operations[setId];
    if (operation?.isFailed ?? false) {
      return {...state.operations, setId: const SetOperationState.idle()};
    }
    return state.operations;
  }

  Future<void> retryInitialLoad() => initialize();

  Future<void> addExercise(AddSessionExerciseCommand command) async {
    if (!state.isSessionMutable || state.addExercise.isBusy) return;
    _emit(state.copyWith(addExercise: const SessionAdditionState.adding()));
    final result = await _sessions.addExercise(command);
    if (isClosed) return;
    switch (result) {
      case Ok():
        // The repository watch is authoritative for the inserted child graph.
        _emit(state.copyWith(addExercise: const SessionAdditionState.idle()));
      case Err(:final failure):
        _emit(
          state.copyWith(
            addExercise: SessionAdditionState.failed(
              command: command,
              failureMessage: failure.message,
            ),
          ),
        );
    }
  }

  Future<void> retryAddExercise() async {
    final command = state.addExercise.failedCommand;
    if (command != null) await addExercise(command);
  }

  Future<void> addSet(AddSessionSetCommand command) async {
    if (!state.isSessionMutable || state.addSet.isBusy) return;
    _emit(state.copyWith(addSet: const SessionAdditionState.adding()));
    final result = await _sessions.addSet(command);
    if (isClosed) return;
    switch (result) {
      case Ok():
        _emit(state.copyWith(addSet: const SessionAdditionState.idle()));
      case Err(:final failure):
        _emit(
          state.copyWith(
            addSet: SessionAdditionState.failed(
              command: command,
              failureMessage: failure.message,
            ),
          ),
        );
    }
  }

  Future<void> retryAddSet() async {
    final command = state.addSet.failedCommand;
    if (command != null) await addSet(command);
  }

  Future<void> saveSetActualValues(int setId) async {
    if (!_canMutateSet(setId)) {
      return;
    }
    final operation = state.operations[setId] ?? const SetOperationState.idle();
    if (operation.isBusy) {
      return;
    }
    if (operation.isFailed && operation.failedSave != null) {
      await _retryFailedSave(setId, operation.failedSave!);
      return;
    }

    final draft = state.drafts[setId];
    if (draft == null || !draft.dirty) {
      return;
    }

    final actualResult = draft.toActual(state.massUnit);
    if (actualResult case Err(:final failure)) {
      _emit(
        state.copyWith(
          drafts: {
            ...state.drafts,
            setId: draft.copyWith(fieldError: failure.message),
          },
        ),
      );
      return;
    }

    final commandResult = SaveSetActualValuesCommand.create(
      sessionId: sessionId,
      setId: setId,
      actual: (actualResult as Ok).value,
    );
    if (commandResult case Err(:final failure)) {
      _emitFieldError(setId, draft, failure.message);
      return;
    }
    await _runSave(setId, (commandResult as Ok).value);
  }

  Future<void> completeSet(int setId) async {
    if (!_canMutateSet(setId)) {
      return;
    }
    var operation = state.operations[setId] ?? const SetOperationState.idle();

    if (operation.kind == SetOperationKind.completing) {
      return;
    }

    if (operation.kind == SetOperationKind.saving) {
      await _inFlightBySetId[setId];
      if (isClosed) {
        return;
      }
      operation = state.operations[setId] ?? const SetOperationState.idle();
      if (operation.kind == SetOperationKind.completing) {
        return;
      }
    }

    if (operation.isFailed && operation.failedComplete != null) {
      await _retryFailedComplete(setId, operation.failedComplete!);
      return;
    }

    final draft = state.drafts[setId] ?? _draftForSet(setId);
    if (draft == null) {
      return;
    }

    final actualResult = draft.toActual(state.massUnit);
    if (actualResult case Err(:final failure)) {
      _emitFieldError(setId, draft, failure.message);
      return;
    }

    final completedAt = clock.now();
    final rest = _restForCompleteSetCommand(setId);
    final commandResult = CompleteSetCommand.create(
      sessionId: sessionId,
      setId: setId,
      actual: (actualResult as Ok).value,
      completedAt: completedAt,
      rest: rest,
    );
    if (commandResult case Err(:final failure)) {
      _emitFieldError(setId, draft, failure.message);
      return;
    }
    await _runComplete(setId, (commandResult as Ok).value);
  }

  Future<void> skipRest() async {
    await _clearRestThenCancel();
  }

  Future<void> adjustRestSeconds(int delta) async {
    final session = state.session;
    final rest = session?.rest;
    if (session == null || rest == null || !state.isSessionMutable) {
      return;
    }
    final nextDuration = rest.durationSeconds + delta;
    final nextRest = AbsoluteRestState.create(
      startedAt: rest.startedAt,
      durationSeconds: nextDuration < 0 ? 0 : nextDuration,
    );
    if (nextRest case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
      return;
    }
    await _commitRestThenNotify((nextRest as Ok).value, session.timezone);
  }

  Future<void> resetRest() async {
    final session = state.session;
    final rest = session?.rest;
    if (session == null || rest == null || !state.isSessionMutable) {
      return;
    }
    final nextRest = AbsoluteRestState.create(
      startedAt: clock.now(),
      durationSeconds: rest.durationSeconds,
    );
    if (nextRest case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
      return;
    }
    await _commitRestThenNotify((nextRest as Ok).value, session.timezone);
  }

  Future<void> retrySet(int setId) async {
    final operation = state.operations[setId];
    if (operation == null || !operation.isFailed) {
      return;
    }
    if (operation.failedSave != null) {
      await _retryFailedSave(setId, operation.failedSave!);
    } else if (operation.failedComplete != null) {
      await _retryFailedComplete(setId, operation.failedComplete!);
    }
  }

  Future<void> _retryFailedSave(
    int setId,
    SaveSetActualValuesCommand command,
  ) async {
    if (!_canMutateSet(setId)) {
      return;
    }
    if ((state.operations[setId]?.kind ?? SetOperationKind.idle) ==
        SetOperationKind.saving) {
      return;
    }
    await _runSave(setId, command);
  }

  Future<void> _retryFailedComplete(
    int setId,
    CompleteSetCommand command,
  ) async {
    if (!_canMutateSet(setId)) {
      return;
    }
    if ((state.operations[setId]?.kind ?? SetOperationKind.idle) ==
        SetOperationKind.completing) {
      return;
    }
    await _runComplete(setId, command);
  }

  Future<void> _runSave(int setId, SaveSetActualValuesCommand command) async {
    _emit(
      state.copyWith(
        operations: {
          ...state.operations,
          setId: const SetOperationState.saving(),
        },
      ),
    );

    final future = _sessions.saveSetActualValues(command);
    _inFlightBySetId[setId] = future.then((_) {});
    final result = await future;
    _inFlightBySetId.remove(setId);
    if (isClosed) {
      return;
    }

    switch (result) {
      case Ok():
        final draft = state.drafts[setId];
        _emit(
          state.copyWith(
            operations: {
              ...state.operations,
              setId: const SetOperationState.idle(),
            },
            drafts: draft == null
                ? state.drafts
                : {...state.drafts, setId: draft.copyWith(dirty: false)},
          ),
        );
      case Err(:final failure):
        _emit(
          state.copyWith(
            operations: {
              ...state.operations,
              setId: SetOperationState.failedSave(
                command: command,
                failureMessage: failure.message,
              ),
            },
          ),
        );
    }
  }

  Future<void> _runComplete(int setId, CompleteSetCommand command) async {
    _emit(
      state.copyWith(
        operations: {
          ...state.operations,
          setId: const SetOperationState.completing(),
        },
      ),
    );

    final future = _sessions.completeSet(command);
    _inFlightBySetId[setId] = future.then((_) {});
    final result = await future;
    _inFlightBySetId.remove(setId);
    if (isClosed) {
      return;
    }

    switch (result) {
      case Ok():
        final draft = state.drafts[setId];
        _emit(
          state.copyWith(
            operations: {
              ...state.operations,
              setId: const SetOperationState.idle(),
            },
            drafts: draft == null
                ? state.drafts
                : {...state.drafts, setId: draft.copyWith(dirty: false)},
          ),
        );
        final timezone = state.session?.timezone ?? 'UTC';
        final preservedRest = identical(command.rest, state.session?.rest);
        if (command.rest case final rest? when !preservedRest) {
          await _scheduleRestNotification(rest, timezone);
        } else if (!preservedRest && state.session?.rest == null) {
          await _cancelRestNotification();
        }
      case Err(:final failure):
        _emit(
          state.copyWith(
            operations: {
              ...state.operations,
              setId: SetOperationState.failedComplete(
                command: command,
                failureMessage: failure.message,
              ),
            },
          ),
        );
    }
  }

  Future<void> _commitRestThenNotify(
    AbsoluteRestState rest,
    String timezone,
  ) async {
    final commandResult = UpdateSessionRestCommand.create(
      sessionId: sessionId,
      rest: rest,
    );
    if (commandResult case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
      return;
    }
    final result = await _sessions.updateSessionRest(
      (commandResult as Ok).value,
    );
    if (isClosed) {
      return;
    }
    if (result case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
      return;
    }
    await _scheduleRestNotification(rest, timezone);
  }

  Future<void> _clearRestThenCancel() async {
    final commandResult = ClearSessionRestCommand.create(sessionId: sessionId);
    if (commandResult case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
      return;
    }
    final result = await _sessions.clearSessionRest(
      (commandResult as Ok).value,
    );
    if (isClosed) {
      return;
    }
    if (result case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
      return;
    }
    await _cancelRestNotification();
  }

  Future<void> _scheduleRestNotification(
    AbsoluteRestState rest,
    String timezone,
  ) async {
    if (!_notificationsPermitted) {
      return;
    }
    if (!_requestedNotificationPermission) {
      _requestedNotificationPermission = true;
      final permission = await _notifications.requestNotificationPermission();
      if (permission case Ok(value: final granted) when !granted) {
        _notificationsPermitted = false;
        _emit(
          state.copyWith(
            restAlertDegradedMessage: restAlertsDeniedMessage,
            clearRestAlertDegradedMessage: false,
          ),
        );
        return;
      }
    }

    var degradedExact = false;
    if (!_promptedExactAlarmSettings) {
      final exact = await _notifications.canScheduleExactAlarms();
      if (exact case Ok(value: final canExact) when !canExact) {
        final afterPrompt = await _notifications.canScheduleExactAlarms(
          openSettingsIfNeeded: true,
        );
        _promptedExactAlarmSettings = true;
        if (afterPrompt case Ok(value: final canExactAfter)
            when !canExactAfter) {
          degradedExact = true;
        }
      }
    } else {
      final exact = await _notifications.canScheduleExactAlarms();
      if (exact case Ok(value: final canExact) when !canExact) {
        degradedExact = true;
      }
    }

    final schedule = await _notifications.scheduleRestAlert(
      sessionId: sessionId,
      targetAtUtc: rest.targetAt,
      ianaTimeZone: timezone,
    );
    if (isClosed) {
      return;
    }

    if (schedule case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
      return;
    }

    _lastScheduledRestTarget = rest.targetAt;
    _emit(
      state.copyWith(
        restAlertDegradedMessage: degradedExact
            ? restExactAlarmDeniedMessage
            : null,
        clearRestAlertDegradedMessage: !degradedExact,
      ),
    );
  }

  Future<void> _reconcileRestNotification(
    AbsoluteRestState rest,
    String timezone,
  ) async {
    if (_lastScheduledRestTarget == rest.targetAt) {
      return;
    }
    await _scheduleRestNotification(rest, timezone);
  }

  Future<void> _cancelRestNotification() async {
    _lastScheduledRestTarget = null;
    final result = await _notifications.cancelRestAlert(sessionId);
    if (isClosed) {
      return;
    }
    if (result case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
    }
  }

  AbsoluteRestState? _restForCompleteSetCommand(int setId) {
    if (_restAutoStart &&
        completionEndsRound(state.session?.exercises ?? const [], setId)) {
      final context = _contextForSet(setId);
      if (context == null) {
        return state.session?.rest;
      }
      final restResult = AbsoluteRestState.create(
        startedAt: clock.now(),
        durationSeconds:
            context.set.plannedRestSeconds ??
            context.exercise.plannedRestSeconds,
      );
      if (restResult case Ok(:final value)) {
        return value;
      }
      return state.session?.rest;
    }
    // Preserve an already-armed rest when auto-start is off; null would clear it.
    return state.session?.rest;
  }

  ({SessionExerciseSnapshot exercise, SessionSetSnapshot set})? _contextForSet(
    int setId,
  ) {
    for (final exercise in state.session?.exercises ?? const []) {
      for (final set in exercise.sets) {
        if (set.id == setId) {
          return (exercise: exercise, set: set);
        }
      }
    }
    return null;
  }

  Future<void> pause() async {
    final session = state.session;
    if (session == null || session.status != SessionStatus.running) {
      return;
    }
    final commandResult = PauseSessionCommand.create(
      sessionId: sessionId,
      currentStatus: session.status,
    );
    if (commandResult case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
      return;
    }
    final result = await _sessions.pauseSession((commandResult as Ok).value);
    if (isClosed) {
      return;
    }
    if (result case Ok()) {
      await _cancelRestNotification();
    } else if (result case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
    }
  }

  Future<void> continueSession() async {
    final session = state.session;
    if (session == null || session.status != SessionStatus.paused) {
      return;
    }
    final commandResult = ContinueSessionCommand.create(
      sessionId: sessionId,
      currentStatus: session.status,
    );
    if (commandResult case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
      return;
    }
    final result = await _sessions.continueSession((commandResult as Ok).value);
    if (isClosed) {
      return;
    }
    if (result case Err(:final failure)) {
      _emit(state.copyWith(streamReadMessage: failure.message));
    }
  }

  Future<void> finish() async {
    final session = state.session;
    if (session == null || !state.isSessionMutable) {
      return;
    }
    if (state.finishPending) {
      return;
    }
    _emit(state.copyWith(finishPending: true, clearFinishSucceeded: true));

    final commandResult = FinishSessionCommand.create(
      sessionId: sessionId,
      currentStatus: session.status,
      endedAt: clock.now(),
    );
    if (commandResult case Err(:final failure)) {
      _emit(
        state.copyWith(
          finishPending: false,
          streamReadMessage: failure.message,
        ),
      );
      return;
    }

    final result = await _sessions.finishSession((commandResult as Ok).value);
    if (isClosed) {
      return;
    }
    switch (result) {
      case Ok():
        await _cancelRestNotification();
        _emit(state.copyWith(finishPending: false, finishSucceeded: true));
      case Err(:final failure):
        _emit(
          state.copyWith(
            finishPending: false,
            streamReadMessage: failure.message,
          ),
        );
    }
  }

  bool _canMutateSet(int setId) {
    if (!state.isSessionMutable) {
      return false;
    }
    return _draftForSet(setId) != null;
  }

  SetDraft? _draftForSet(int setId) {
    final draft = state.drafts[setId];
    if (draft != null) {
      return draft;
    }
    final set = _findSet(setId);
    if (set == null) {
      return null;
    }
    return SetDraft.seed(set, state.massUnit);
  }

  SessionSetSnapshot? _findSet(int setId) {
    for (final exercise in state.session?.exercises ?? const []) {
      for (final set in exercise.sets) {
        if (set.id == setId) {
          return set;
        }
      }
    }
    return null;
  }

  void _emitFieldError(int setId, SetDraft draft, String message) {
    _emit(
      state.copyWith(
        drafts: {
          ...state.drafts,
          setId: draft.copyWith(fieldError: message),
        },
      ),
    );
  }

  void _emit(ActiveSessionState next) {
    if (!isClosed) {
      emit(next);
    }
  }

  @override
  Future<void> close() async {
    _restUiTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
