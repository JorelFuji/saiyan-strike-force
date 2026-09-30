import '../../domain/models/active_session.dart';
import '../../domain/models/mass.dart';

enum SessionDetailLoadPhase { loading, ready, notFound, failure }

final class SessionDetailState {
  const SessionDetailState({
    this.loadPhase = SessionDetailLoadPhase.loading,
    this.session,
    this.massUnit = MassUnit.kg,
    this.failureMessage,
  });

  final SessionDetailLoadPhase loadPhase;
  final ActiveSession? session;
  final MassUnit massUnit;
  final String? failureMessage;

  SessionDetailState copyWith({
    SessionDetailLoadPhase? loadPhase,
    ActiveSession? session,
    bool clearSession = false,
    MassUnit? massUnit,
    String? failureMessage,
    bool clearFailureMessage = false,
  }) {
    return SessionDetailState(
      loadPhase: loadPhase ?? this.loadPhase,
      session: clearSession ? null : (session ?? this.session),
      massUnit: massUnit ?? this.massUnit,
      failureMessage: clearFailureMessage
          ? null
          : (failureMessage ?? this.failureMessage),
    );
  }
}
