import '../../core/failure.dart';
import '../../core/result.dart';

/// Trims and collapses Unicode whitespace before lowercasing. This is not
/// Unicode normalization or full case-folding; changing that policy requires
/// a deliberate persisted-key migration.
String normalizeExerciseName(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

Result<String> validateDisplayName(String value) {
  final display = value.trim();
  if (display.isEmpty) {
    return const Err(ValidationFailure('Name must not be blank.'));
  }
  return Ok(display);
}

/// A local autocomplete suggestion: one display spelling per normalized key.
final class ExerciseNameSuggestion {
  const ExerciseNameSuggestion._({
    required this.display,
    required this.normalized,
  });

  final String display;
  final String normalized;

  /// Validates persisted values; [normalized] must be the key derived from
  /// [display] under [normalizeExerciseName], otherwise the row is corrupt.
  static Result<ExerciseNameSuggestion> create({
    required String display,
    required String normalized,
  }) {
    final displayResult = validateDisplayName(display);
    if (displayResult case Err(:final failure)) {
      return Err(failure);
    }
    final trimmed = (displayResult as Ok<String>).value;
    if (normalizeExerciseName(trimmed) != normalized) {
      return const Err(
        ValidationFailure('Exercise name does not match its normalized key.'),
      );
    }
    return Ok(
      ExerciseNameSuggestion._(display: trimmed, normalized: normalized),
    );
  }
}

/// Validated display/normalized exercise identity for history lookups.
final class ExerciseName {
  const ExerciseName._({required this.display, required this.normalized});

  final String display;
  final String normalized;

  /// Derives the persisted lookup key from user-facing text (route or UI).
  static Result<ExerciseName> forLookup(String raw) {
    final displayResult = validateDisplayName(raw);
    if (displayResult case Err(:final failure)) {
      return Err(failure);
    }
    final display = (displayResult as Ok<String>).value;
    return Ok(
      ExerciseName._(
        display: display,
        normalized: normalizeExerciseName(display),
      ),
    );
  }
}
