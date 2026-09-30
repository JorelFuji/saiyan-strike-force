import 'package:sqlite3/sqlite3.dart';

import '../../core/failure.dart';

/// Bounded retry for SQLite contention failures during session writes.
final class SessionStorageRetry {
  SessionStorageRetry({
    this.maxAttempts = 3,
    bool Function(Object error)? isSqliteContention,
    Future<void> Function(Duration delay)? onBackoff,
    this.runnerForTesting,
  }) : _isContention = isSqliteContention ?? _defaultIsContention,
       _onBackoff = onBackoff ?? _immediateBackoff;

  final int maxAttempts;
  final bool Function(Object error) _isContention;
  final Future<void> Function(Duration delay) _onBackoff;
  final Future<T> Function<T>(Future<T> Function() action)? runnerForTesting;

  Future<T> run<T>(Future<T> Function() action) async {
    if (runnerForTesting != null) {
      return runnerForTesting!(action);
    }
    Object? lastError;
    StackTrace? lastStack;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await action();
      } on Object catch (error, stack) {
        lastError = error;
        lastStack = stack;
        if (!_isContention(error) || attempt == maxAttempts) {
          if (_isContention(error)) {
            throw StorageFailure(
              'Session storage remained busy after bounded retries.',
              cause: error,
              stackTrace: stack,
            );
          }
          rethrow;
        }
        await _onBackoff(Duration(milliseconds: 5 * attempt));
      }
    }
    throw StorageFailure(
      'Session storage remained busy after bounded retries.',
      cause: lastError,
      stackTrace: lastStack,
    );
  }

  static bool _defaultIsContention(Object error) =>
      error is SqliteException &&
      (error.resultCode == SqlError.SQLITE_BUSY ||
          error.resultCode == SqlError.SQLITE_LOCKED);

  static Future<void> _immediateBackoff(Duration _) async {}
}
