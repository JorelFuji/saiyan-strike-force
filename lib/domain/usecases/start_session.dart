import '../../core/failure.dart';
import '../../core/result.dart';
import '../repositories/session_repository.dart';

final class StartSessionCommand {
  const StartSessionCommand._({
    required this.workoutId,
    required this.scheduleEntryId,
    required this.startedAt,
    required this.timezone,
  });

  final int workoutId;
  final int? scheduleEntryId;
  final DateTime startedAt;
  final String timezone;

  static Result<StartSessionCommand> create({
    required int workoutId,
    int? scheduleEntryId,
    required DateTime startedAt,
    required String timezone,
  }) {
    if (workoutId < 1 || (scheduleEntryId != null && scheduleEntryId < 1)) {
      return const Err(
        ValidationFailure('Session source identifiers must be positive.'),
      );
    }
    final timezoneResult = _validatedTimezone(timezone);
    if (timezoneResult case Err(:final failure)) return Err(failure);
    return Ok(
      StartSessionCommand._(
        workoutId: workoutId,
        scheduleEntryId: scheduleEntryId,
        startedAt: startedAt.toUtc(),
        timezone: (timezoneResult as Ok<String>).value,
      ),
    );
  }
}

final class StartFreestyleSessionCommand {
  const StartFreestyleSessionCommand._({
    required this.startedAt,
    required this.timezone,
  });

  final DateTime startedAt;
  final String timezone;

  static Result<StartFreestyleSessionCommand> create({
    required DateTime startedAt,
    required String timezone,
  }) {
    final timezoneResult = _validatedTimezone(timezone);
    if (timezoneResult case Err(:final failure)) return Err(failure);
    return Ok(
      StartFreestyleSessionCommand._(
        startedAt: startedAt.toUtc(),
        timezone: (timezoneResult as Ok<String>).value,
      ),
    );
  }
}

Result<String> _validatedTimezone(String timezone) {
  final value = timezone.trim();
  if (!_isTimezoneIdentifier(value)) {
    return const Err(
      ValidationFailure(
        'Timezone must be a nonblank IANA timezone identifier.',
      ),
    );
  }
  return Ok(value);
}

bool _isTimezoneIdentifier(String value) {
  // The platform timezone service is the source of truth for membership in
  // the IANA database. Validate the identifier shape here without maintaining
  // a second copy of that database in the domain layer.
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

final class StartSession {
  const StartSession(this.repository);

  final SessionRepository repository;

  Future<Result<int>> call(StartSessionCommand command) {
    return repository.startFromTemplate(command);
  }

  Future<Result<int>> startFreestyle(StartFreestyleSessionCommand command) {
    return repository.startFreestyle(command);
  }
}
