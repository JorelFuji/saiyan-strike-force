import '../../domain/models/active_session.dart';
import '../../domain/models/mass.dart';
import '../../domain/models/session_status.dart';
import 'set_draft.dart';

enum ActiveSessionLoadPhase { loading, ready, initialError }

enum SetOperationKind { idle, saving, completing, failed }

enum SessionAdditionKind { idle, adding, failed }

final class SessionAdditionState<T> {
  const SessionAdditionState._({
    required this.kind,
    this.failedCommand,
    this.failureMessage,
  });

  const SessionAdditionState.idle() : this._(kind: SessionAdditionKind.idle);
  const SessionAdditionState.adding()
    : this._(kind: SessionAdditionKind.adding);
  const SessionAdditionState.failed({
    required T command,
    required String failureMessage,
  }) : this._(
         kind: SessionAdditionKind.failed,
         failedCommand: command,
         failureMessage: failureMessage,
       );

  final SessionAdditionKind kind;
  final T? failedCommand;
  final String? failureMessage;
  bool get isBusy => kind == SessionAdditionKind.adding;
}

/// Per-set mutation status and optional retry command captured on failure.
final class SetOperationState {
  const SetOperationState._({
    required this.kind,
    this.failedSave,
    this.failedComplete,
    this.failureMessage,
  });

  const SetOperationState.idle() : this._(kind: SetOperationKind.idle);

  const SetOperationState.saving() : this._(kind: SetOperationKind.saving);

  const SetOperationState.completing()
    : this._(kind: SetOperationKind.completing);

  const SetOperationState.failedSave({
    required SaveSetActualValuesCommand command,
    required String failureMessage,
  }) : this._(
         kind: SetOperationKind.failed,
         failedSave: command,
         failureMessage: failureMessage,
       );

  const SetOperationState.failedComplete({
    required CompleteSetCommand command,
    required String failureMessage,
  }) : this._(
         kind: SetOperationKind.failed,
         failedComplete: command,
         failureMessage: failureMessage,
       );

  final SetOperationKind kind;
  final SaveSetActualValuesCommand? failedSave;
  final CompleteSetCommand? failedComplete;
  final String? failureMessage;

  bool get isBusy =>
      kind == SetOperationKind.saving || kind == SetOperationKind.completing;

  bool get isFailed => kind == SetOperationKind.failed;
}

final class ActiveSessionState {
  const ActiveSessionState({
    this.loadPhase = ActiveSessionLoadPhase.loading,
    this.session,
    this.massUnit = MassUnit.kg,
    this.drafts = const {},
    this.operations = const {},
    this.initialReadMessage,
    this.streamReadMessage,
    this.finishPending = false,
    this.finishSucceeded = false,
    this.restAlertDegradedMessage,
    this.restUiTick = 0,
    this.addExercise = const SessionAdditionState.idle(),
    this.addSet = const SessionAdditionState.idle(),
  });

  final ActiveSessionLoadPhase loadPhase;
  final ActiveSession? session;
  final MassUnit massUnit;
  final Map<int, SetDraft> drafts;
  final Map<int, SetOperationState> operations;
  final String? initialReadMessage;
  final String? streamReadMessage;
  final bool finishPending;
  final bool finishSucceeded;
  final String? restAlertDegradedMessage;
  final int restUiTick;
  final SessionAdditionState<AddSessionExerciseCommand> addExercise;
  final SessionAdditionState<AddSessionSetCommand> addSet;

  bool get hasCommittedSession => session != null;

  bool get hasArmedRest => session?.rest != null;

  bool get isSessionMutable {
    final status = session?.status;
    return status == SessionStatus.running || status == SessionStatus.paused;
  }

  ActiveSessionState copyWith({
    ActiveSessionLoadPhase? loadPhase,
    ActiveSession? session,
    MassUnit? massUnit,
    Map<int, SetDraft>? drafts,
    Map<int, SetOperationState>? operations,
    String? initialReadMessage,
    String? streamReadMessage,
    bool? finishPending,
    bool? finishSucceeded,
    String? restAlertDegradedMessage,
    int? restUiTick,
    SessionAdditionState<AddSessionExerciseCommand>? addExercise,
    SessionAdditionState<AddSessionSetCommand>? addSet,
    bool clearInitialReadMessage = false,
    bool clearStreamReadMessage = false,
    bool clearFinishSucceeded = false,
    bool clearRestAlertDegradedMessage = false,
  }) {
    return ActiveSessionState(
      loadPhase: loadPhase ?? this.loadPhase,
      session: session ?? this.session,
      massUnit: massUnit ?? this.massUnit,
      drafts: drafts ?? this.drafts,
      operations: operations ?? this.operations,
      initialReadMessage: clearInitialReadMessage
          ? null
          : (initialReadMessage ?? this.initialReadMessage),
      streamReadMessage: clearStreamReadMessage
          ? null
          : (streamReadMessage ?? this.streamReadMessage),
      finishPending: finishPending ?? this.finishPending,
      finishSucceeded: clearFinishSucceeded
          ? false
          : (finishSucceeded ?? this.finishSucceeded),
      restAlertDegradedMessage: clearRestAlertDegradedMessage
          ? null
          : (restAlertDegradedMessage ?? this.restAlertDegradedMessage),
      restUiTick: restUiTick ?? this.restUiTick,
      addExercise: addExercise ?? this.addExercise,
      addSet: addSet ?? this.addSet,
    );
  }
}
