import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/exercise_name.dart';
import '../../domain/repositories/exercise_name_repository.dart';
import '../database/app_database.dart';

/// Unions template and session exercise names, keeping the latest spelling per
/// normalized key. Ties on the parent instant prefer sessions over templates,
/// then the higher child primary key.
const _suggestionSql = '''
WITH uses AS (
  SELECT
    we.name AS display_name,
    we.normalized_name AS normalized_name,
    w.created_at AS used_at,
    0 AS source_rank,
    we.id AS child_id
  FROM workout_exercise we
  INNER JOIN workout w ON w.id = we.workout_id
  UNION ALL
  SELECT
    se.name_snapshot AS display_name,
    se.normalized_name AS normalized_name,
    s.started_at AS used_at,
    1 AS source_rank,
    se.id AS child_id
  FROM session_exercise se
  INNER JOIN session s ON s.id = se.session_id
),
ranked AS (
  SELECT
    display_name,
    normalized_name,
    ROW_NUMBER() OVER (
      PARTITION BY normalized_name
      ORDER BY used_at DESC, source_rank DESC, child_id DESC
    ) AS rank
  FROM uses
)
SELECT display_name, normalized_name
FROM ranked
WHERE rank = 1
ORDER BY normalized_name ASC
''';

final class DriftExerciseNameRepository implements ExerciseNameRepository {
  DriftExerciseNameRepository(this.database);

  final AppDatabase database;

  @override
  Future<Result<List<ExerciseNameSuggestion>>> listSuggestions() async {
    try {
      final rows = await database
          .customSelect(
            _suggestionSql,
            readsFrom: {
              database.workout,
              database.workoutExercise,
              database.session,
              database.sessionExercise,
            },
          )
          .get();
      final suggestions = <ExerciseNameSuggestion>[];
      for (final row in rows) {
        final mapped = ExerciseNameSuggestion.create(
          display: row.read<String>('display_name'),
          normalized: row.read<String>('normalized_name'),
        );
        switch (mapped) {
          case Ok(:final value):
            suggestions.add(value);
          case Err(:final failure):
            return Err(failure);
        }
      }
      return Ok(suggestions);
    } on Exception catch (error, stack) {
      return Err(
        StorageFailure(
          'Exercise name storage operation failed.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }
}
