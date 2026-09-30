import '../../domain/models/workout_template.dart';
import '../../core/result.dart';
import 'workout_builder_state.dart';

/// Returns a copy of [exercise] with a different persisted group token.
TemplateExercise withSupersetGroup(TemplateExercise exercise, int? group) {
  final result = TemplateExercise.create(
    name: exercise.name,
    plannedSets: exercise.plannedSets,
    reps: exercise.reps,
    load: exercise.load,
    restSeconds: exercise.restSeconds,
    supersetGroup: group,
  );
  return (result as Ok<TemplateExercise>).value;
}

/// Normalizes only contiguous, unambiguous groups in draft order.
List<DraftExerciseRow> normalizeSupersetRows(List<DraftExerciseRow> rows) {
  final runsByToken = <int, List<List<int>>>{};
  var index = 0;
  while (index < rows.length) {
    final token = rows[index].exercise.supersetGroup;
    final start = index;
    while (index + 1 < rows.length &&
        rows[index + 1].exercise.supersetGroup == token) {
      index++;
    }
    if (token != null) {
      runsByToken.putIfAbsent(token, () => []).add([start, index]);
    }
    index++;
  }

  final validTokens = runsByToken.entries
      .where(
        (entry) =>
            entry.value.length == 1 &&
            entry.value.single[1] - entry.value.single[0] >= 1,
      )
      .map((entry) => entry.key)
      .toSet();
  final denseTokens = <int, int>{};
  var nextToken = 0;
  return [
    for (final row in rows)
      () {
        final token = row.exercise.supersetGroup;
        if (token == null || !validTokens.contains(token)) {
          return DraftExerciseRow(
            key: row.key,
            exercise: withSupersetGroup(row.exercise, null),
          );
        }
        final dense = denseTokens.putIfAbsent(token, () => nextToken++);
        return DraftExerciseRow(
          key: row.key,
          exercise: withSupersetGroup(row.exercise, dense),
        );
      }(),
  ];
}

List<DraftExerciseRow> groupWithPrevious(
  List<DraftExerciseRow> rows,
  int index,
) {
  if (index <= 0 || index >= rows.length) return rows;
  final updated = List<DraftExerciseRow>.of(rows);
  final previous = updated[index - 1].exercise;
  final token = previous.supersetGroup ?? _nextToken(updated);
  updated[index] = DraftExerciseRow(
    key: updated[index].key,
    exercise: withSupersetGroup(updated[index].exercise, token),
  );
  if (previous.supersetGroup == null) {
    updated[index - 1] = DraftExerciseRow(
      key: updated[index - 1].key,
      exercise: withSupersetGroup(previous, token),
    );
  }
  return normalizeSupersetRows(updated);
}

List<DraftExerciseRow> removeFromSuperset(
  List<DraftExerciseRow> rows,
  int index,
) {
  if (index < 0 || index >= rows.length) return rows;
  final updated = List<DraftExerciseRow>.of(rows);
  updated[index] = DraftExerciseRow(
    key: updated[index].key,
    exercise: withSupersetGroup(updated[index].exercise, null),
  );
  return normalizeSupersetRows(updated);
}

int _nextToken(List<DraftExerciseRow> rows) {
  return rows
          .map((row) => row.exercise.supersetGroup)
          .whereType<int>()
          .fold(-1, (max, token) => token > max ? token : max) +
      1;
}
