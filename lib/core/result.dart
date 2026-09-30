import 'failure.dart';

/// The outcome of an operation that can fail in an expected, typed way.
sealed class Result<T> {
  const Result();
}

/// A successful [Result] containing [value].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

/// A failed [Result] containing a typed [failure].
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
