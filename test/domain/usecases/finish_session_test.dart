import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/session_status.dart';
import 'package:vulcan_fitness/domain/usecases/finish_session.dart';

import '../../support/fake_session_repository.dart';

void main() {
  FinishSessionCommand command() => (FinishSessionCommand.create(
    sessionId: 3,
    currentStatus: SessionStatus.running,
    endedAt: DateTime.utc(2026, 9, 26, 18),
  ) as Ok<FinishSessionCommand>).value;

  test('delegates once and returns success', () async {
    final repository = FakeSessionRepository();
    expect(await FinishSession(repository).call(command()), isA<Ok<void>>());
    expect(repository.finishCalls, 1);
  });

  test('propagates not found, validation, and storage failures', () async {
    for (final failure in [
      const NotFoundFailure('missing'),
      const ValidationFailure('illegal'),
      const StorageFailure('write failed'),
    ]) {
      final repository = FakeSessionRepository()
        ..finishResult = Err<void>(failure);
      expect(await FinishSession(repository).call(command()), isA<Err<void>>());
      expect(repository.finishCalls, 1);
    }
  });
}
