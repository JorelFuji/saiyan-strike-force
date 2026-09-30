import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';

void main() {
  test(
    'creates immutable normalized aggregate and permits empty exercises',
    () {
      final exercise = TemplateExercise.create(
        name: ' Bench  Press ',
        plannedSets: 3,
        reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        load: const BodyweightLoad(),
        restSeconds: 90,
        supersetGroup: 0,
      );
      final draft = WorkoutTemplateDraft.create(
        name: '  Push  ',
        notes: 'A',
        exercises: [(exercise as Ok<TemplateExercise>).value],
      );
      expect((draft as Ok<WorkoutTemplateDraft>).value.name, 'Push');
      expect(draft.value.exercises.single.name, 'Bench  Press');
      expect(draft.value.exercises.single.normalizedName, 'bench press');
      expect(
        WorkoutTemplateDraft.create(name: 'Empty'),
        isA<Ok<WorkoutTemplateDraft>>(),
      );
    },
  );

  test('rejects invalid aggregate fields', () {
    final reps = (RepPrescription.fixed(5) as Ok<RepPrescription>).value;
    final load = const NoLoad();
    expect(
      TemplateExercise.create(
        name: 'x',
        plannedSets: 0,
        reps: reps,
        load: load,
        restSeconds: 0,
      ),
      isA<Err<TemplateExercise>>(),
    );
    expect(
      TemplateExercise.create(
        name: 'x',
        plannedSets: 1,
        reps: reps,
        load: load,
        restSeconds: -1,
      ),
      isA<Err<TemplateExercise>>(),
    );
    expect(
      TemplateExercise.create(
        name: 'x',
        plannedSets: 1,
        reps: reps,
        load: load,
        restSeconds: 0,
        supersetGroup: -1,
      ),
      isA<Err<TemplateExercise>>(),
    );
    expect(
      WorkoutTemplate.create(id: 0, name: 'x', createdAt: DateTime.utc(2026)),
      isA<Err<WorkoutTemplate>>(),
    );
  });
}
