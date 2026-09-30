import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/usecases/start_session.dart';

import '../../support/fake_session_repository.dart';

void main() {
  test(
    'validates, normalizes UTC, delegates once, and returns result',
    () async {
      final repository = FakeSessionRepository();
      final command = (StartSessionCommand.create(
        workoutId: 7,
        scheduleEntryId: 4,
        startedAt: DateTime(2026, 9, 26, 10),
        timezone: ' America/Denver ',
      ) as Ok<StartSessionCommand>).value;
      expect(command.startedAt.isUtc, isTrue);
      expect(command.timezone, 'America/Denver');
      expect(
        (await StartSession(repository).call(command) as Ok<int>).value,
        42,
      );
      expect(repository.startCalls, 1);
    },
  );

  test('rejects invalid command before repository call', () {
    final repository = FakeSessionRepository();
    for (final invalid in [
      StartSessionCommand.create(
        workoutId: 0,
        startedAt: DateTime.now(),
        timezone: 'UTC',
      ),
      StartSessionCommand.create(
        workoutId: 1,
        scheduleEntryId: 0,
        startedAt: DateTime.now(),
        timezone: 'UTC',
      ),
      StartSessionCommand.create(
        workoutId: 1,
        startedAt: DateTime.now(),
        timezone: '  ',
      ),
      StartSessionCommand.create(
        workoutId: 1,
        startedAt: DateTime.now(),
        timezone: 'not-a-zone',
      ),
    ]) {
      expect(invalid, isA<Err<StartSessionCommand>>());
    }
    expect(repository.startCalls, 0);
  });

  test('preserves repository failure', () async {
    final repository = FakeSessionRepository()
      ..startResult = const Err<int>(NotFoundFailure('missing'));
    final command = (StartSessionCommand.create(
      workoutId: 1,
      startedAt: DateTime.now(),
      timezone: 'UTC',
    ) as Ok<StartSessionCommand>).value;
    expect(await StartSession(repository).call(command), isA<Err<int>>());
    expect(repository.startCalls, 1);
  });

  test('preserves storage failure', () async {
    final repository = FakeSessionRepository()
      ..startResult = const Err<int>(StorageFailure('write failed'));
    final command = (StartSessionCommand.create(
      workoutId: 1,
      startedAt: DateTime.now(),
      timezone: 'UTC',
    ) as Ok<StartSessionCommand>).value;
    expect(await StartSession(repository).call(command), isA<Err<int>>());
    expect(repository.startCalls, 1);
  });

  test('validates and delegates a UTC-normalized freestyle start', () async {
    final repository = FakeSessionRepository();
    final command = (StartFreestyleSessionCommand.create(
      startedAt: DateTime(2026, 9, 29, 10),
      timezone: ' America/Denver ',
    ) as Ok<StartFreestyleSessionCommand>).value;
    expect(command.startedAt.isUtc, isTrue);
    expect(command.timezone, 'America/Denver');
    expect(
      await StartSession(repository).startFreestyle(command),
      isA<Ok<int>>(),
    );
    expect(repository.startFreestyleCalls, 1);
    expect(repository.startCalls, 0);
    expect(
      StartFreestyleSessionCommand.create(
        startedAt: DateTime.now(),
        timezone: 'not-a-zone',
      ),
      isA<Err<StartFreestyleSessionCommand>>(),
    );
  });
}
