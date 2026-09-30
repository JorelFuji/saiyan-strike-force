import '../../core/result.dart';
import '../models/calendar_date.dart';
import '../models/scheduled_workout.dart';

/// Persistence boundary for weekly/monthly schedule planning.
///
/// Range watches are half-open: `date >= startInclusive` and
/// `date < endExclusive`, ordered by date ascending, then `start_time`
/// ascending (SQLite `ASC` places `NULL` first), then `id` ascending.
///
/// UI "missed" is never returned as a wire status — the Cubit derives it from
/// `planned` entries whose calendar date is before local today.
abstract interface class ScheduleRepository {
  Stream<Result<List<ScheduledWorkout>>> watchRange({
    required CalendarDate startInclusive,
    required CalendarDate endExclusive,
  });

  Future<Result<ScheduledWorkout>> add(ScheduleDraft draft);

  Future<Result<void>> move(int entryId, CalendarDate date);

  Future<Result<void>> setSkipped(int entryId, {required bool skipped});
}
