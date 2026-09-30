import '../../core/failure.dart';
import '../../core/result.dart';

enum SessionStatus {
  draft('draft'),
  running('running'),
  paused('paused'),
  finished('finished'),
  abandoned('abandoned');

  const SessionStatus(this.wireValue);
  final String wireValue;

  static Result<SessionStatus> fromWire(String value) => switch (value) {
    'draft' => const Ok(SessionStatus.draft),
    'running' => const Ok(SessionStatus.running),
    'paused' => const Ok(SessionStatus.paused),
    'finished' => const Ok(SessionStatus.finished),
    'abandoned' => const Ok(SessionStatus.abandoned),
    _ => Err(ValidationFailure('Unknown session status: $value')),
  };
}

extension SessionStatusTransitions on SessionStatus {
  Result<SessionStatus> validateTransitionTo(SessionStatus target) {
    if (this == target) {
      return const Err(
        ValidationFailure('Session status is already in the target state.'),
      );
    }
    final allowed = switch (this) {
      SessionStatus.running => {
        SessionStatus.paused,
        SessionStatus.finished,
        SessionStatus.abandoned,
      },
      SessionStatus.paused => {
        SessionStatus.running,
        SessionStatus.finished,
        SessionStatus.abandoned,
      },
      SessionStatus.draft ||
      SessionStatus.finished ||
      SessionStatus.abandoned => <SessionStatus>{},
    };
    if (!allowed.contains(target)) {
      return Err(
        ValidationFailure(
          'Cannot transition session from $wireValue to ${target.wireValue}.',
        ),
      );
    }
    return Ok(target);
  }
}
