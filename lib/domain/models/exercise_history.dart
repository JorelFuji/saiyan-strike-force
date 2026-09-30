import '../../core/failure.dart';
import '../../core/result.dart';
import 'active_session.dart';
import 'calendar_date.dart';
import 'exercise_name.dart';

/// One completed set in an exercise-history instance (actual values only).
final class ExerciseHistoryCompletedSet {
  const ExerciseHistoryCompletedSet._({
    required this.setIndex,
    required this.actual,
    required this.rpe,
  });

  final int setIndex;
  final ActualPrescription actual;
  final double? rpe;

  static Result<ExerciseHistoryCompletedSet> create({
    required int setIndex,
    required ActualPrescription actual,
    double? rpe,
  }) {
    if (setIndex < 0) {
      return const Err(ValidationFailure('Set index must not be negative.'));
    }
    if (rpe != null && (!rpe.isFinite || rpe < 0 || rpe > 10)) {
      return const Err(
        ValidationFailure('Set RPE must be between 0 and 10 when present.'),
      );
    }
    return Ok(
      ExerciseHistoryCompletedSet._(
        setIndex: setIndex,
        actual: actual,
        rpe: rpe,
      ),
    );
  }
}

/// One finished session-exercise snapshot with every completed actual set.
final class ExerciseHistoryEntry {
  const ExerciseHistoryEntry._({
    required this.sessionExerciseId,
    required this.sessionId,
    required this.nameSnapshot,
    required this.normalizedName,
    required this.startedAt,
    required this.sessionOn,
    required this.completedSets,
  });

  final int sessionExerciseId;
  final int sessionId;
  final String nameSnapshot;
  final String normalizedName;
  final DateTime startedAt;
  final CalendarDate sessionOn;
  final List<ExerciseHistoryCompletedSet> completedSets;

  static Result<ExerciseHistoryEntry> create({
    required int sessionExerciseId,
    required int sessionId,
    required String nameSnapshot,
    required String normalizedName,
    required DateTime startedAt,
    required CalendarDate sessionOn,
    required List<ExerciseHistoryCompletedSet> completedSets,
  }) {
    if (sessionExerciseId < 1 || sessionId < 1) {
      return const Err(
        ValidationFailure('Exercise history identifiers must be positive.'),
      );
    }
    final display = validateDisplayName(nameSnapshot);
    if (display case Err(:final failure)) {
      return Err(failure);
    }
    final trimmedNormalized = normalizedName.trim();
    if (trimmedNormalized.isEmpty) {
      return const Err(
        ValidationFailure('Normalized exercise name must not be blank.'),
      );
    }
    final trimmedDisplay = (display as Ok<String>).value;
    if (normalizeExerciseName(trimmedDisplay) != trimmedNormalized) {
      return const Err(
        ValidationFailure('Exercise normalized name does not match snapshot.'),
      );
    }
    if (completedSets.isEmpty) {
      return const Err(
        ValidationFailure(
          'Exercise history entries require at least one completed set.',
        ),
      );
    }
    for (var i = 0; i < completedSets.length; i++) {
      if (i > 0 && completedSets[i].setIndex <= completedSets[i - 1].setIndex) {
        return const Err(
          ValidationFailure('Completed sets must be in ascending set order.'),
        );
      }
    }
    return Ok(
      ExerciseHistoryEntry._(
        sessionExerciseId: sessionExerciseId,
        sessionId: sessionId,
        nameSnapshot: trimmedDisplay,
        normalizedName: trimmedNormalized,
        startedAt: startedAt.toUtc(),
        sessionOn: sessionOn,
        completedSets: List.unmodifiable(completedSets),
      ),
    );
  }
}
