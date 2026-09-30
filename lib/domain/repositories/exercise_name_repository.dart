import '../../core/result.dart';
import '../models/exercise_name.dart';

/// Read-only local exercise-name suggestions for the template builder.
///
/// Names come from existing templates and historical sessions. Each normalized
/// key appears once, using the display spelling from its most recent use, in a
/// stable order by normalized key. Template recency is the parent template's
/// creation time, sessions use their start time, and archived templates are
/// included. An empty list is a valid result; authoring remains free text.
/// A corrupt stored row fails the whole read; callers should fall back to free
/// text on `Err`.
abstract interface class ExerciseNameRepository {
  Future<Result<List<ExerciseNameSuggestion>>> listSuggestions();
}
