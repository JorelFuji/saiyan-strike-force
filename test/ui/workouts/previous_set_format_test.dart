import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/exercise_history.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/ui/workouts/previous_set_format.dart';

void main() {
  RepPrescription fixed(int reps) =>
      (RepPrescription.fixed(reps) as Ok<RepPrescription>).value;
  LoadPrescription absoluteLoad(int milligrams) =>
      (LoadPrescription.absolute(milligrams) as Ok<LoadPrescription>).value;
  LoadPrescription percentage(int value) =>
      (LoadPrescription.percentage(value) as Ok<LoadPrescription>).value;
  LoadPrescription rpe(double value) =>
      (LoadPrescription.targetRpe(value) as Ok<LoadPrescription>).value;

  ExerciseHistoryCompletedSet set({
    required RepPrescription reps,
    required LoadPrescription load,
  }) => (ExerciseHistoryCompletedSet.create(
    setIndex: 0,
    actual: (ActualPrescription.create(
      reps: reps,
      load: load,
    ) as Ok<ActualPrescription>).value,
  ) as Ok<ExerciseHistoryCompletedSet>).value;

  test('formats missing, no-load, and absolute previous values', () {
    expect(formatPreviousSet(null, MassUnit.kg), '—');
    expect(
      formatPreviousSet(
        set(reps: fixed(6), load: LoadPrescription.noLoad),
        MassUnit.lb,
      ),
      '6 reps',
    );
    final absolute = set(reps: fixed(3), load: absoluteLoad(43091375));
    expect(formatPreviousSet(absolute, MassUnit.lb), '95 lb × 3');
    expect(formatPreviousSet(absolute, MassUnit.kg), '43 kg × 3');
  });

  test('formats bodyweight, percentage, and RPE values', () {
    expect(
      formatPreviousSet(
        set(reps: fixed(8), load: LoadPrescription.bodyweight),
        MassUnit.kg,
      ),
      '8 reps',
    );
    expect(
      formatPreviousSet(set(reps: fixed(5), load: percentage(70)), MassUnit.kg),
      '70% × 5',
    );
    expect(
      formatPreviousSet(set(reps: fixed(5), load: rpe(8)), MassUnit.kg),
      'RPE 8 × 5',
    );
  });
}
