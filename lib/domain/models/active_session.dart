import '../../core/failure.dart';
import '../../core/result.dart';
import 'exercise_name.dart';
import 'prescriptions.dart';
import 'session_status.dart';

final class ActualPrescription {
  const ActualPrescription._({required this.reps, required this.load});

  final RepPrescription reps;
  final LoadPrescription load;

  static Result<ActualPrescription> create({
    required RepPrescription reps,
    required LoadPrescription load,
  }) => Ok(ActualPrescription._(reps: reps, load: load));
}

final class AbsoluteRestState {
  const AbsoluteRestState._({
    required this.startedAt,
    required this.durationSeconds,
    required this.targetAt,
  });

  final DateTime startedAt;
  final int durationSeconds;
  final DateTime targetAt;

  static Result<AbsoluteRestState> create({
    required DateTime startedAt,
    required int durationSeconds,
  }) {
    if (durationSeconds < 0) {
      return const Err(
        ValidationFailure('Rest duration must not be negative.'),
      );
    }
    final utcStart = startedAt.toUtc();
    return Ok(
      AbsoluteRestState._(
        startedAt: utcStart,
        durationSeconds: durationSeconds,
        targetAt: utcStart.add(Duration(seconds: durationSeconds)),
      ),
    );
  }
}

final class SessionSetSnapshot {
  const SessionSetSnapshot._({
    required this.id,
    required this.sessionExerciseId,
    required this.setIndex,
    required this.plannedReps,
    required this.plannedLoad,
    required this.plannedRestSeconds,
    required this.actual,
    required this.rpe,
    required this.completed,
    required this.completedAt,
  });

  final int id;
  final int sessionExerciseId;
  final int setIndex;
  final RepPrescription plannedReps;
  final LoadPrescription plannedLoad;
  final int? plannedRestSeconds;
  final ActualPrescription? actual;
  final double? rpe;
  final bool completed;
  final DateTime? completedAt;

  static Result<SessionSetSnapshot> create({
    required int id,
    required int sessionExerciseId,
    required int setIndex,
    required RepPrescription plannedReps,
    required LoadPrescription plannedLoad,
    int? plannedRestSeconds,
    ActualPrescription? actual,
    double? rpe,
    required bool completed,
    DateTime? completedAt,
  }) {
    if (id < 1 || sessionExerciseId < 1) {
      return const Err(ValidationFailure('Set identifiers must be positive.'));
    }
    if (setIndex < 0) {
      return const Err(ValidationFailure('Set index must not be negative.'));
    }
    if (plannedRestSeconds != null && plannedRestSeconds < 0) {
      return const Err(
        ValidationFailure('Planned rest seconds must not be negative.'),
      );
    }
    final rpeResult = _validateOptionalRpe(rpe);
    if (rpeResult case Err(:final failure)) {
      return Err(failure);
    }
    if (completed && completedAt == null) {
      return const Err(
        ValidationFailure('Completed sets require a completion instant.'),
      );
    }
    if (!completed && completedAt != null) {
      return const Err(
        ValidationFailure(
          'Incomplete sets must not have a completion instant.',
        ),
      );
    }
    return Ok(
      SessionSetSnapshot._(
        id: id,
        sessionExerciseId: sessionExerciseId,
        setIndex: setIndex,
        plannedReps: plannedReps,
        plannedLoad: plannedLoad,
        plannedRestSeconds: plannedRestSeconds,
        actual: actual,
        rpe: (rpeResult as Ok<double?>).value,
        completed: completed,
        completedAt: completedAt?.toUtc(),
      ),
    );
  }
}

final class SessionExerciseSnapshot {
  const SessionExerciseSnapshot._({
    required this.id,
    required this.sessionId,
    required this.nameSnapshot,
    required this.normalizedName,
    required this.orderIndex,
    required this.plannedSets,
    required this.plannedReps,
    required this.plannedLoad,
    required this.plannedRestSeconds,
    required this.supersetGroup,
    required this.sets,
  });

  final int id;
  final int sessionId;
  final String nameSnapshot;
  final String normalizedName;
  final int orderIndex;
  final int plannedSets;
  final RepPrescription plannedReps;
  final LoadPrescription plannedLoad;
  final int plannedRestSeconds;
  final int? supersetGroup;
  final List<SessionSetSnapshot> sets;

