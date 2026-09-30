import '../../core/failure.dart';
import '../../core/result.dart';

/// Optional local wall-clock minutes since midnight (`0…1439`).
///
/// This is a calendar reading for a planner day, not a timezone instant.
final class LocalStartTime {
  const LocalStartTime._(this.minutesFromMidnight);

  final int minutesFromMidnight;

  static Result<LocalStartTime> create(int minutesFromMidnight) {
    if (minutesFromMidnight < 0 || minutesFromMidnight > 1439) {
      return const Err(
        ValidationFailure(
          'Start time must be minutes from midnight in 0…1439.',
        ),
      );
    }
    return Ok(LocalStartTime._(minutesFromMidnight));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalStartTime &&
          minutesFromMidnight == other.minutesFromMidnight;

  @override
  int get hashCode => minutesFromMidnight.hashCode;

  @override
  String toString() => 'LocalStartTime($minutesFromMidnight)';
}
