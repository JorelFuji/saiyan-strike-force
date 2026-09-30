import '../../core/failure.dart';
import '../../core/result.dart';
import 'calendar_date.dart';
import 'exercise_name.dart';

/// Validated list projection for one finished session.
///
/// [startedOn] must already be derived in the session's captured IANA zone
/// (data layer). Domain does not import the timezone package.
///
/// [absoluteVolumeMilligramReps] is the integer sum of
/// `actual_weight_canonical_mg * actual_target_reps` for completed absolute×fixed
/// sets only. UI converts that milligram-rep total into the current mass unit
/// for display; stored milligrams are never rewritten.
final class CompletedSessionSummary {
  const CompletedSessionSummary._({
    required this.id,
    required this.workoutNameSnapshot,
    required this.startedOn,
    required this.startedAt,
    required this.endedAt,
    required this.timezone,
    required this.completedSetCount,
    required this.totalSetCount,
    required this.absoluteVolumeMilligramReps,
  });

  final int id;
  final String workoutNameSnapshot;
  final CalendarDate startedOn;
  final DateTime startedAt;
  final DateTime endedAt;
  final String timezone;
  final int completedSetCount;
  final int totalSetCount;
  final int absoluteVolumeMilligramReps;

  /// Wall-clock duration from [startedAt] to [endedAt].
  Duration get duration => endedAt.difference(startedAt);

  /// Completion label such as `18/20`.
  String get completionLabel => '$completedSetCount/$totalSetCount';

  static Result<CompletedSessionSummary> create({
    required int id,
    required String workoutNameSnapshot,
    required CalendarDate startedOn,
    required DateTime startedAt,
    required DateTime endedAt,
    required String timezone,
    required int completedSetCount,
    required int totalSetCount,
    required int absoluteVolumeMilligramReps,
  }) {
    if (id < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    final display = validateDisplayName(workoutNameSnapshot);
    if (display case Err(:final failure)) {
      return Err(failure);
    }
    final normalizedTimezone = timezone.trim();
    if (!_isTimezoneIdentifier(normalizedTimezone)) {
      return const Err(
        ValidationFailure(
          'Timezone must be a nonblank IANA timezone identifier.',
        ),
      );
    }
    final startedAtUtc = startedAt.toUtc();
    final endedAtUtc = endedAt.toUtc();
    if (endedAtUtc.isBefore(startedAtUtc)) {
      return const Err(
        ValidationFailure('Session end must not be before start.'),
      );
    }
    if (completedSetCount < 0 || totalSetCount < 0) {
      return const Err(ValidationFailure('Set counts must not be negative.'));
    }
    if (completedSetCount > totalSetCount) {
      return const Err(
        ValidationFailure('Completed sets cannot exceed total sets.'),
      );
    }
    if (absoluteVolumeMilligramReps < 0) {
      return const Err(
        ValidationFailure('Absolute volume must not be negative.'),
      );
    }
    return Ok(
      CompletedSessionSummary._(
        id: id,
        workoutNameSnapshot: (display as Ok<String>).value,
        startedOn: startedOn,
        startedAt: startedAtUtc,
        endedAt: endedAtUtc,
        timezone: normalizedTimezone,
        completedSetCount: completedSetCount,
        totalSetCount: totalSetCount,
        absoluteVolumeMilligramReps: absoluteVolumeMilligramReps,
      ),
    );
  }
}

bool _isTimezoneIdentifier(String value) {
  if (value == 'UTC' || value == 'GMT') return true;
  if (!value.contains('/')) return false;
  return value
      .split('/')
      .every(
        (part) =>
            part.isNotEmpty &&
            part != '.' &&
            part != '..' &&
            RegExp(r'^[A-Za-z0-9._+-]+$').hasMatch(part),
      );
}
