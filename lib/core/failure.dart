/// A typed, expected failure exposed at an application boundary.
sealed class Failure {
  const Failure(this.message, {this.cause, this.stackTrace});

  /// A safe description suitable for the receiving layer to interpret.
  final String message;

  /// The original error when one exists; it is not persisted or shown directly.
  final Object? cause;

  /// The original stack trace when one exists.
  final StackTrace? stackTrace;
}

/// A failure while reading or writing durable application data.
final class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.cause, super.stackTrace});
}

/// A failure that prevents encrypted storage from being safely opened or used.
final class EncryptionFailure extends Failure {
  const EncryptionFailure(super.message, {super.cause, super.stackTrace});
}

/// A failure caused by invalid input or untrusted persisted data.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause, super.stackTrace});
}

/// A requested durable entity does not exist.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.cause, super.stackTrace});
}

/// A failure caused by a missing operating-system permission.
final class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.cause, super.stackTrace});
}
