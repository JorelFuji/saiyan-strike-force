final class TodayState {
  const TodayState({
    this.startPending = false,
    this.failureMessage,
    this.startedSessionId,
  });

  final bool startPending;
  final String? failureMessage;
  final int? startedSessionId;

  TodayState copyWith({
    bool? startPending,
    String? failureMessage,
    int? startedSessionId,
    bool clearFailure = false,
    bool clearStartedSessionId = false,
  }) => TodayState(
    startPending: startPending ?? this.startPending,
    failureMessage: clearFailure
        ? null
        : (failureMessage ?? this.failureMessage),
    startedSessionId: clearStartedSessionId
        ? null
        : (startedSessionId ?? this.startedSessionId),
  );
}
