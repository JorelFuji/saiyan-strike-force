/// Provides the current instant for production code and deterministic tests.
abstract interface class Clock {
  /// Returns the current instant in UTC.
  DateTime now();
}

/// The production [Clock] backed by the device clock.
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

/// Signed seconds until [targetAtUtc]; negative when overdue.
int restSecondsUntil(DateTime targetAtUtc, Clock clock) {
  return targetAtUtc.difference(clock.now()).inSeconds;
}

/// Remaining fraction in `[0, 1]` for UI; `0` when overdue or zero duration.
double restRemainingFraction({
  required DateTime startedAtUtc,
  required DateTime targetAtUtc,
  required Clock clock,
}) {
  final total = targetAtUtc.difference(startedAtUtc).inSeconds;
  if (total <= 0) {
    return 0;
  }
  final remaining = restSecondsUntil(targetAtUtc, clock);
  if (remaining <= 0) {
    return 0;
  }
  return remaining / total;
}
