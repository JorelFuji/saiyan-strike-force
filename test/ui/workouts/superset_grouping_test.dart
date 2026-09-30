import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';
import 'package:vulcan_fitness/ui/workouts/superset_grouping.dart';
import 'package:vulcan_fitness/ui/workouts/workout_builder_state.dart';

void main() {
  TemplateExercise exercise(String name, {int? group}) =>
      (TemplateExercise.create(
        name: name,
        plannedSets: 2,
        reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        load: LoadPrescription.bodyweight,
        restSeconds: 60,
        supersetGroup: group,
      ) as Ok<TemplateExercise>).value;

  List<DraftExerciseRow> rows(List<TemplateExercise> exercises) => [
    for (var i = 0; i < exercises.length; i++)
      DraftExerciseRow(key: i + 1, exercise: exercises[i]),
  ];

  test('groups adjacent rows and assigns dense tokens', () {
    final result = groupWithPrevious(rows([exercise('A'), exercise('B')]), 1);
    expect(result.map((row) => row.exercise.supersetGroup), [0, 0]);
  });

  test('removing a member clears the now-singleton group', () {
    final input = rows([exercise('A', group: 4), exercise('B', group: 4)]);
    final result = removeFromSuperset(input, 1);
    expect(result.map((row) => row.exercise.supersetGroup), [null, null]);
    expect(result.map((row) => row.key), [1, 2]);
  });

  test('normalization clears singleton and non-contiguous legacy tokens', () {
    final result = normalizeSupersetRows(
      rows([
        exercise('A', group: 8),
        exercise('B'),
        exercise('C', group: 8),
        exercise('D', group: 2),
        exercise('E', group: 2),
      ]),
    );
    expect(result.map((row) => row.exercise.supersetGroup), [
      null,
      null,
      null,
      0,
      0,
    ]);
  });

  test(
    'normalization preserves keys and prescriptions across multiple groups',
    () {
      final result = normalizeSupersetRows(
        rows([
          exercise('A', group: 11),
          exercise('B', group: 11),
          exercise('C', group: 19),
          exercise('D', group: 19),
        ]),
      );
      expect(result.map((row) => row.key), [1, 2, 3, 4]);
      expect(result.map((row) => row.exercise.name), ['A', 'B', 'C', 'D']);
      expect(result.map((row) => row.exercise.supersetGroup), [0, 0, 1, 1]);
    },
  );
}
