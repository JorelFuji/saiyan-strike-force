import '../../core/failure.dart';
import '../../core/result.dart';

/// Persisted schedule_entry status wire values.
///
/// UI "missed" is derived in the Cubit and is never a wire status.
enum ScheduleStatus {
  planned('planned'),
  skipped('skipped'),
  completedBySession('completed_by_session');

  const ScheduleStatus(this.wireValue);
  final String wireValue;

  static Result<ScheduleStatus> fromWire(String value) => switch (value) {
    'planned' => const Ok(ScheduleStatus.planned),
    'skipped' => const Ok(ScheduleStatus.skipped),
    'completed_by_session' => const Ok(ScheduleStatus.completedBySession),
    _ => Err(ValidationFailure('Unknown schedule status: $value')),
  };
}
