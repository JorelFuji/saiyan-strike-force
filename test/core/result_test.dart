import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';

void main() {
  test('Ok preserves its typed value', () {
    const result = Ok<int>(42);

    expect(result, isA<Result<int>>());
    expect(result.value, 42);
  });

  test('Err preserves its typed failure', () {
    const failure = ValidationFailure('A name is required.');
    const result = Err<String>(failure);

    expect(result, isA<Result<String>>());
    expect(result.failure, same(failure));
  });

  test('failure subtypes preserve diagnostic context', () {
    final cause = StateError('database unavailable');
    final stackTrace = StackTrace.current;
    final failures = <Failure>[
      StorageFailure(
        'Could not save the set.',
        cause: cause,
        stackTrace: stackTrace,
      ),
      EncryptionFailure(
        'The database could not be opened.',
        cause: cause,
        stackTrace: stackTrace,
      ),
      ValidationFailure(
        'The value is invalid.',
        cause: cause,
        stackTrace: stackTrace,
      ),
      PermissionFailure(
        'Notification permission was denied.',
        cause: cause,
        stackTrace: stackTrace,
      ),
    ];

    expect(failures, hasLength(4));
    for (final failure in failures) {
      expect(failure.message, isNotEmpty);
      expect(failure.cause, same(cause));
      expect(failure.stackTrace, same(stackTrace));
    }
  });
}
