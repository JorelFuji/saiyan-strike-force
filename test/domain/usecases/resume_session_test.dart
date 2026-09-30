import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/usecases/resume_session.dart';

import '../../support/fake_session_repository.dart';

void main() {
  test('delegates once and returns resumable id', () async {
    final repository = FakeSessionRepository()..resumeResult = const Ok(9);
    expect((await ResumeSession(repository).call() as Ok<int?>).value, 9);
    expect(repository.resumeCalls, 1);
  });

  test('propagates validation and storage failures', () async {
    for (final failure in [
      const ValidationFailure('corrupt'),
      const StorageFailure('busy'),
    ]) {
      final repository = FakeSessionRepository()
        ..resumeResult = Err<int?>(failure);
      expect(await ResumeSession(repository).call(), isA<Err<int?>>());
      expect(repository.resumeCalls, 1);
    }
  });
}
