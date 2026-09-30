import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/exercise_name.dart';
import 'package:vulcan_fitness/domain/repositories/exercise_name_repository.dart';

/// Hand-written fake for builder Cubit, router, and widget tests.
final class FakeExerciseNameRepository implements ExerciseNameRepository {
  FakeExerciseNameRepository({List<String> names = const []}) {
    for (final name in names) {
      suggestions.add(
        (ExerciseNameSuggestion.create(
          display: name,
          normalized: normalizeExerciseName(name),
        ) as Ok<ExerciseNameSuggestion>).value,
      );
    }
  }

  final List<ExerciseNameSuggestion> suggestions = [];

  /// When set, returned instead of [suggestions].
  Result<List<ExerciseNameSuggestion>>? result;

  int listCalls = 0;

  @override
  Future<Result<List<ExerciseNameSuggestion>>> listSuggestions() async {
    listCalls++;
    return result ?? Ok(List.unmodifiable(suggestions));
  }
}
