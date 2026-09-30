import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/clock.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/usecases/start_session.dart';
import 'package:vulcan_fitness/ui/today/today_cubit.dart';

import '../../support/fake_session_repository.dart';
import '../../support/fake_timezone_service.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this.instant);
  final DateTime instant;
  @override
  DateTime now() => instant;
}

void main() {
  test('starts freestyle only after committed repository result', () async {
    final sessions = FakeSessionRepository();
    final cubit = TodayCubit(
      startSession: StartSession(sessions),
      timezoneService: FakeTimezoneService(identifier: ' America/Denver '),
      clock: _FixedClock(DateTime.utc(2026, 9, 29, 12)),
    );
    addTearDown(cubit.close);
    await cubit.startFreestyle();
    expect(sessions.startFreestyleCalls, 1);
    expect(sessions.startCalls, 0);
    expect(cubit.state.startedSessionId, 43);
    expect(sessions.startFreestyleCalls, 1);
  });

  test('suppresses duplicate starts and keeps failures retryable', () async {
    final sessions = FakeSessionRepository()
      ..startFreestyleCompleter = Completer<Result<int>>();
    final cubit = TodayCubit(
      startSession: StartSession(sessions),
      timezoneService: FakeTimezoneService(),
      clock: _FixedClock(DateTime.utc(2026, 9, 29)),
    );
    addTearDown(cubit.close);
    final first = cubit.startFreestyle();
    await cubit.startFreestyle();
    expect(sessions.startFreestyleCalls, 1);
    sessions.startFreestyleCompleter!.complete(
      const Err(StorageFailure('full')),
    );
    await first;
    expect(cubit.state.failureMessage, 'full');
    sessions.startFreestyleCompleter = null;
    await cubit.startFreestyle();
    expect(cubit.state.startedSessionId, 43);
  });

  test('timezone failure never starts a session', () async {
    final sessions = FakeSessionRepository();
    final cubit = TodayCubit(
      startSession: StartSession(sessions),
      timezoneService: FakeTimezoneService()
        ..result = const Err(ValidationFailure('zone unavailable')),
      clock: _FixedClock(DateTime.utc(2026, 9, 29)),
    );
    addTearDown(cubit.close);
    await cubit.startFreestyle();
    expect(sessions.startFreestyleCalls, 0);
    expect(cubit.state.failureMessage, 'zone unavailable');
  });
}