  static Result<SessionExerciseSnapshot> create({
    required int id,
    required int sessionId,
    required String nameSnapshot,
    required int orderIndex,
    required int plannedSets,
    required RepPrescription plannedReps,
    required LoadPrescription plannedLoad,
    required int plannedRestSeconds,
    int? supersetGroup,
    List<SessionSetSnapshot> sets = const [],
  }) {
    if (id < 1 || sessionId < 1) {
      return const Err(
        ValidationFailure('Exercise identifiers must be positive.'),
      );
    }
    final display = validateDisplayName(nameSnapshot);
    if (display case Err(:final failure)) {
      return Err(failure);
    }
    final trimmed = (display as Ok<String>).value;
    final normalized = normalizeExerciseName(trimmed);
    if (orderIndex < 0) {
      return const Err(ValidationFailure('Order index must not be negative.'));
    }
    if (plannedSets < 1) {
      return const Err(ValidationFailure('Planned sets must be at least 1.'));
    }
    if (plannedRestSeconds < 0) {
      return const Err(ValidationFailure('Rest seconds must not be negative.'));
    }
    if (supersetGroup != null && supersetGroup < 0) {
      return const Err(
        ValidationFailure('Superset group must not be negative.'),
      );
    }
    for (final set in sets) {
      if (set.sessionExerciseId != id) {
        return const Err(
          ValidationFailure('Set does not belong to this exercise.'),
        );
      }
    }
    return Ok(
      SessionExerciseSnapshot._(
        id: id,
        sessionId: sessionId,
        nameSnapshot: trimmed,
        normalizedName: normalized,
        orderIndex: orderIndex,
        plannedSets: plannedSets,
        plannedReps: plannedReps,
        plannedLoad: plannedLoad,
        plannedRestSeconds: plannedRestSeconds,
        supersetGroup: supersetGroup,
        sets: List.unmodifiable(sets),
      ),
    );
  }
}

final class ActiveSession {
  const ActiveSession._({
    required this.id,
    required this.workoutId,
    required this.scheduleEntryId,
    required this.workoutNameSnapshot,
    required this.startedAt,
    required this.endedAt,
    required this.timezone,
    required this.status,
    required this.notes,
    required this.rest,
    required this.exercises,
  });

  final int id;
  final int? workoutId;
  final int? scheduleEntryId;
  final String workoutNameSnapshot;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String timezone;
  final SessionStatus status;
  final String? notes;
  final AbsoluteRestState? rest;
  final List<SessionExerciseSnapshot> exercises;

