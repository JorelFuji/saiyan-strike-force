import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart'
    show
        AbandonSessionCommand,
        ContinueSessionCommand,
        FinishSessionCommand,
        PauseSessionCommand;
import 'package:vulcan_fitness/domain/models/session_status.dart';

void main() {
  test('decodes schema statuses and rejects unknown values', () {
    for (final status in SessionStatus.values) {
      expect(
        (SessionStatus.fromWire(status.wireValue) as Ok<SessionStatus>).value,
        status,
      );
    }
    expect(SessionStatus.fromWire('unknown'), isA<Err<SessionStatus>>());
  });

  test(
    'allows running and paused transitions from the active session table',
    () {
      expect(
        SessionStatus.running.validateTransitionTo(SessionStatus.paused),
        isA<Ok<SessionStatus>>(),
      );
      expect(
        SessionStatus.running.validateTransitionTo(SessionStatus.finished),
        isA<Ok<SessionStatus>>(),
      );
      expect(
        SessionStatus.running.validateTransitionTo(SessionStatus.abandoned),
        isA<Ok<SessionStatus>>(),
      );
      expect(
        SessionStatus.paused.validateTransitionTo(SessionStatus.running),
        isA<Ok<SessionStatus>>(),
      );
      expect(
        SessionStatus.paused.validateTransitionTo(SessionStatus.finished),
        isA<Ok<SessionStatus>>(),
      );
      expect(
        SessionStatus.paused.validateTransitionTo(SessionStatus.abandoned),
        isA<Ok<SessionStatus>>(),
      );
    },
  );

  test('rejects terminal, draft, and identity transitions', () {
    for (final terminal in [SessionStatus.finished, SessionStatus.abandoned]) {
      expect(
        terminal.validateTransitionTo(SessionStatus.running),
        isA<Err<SessionStatus>>(),
      );
    }
    expect(
      SessionStatus.draft.validateTransitionTo(SessionStatus.running),
      isA<Err<SessionStatus>>(),
    );
    expect(
      SessionStatus.running.validateTransitionTo(SessionStatus.running),
      isA<Err<SessionStatus>>(),
    );
  });

  test('transition commands enforce the same rules', () {
    expect(
      PauseSessionCommand.create(
        sessionId: 1,
        currentStatus: SessionStatus.running,
      ),
      isA<Ok<PauseSessionCommand>>(),
    );
    expect(
      PauseSessionCommand.create(
        sessionId: 1,
        currentStatus: SessionStatus.finished,
      ),
      isA<Err<PauseSessionCommand>>(),
    );
    expect(
      ContinueSessionCommand.create(
        sessionId: 1,
        currentStatus: SessionStatus.paused,
      ),
      isA<Ok<ContinueSessionCommand>>(),
    );
    expect(
      FinishSessionCommand.create(
        sessionId: 1,
        currentStatus: SessionStatus.running,
        endedAt: DateTime.utc(2026, 9, 26),
      ),
      isA<Ok<FinishSessionCommand>>(),
    );
    expect(
      AbandonSessionCommand.create(
        sessionId: 1,
        currentStatus: SessionStatus.paused,
        endedAt: DateTime.utc(2026, 9, 26),
      ),
      isA<Ok<AbandonSessionCommand>>(),
    );
  });
}
