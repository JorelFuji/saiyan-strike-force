import 'package:timezone/timezone.dart' as tz;

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/completed_session_summary.dart';

/// Derives the session's original local calendar date from a UTC instant and
/// captured IANA zone. Unknown zones yield [ValidationFailure] — never a
/// device-local fallback.
Result<CalendarDate> calendarDateInSessionZone({
  required DateTime startedAtUtc,
  required String ianaTimezone,
}) {
  final trimmed = ianaTimezone.trim();
  if (trimmed.isEmpty) {
    return const Err(
      ValidationFailure(
        'Timezone must be a nonblank IANA timezone identifier.',
      ),
    );
  }
  try {
    final location = tz.getLocation(trimmed);
    final local = tz.TZDateTime.from(startedAtUtc.toUtc(), location);
    return CalendarDate.create(
      year: local.year,
      month: local.month,
      day: local.day,
    );
  } on Exception catch (error, stack) {
    return Err(
      ValidationFailure(
        'Unknown or invalid IANA timezone identifier.',
        cause: error,
        stackTrace: stack,
      ),
    );
  }
}

/// Maps one finished-summary SQL row into a validated domain projection.
Result<CompletedSessionSummary> mapCompletedSessionSummaryRow({
  required int id,
  required String workoutNameSnapshot,
  required DateTime startedAt,
  required DateTime? endedAt,
  required String timezone,
  required int completedSetCount,
  required int totalSetCount,
  required int absoluteVolumeMilligramReps,
}) {
  if (endedAt == null) {
    return const Err(
      ValidationFailure('Finished sessions require an end instant.'),
    );
  }
  final startedOn = calendarDateInSessionZone(
    startedAtUtc: startedAt,
    ianaTimezone: timezone,
  );
  if (startedOn case Err(:final failure)) {
    return Err(failure);
  }
  return CompletedSessionSummary.create(
    id: id,
    workoutNameSnapshot: workoutNameSnapshot,
    startedOn: (startedOn as Ok<CalendarDate>).value,
    startedAt: startedAt,
    endedAt: endedAt,
    timezone: timezone,
    completedSetCount: completedSetCount,
    totalSetCount: totalSetCount,
    absoluteVolumeMilligramReps: absoluteVolumeMilligramReps,
  );
}