  static Result<ActiveSession> create({
    required int id,
    int? workoutId,
    int? scheduleEntryId,
    required String workoutNameSnapshot,
    required DateTime startedAt,
    DateTime? endedAt,
    required String timezone,
    required SessionStatus status,
    String? notes,
    AbsoluteRestState? rest,
    List<SessionExerciseSnapshot> exercises = const [],
  }) {
    if (id < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    if (workoutId != null && workoutId < 1) {
      return const Err(ValidationFailure('Workout ID must be positive.'));
    }
    if (scheduleEntryId != null && scheduleEntryId < 1) {
      return const Err(
        ValidationFailure('Schedule entry ID must be positive.'),
      );
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
    for (final exercise in exercises) {
      if (exercise.sessionId != id) {
        return const Err(
          ValidationFailure('Exercise does not belong to this session.'),
        );
      }
    }
    final endedAtUtc = endedAt?.toUtc();
    final terminal =
        status == SessionStatus.finished || status == SessionStatus.abandoned;
    if (terminal && endedAtUtc == null) {
      return const Err(
        ValidationFailure('Terminal sessions require an end instant.'),
      );
    }
    if (!terminal && endedAtUtc != null) {
      return const Err(
        ValidationFailure('In-progress sessions must not have an end instant.'),
      );
    }
    return Ok(
      ActiveSession._(
        id: id,
        workoutId: workoutId,
        scheduleEntryId: scheduleEntryId,
        workoutNameSnapshot: (display as Ok<String>).value,
        startedAt: startedAt.toUtc(),
        endedAt: endedAtUtc,
        timezone: normalizedTimezone,
        status: status,
        notes: notes,
        rest: rest,
        exercises: List.unmodifiable(exercises),
      ),
    );
  }
}

/// Creates a session-owned exercise and its initial, incomplete set rows.
final class AddSessionExerciseCommand {
  const AddSessionExerciseCommand._({
    required this.sessionId,
    required this.name,
    required this.initialSetCount,
    required this.reps,
    required this.load,
    required this.restSeconds,
  });

  final int sessionId;
  final ExerciseName name;
  final int initialSetCount;
  final RepPrescription reps;
  final LoadPrescription load;
  final int restSeconds;

  static Result<AddSessionExerciseCommand> create({
    required int sessionId,
    required String name,
    required int initialSetCount,
    required RepPrescription reps,
    required LoadPrescription load,
    required int restSeconds,
  }) {
    if (sessionId < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    final exerciseName = ExerciseName.forLookup(name);
    if (exerciseName case Err(:final failure)) return Err(failure);
    if (initialSetCount < 1) {
      return const Err(ValidationFailure('Initial sets must be at least 1.'));
    }
    if (restSeconds < 0) {
      return const Err(ValidationFailure('Rest seconds must not be negative.'));
    }
    return Ok(
      AddSessionExerciseCommand._(
        sessionId: sessionId,
        name: (exerciseName as Ok<ExerciseName>).value,
        initialSetCount: initialSetCount,
        reps: reps,
        load: load,
        restSeconds: restSeconds,
      ),
    );
  }
}

/// Appends one set using the persisted prescription of its parent exercise.
final class AddSessionSetCommand {
  const AddSessionSetCommand._({
    required this.sessionId,
    required this.exerciseId,
  });

  final int sessionId;
  final int exerciseId;

  static Result<AddSessionSetCommand> create({
    required int sessionId,
    required int exerciseId,
  }) {
    if (sessionId < 1 || exerciseId < 1) {
      return const Err(
        ValidationFailure('Session and exercise identifiers must be positive.'),
      );
    }
    return Ok(
      AddSessionSetCommand._(sessionId: sessionId, exerciseId: exerciseId),
    );
  }
}

final class SaveSetActualValuesCommand {
  const SaveSetActualValuesCommand._({
    required this.sessionId,
    required this.setId,
    required this.actual,
    required this.rpe,
  });

  final int sessionId;
  final int setId;
  final ActualPrescription actual;
  final double? rpe;

  static Result<SaveSetActualValuesCommand> create({
    required int sessionId,
    required int setId,
    required ActualPrescription actual,
    double? rpe,
  }) {
    if (sessionId < 1 || setId < 1) {
      return const Err(
        ValidationFailure('Session and set identifiers must be positive.'),
      );
    }
    final rpeResult = _validateOptionalRpe(rpe);
    if (rpeResult case Err(:final failure)) {
      return Err(failure);
    }
    return Ok(
      SaveSetActualValuesCommand._(
        sessionId: sessionId,
        setId: setId,
        actual: actual,
        rpe: (rpeResult as Ok<double?>).value,
      ),
    );
  }
}

final class CompleteSetCommand {
  const CompleteSetCommand._({
    required this.sessionId,
    required this.setId,
    required this.actual,
    required this.rpe,
    required this.completedAt,
    required this.rest,
  });

  final int sessionId;
  final int setId;
  final ActualPrescription actual;
  final double? rpe;
  final DateTime completedAt;
  final AbsoluteRestState? rest;

  static Result<CompleteSetCommand> create({
    required int sessionId,
    required int setId,
    required ActualPrescription actual,
    double? rpe,
    required DateTime completedAt,
    AbsoluteRestState? rest,
  }) {
    if (sessionId < 1 || setId < 1) {
      return const Err(
        ValidationFailure('Session and set identifiers must be positive.'),
      );
    }
    final rpeResult = _validateOptionalRpe(rpe);
    if (rpeResult case Err(:final failure)) {
      return Err(failure);
    }
    return Ok(
      CompleteSetCommand._(
        sessionId: sessionId,
        setId: setId,
        actual: actual,
        rpe: (rpeResult as Ok<double?>).value,
        completedAt: completedAt.toUtc(),
        rest: rest,
      ),
    );
  }
}

final class UpdateSessionNotesCommand {
  const UpdateSessionNotesCommand._({
    required this.sessionId,
    required this.notes,
  });

  final int sessionId;
  final String? notes;

  static Result<UpdateSessionNotesCommand> create({
    required int sessionId,
    String? notes,
  }) {
    if (sessionId < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    return Ok(UpdateSessionNotesCommand._(sessionId: sessionId, notes: notes));
  }
}

final class PauseSessionCommand {
  const PauseSessionCommand._({
    required this.sessionId,
    required this.currentStatus,
  });

  final int sessionId;
  final SessionStatus currentStatus;

  static Result<PauseSessionCommand> create({
    required int sessionId,
    required SessionStatus currentStatus,
  }) {
    if (sessionId < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    final transition = currentStatus.validateTransitionTo(SessionStatus.paused);
    if (transition case Err(:final failure)) {
      return Err(failure);
    }
    return Ok(
      PauseSessionCommand._(sessionId: sessionId, currentStatus: currentStatus),
    );
  }
}

final class ContinueSessionCommand {
  const ContinueSessionCommand._({
    required this.sessionId,
    required this.currentStatus,
  });

  final int sessionId;
  final SessionStatus currentStatus;

  static Result<ContinueSessionCommand> create({
    required int sessionId,
    required SessionStatus currentStatus,
  }) {
    if (sessionId < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    final transition = currentStatus.validateTransitionTo(
      SessionStatus.running,
    );
    if (transition case Err(:final failure)) {
      return Err(failure);
    }
    return Ok(
      ContinueSessionCommand._(
        sessionId: sessionId,
        currentStatus: currentStatus,
      ),
    );
  }
}

final class FinishSessionCommand {
  const FinishSessionCommand._({
    required this.sessionId,
    required this.currentStatus,
    required this.endedAt,
  });

  final int sessionId;
  final SessionStatus currentStatus;
  final DateTime endedAt;

  static Result<FinishSessionCommand> create({
    required int sessionId,
    required SessionStatus currentStatus,
    required DateTime endedAt,
  }) {
    if (sessionId < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    final transition = currentStatus.validateTransitionTo(
      SessionStatus.finished,
    );
    if (transition case Err(:final failure)) {
      return Err(failure);
    }
    return Ok(
      FinishSessionCommand._(
        sessionId: sessionId,
        currentStatus: currentStatus,
        endedAt: endedAt.toUtc(),
      ),
    );
  }
}

final class AbandonSessionCommand {
  const AbandonSessionCommand._({
    required this.sessionId,
    required this.currentStatus,
    required this.endedAt,
  });

  final int sessionId;
  final SessionStatus currentStatus;
  final DateTime endedAt;

  static Result<AbandonSessionCommand> create({
    required int sessionId,
    required SessionStatus currentStatus,
    required DateTime endedAt,
  }) {
    if (sessionId < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    final transition = currentStatus.validateTransitionTo(
      SessionStatus.abandoned,
    );
    if (transition case Err(:final failure)) {
      return Err(failure);
    }
    return Ok(
      AbandonSessionCommand._(
        sessionId: sessionId,
        currentStatus: currentStatus,
        endedAt: endedAt.toUtc(),
      ),
    );
  }
}

final class UpdateSessionRestCommand {
  const UpdateSessionRestCommand._({
    required this.sessionId,
    required this.rest,
  });

  final int sessionId;
  final AbsoluteRestState rest;

  static Result<UpdateSessionRestCommand> create({
    required int sessionId,
    required AbsoluteRestState rest,
  }) {
    if (sessionId < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    return Ok(UpdateSessionRestCommand._(sessionId: sessionId, rest: rest));
  }
}

final class ClearSessionRestCommand {
  const ClearSessionRestCommand._({required this.sessionId});

  final int sessionId;

  static Result<ClearSessionRestCommand> create({required int sessionId}) {
    if (sessionId < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    return Ok(ClearSessionRestCommand._(sessionId: sessionId));
  }
}

Result<double?> _validateOptionalRpe(double? rpe) {
  if (rpe == null) {
    return const Ok(null);
  }
  if (!rpe.isFinite || rpe < 0 || rpe > 10) {
    return const Err(ValidationFailure('RPE must be between 0 and 10.'));
  }
  return Ok(rpe);
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
