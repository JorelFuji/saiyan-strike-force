import '../../core/failure.dart';
import '../../core/result.dart';
import 'calendar_date.dart';
import 'local_start_time.dart';
import 'schedule_status.dart';

/// Create payload for inserting a planned schedule entry.
final class ScheduleDraft {
  const ScheduleDraft._({
    required this.workoutId,
    required this.date,
    required this.startTime,
    required this.label,
  });

  final int workoutId;
  final CalendarDate date;
  final LocalStartTime? startTime;
  final String? label;

  static Result<ScheduleDraft> create({
    required int workoutId,
    required CalendarDate date,
    LocalStartTime? startTime,
    String? label,
  }) {
    if (workoutId < 1) {
      return const Err(
        ValidationFailure('Workout identifier must be positive.'),
      );
    }
    String? normalizedLabel;
    if (label != null) {
      final trimmed = label.trim();
      if (trimmed.isEmpty) {
        normalizedLabel = null;
      } else {
        normalizedLabel = trimmed;
      }
    }
    return Ok(
      ScheduleDraft._(
        workoutId: workoutId,
        date: date,
        startTime: startTime,
        label: normalizedLabel,
      ),
    );
  }
}

/// Joined read projection of a schedule entry plus current template fields.
///
/// This is intentionally not a 1:1 `schedule_entry` row: it includes the
/// referenced workout's current name and archive flag so Planner and later
/// Today can render without composing a second stream.
final class ScheduledWorkout {
  const ScheduledWorkout._({
    required this.id,
    required this.workoutId,
    required this.date,
    required this.startTime,
    required this.label,
    required this.status,
    required this.sessionId,
    required this.workoutName,
    required this.workoutArchived,
  });

  final int id;
  final int workoutId;
  final CalendarDate date;
  final LocalStartTime? startTime;
  final String? label;
  final ScheduleStatus status;
  final int? sessionId;
  final String workoutName;
  final bool workoutArchived;

  static Result<ScheduledWorkout> create({
    required int id,
    required int workoutId,
    required CalendarDate date,
    LocalStartTime? startTime,
    String? label,
    required ScheduleStatus status,
    int? sessionId,
    required String workoutName,
    required bool workoutArchived,
  }) {
    if (id < 1 || workoutId < 1) {
      return const Err(
        ValidationFailure('Schedule identifiers must be positive.'),
      );
    }
    if (sessionId != null && sessionId < 1) {
      return const Err(
        ValidationFailure('Session identifier must be positive when set.'),
      );
    }
    final trimmedName = workoutName.trim();
    if (trimmedName.isEmpty) {
      return const Err(ValidationFailure('Workout name must not be blank.'));
    }
    String? normalizedLabel;
    if (label != null) {
      final trimmed = label.trim();
      normalizedLabel = trimmed.isEmpty ? null : trimmed;
    }
    return Ok(
      ScheduledWorkout._(
        id: id,
        workoutId: workoutId,
        date: date,
        startTime: startTime,
        label: normalizedLabel,
        status: status,
        sessionId: sessionId,
        workoutName: trimmedName,
        workoutArchived: workoutArchived,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledWorkout &&
          id == other.id &&
          workoutId == other.workoutId &&
          date == other.date &&
          startTime == other.startTime &&
          label == other.label &&
          status == other.status &&
          sessionId == other.sessionId &&
          workoutName == other.workoutName &&
          workoutArchived == other.workoutArchived;

  @override
  int get hashCode => Object.hash(
    id,
    workoutId,
    date,
    startTime,
    label,
    status,
    sessionId,
    workoutName,
    workoutArchived,
  );
}
