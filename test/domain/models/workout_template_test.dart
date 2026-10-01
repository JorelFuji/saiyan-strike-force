import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';

void main() {
  final reps = (RepPrescription.fixed(5) as Ok<RepPrescription>).value;
  final load = const BodyweightLoad();

  test(
    'creates immutable normalized aggregate and permits empty exercises',
    () {
      final exercise = TemplateExercise.uniform(
        name: ' Bench  Press ',
        setCount: 3,
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
    expect(
      TemplateExercise.uniform(
        name: 'x',
        setCount: 0,
        reps: reps,
        load: load,
        restSeconds: 0,
      ),
      isA<Err<TemplateExercise>>(),
    );
    expect(
      TemplateExercise.uniform(
        name: 'x',
        setCount: 1,
        reps: reps,
        load: load,
        restSeconds: -1,
      ),
      isA<Err<TemplateExercise>>(),
    );
    expect(
      TemplateExercise.uniform(
        name: 'x',
        setCount: 1,
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

  test('validates and derives per-set prescriptions', () {
    final first = (TemplateSet.create(
      reps: reps,
      load: load,
      restSeconds: 60,
    ) as Ok<TemplateSet>).value;
    final second = (TemplateSet.create(
      reps: reps,
      load: load,
      restSeconds: 90,
    ) as Ok<TemplateSet>).value;
    final exercise = (TemplateExercise.create(
      name: 'Bench',
      sets: [first, second],
    ) as Ok<TemplateExercise>).value;
    expect(exercise.plannedSets, 2);
    expect(exercise.lastSet, second);
    expect(exercise.sets, hasLength(2));
    expect(() => exercise.sets.add(first), throwsUnsupportedError);
    expect(
      TemplateExercise.create(name: 'Bench', sets: const []),
      isA<Err<TemplateExercise>>(),
    );
    expect(
      TemplateSet.create(reps: reps, load: load, restSeconds: -1),
      isA<Err<TemplateSet>>(),
    );
    expect(
      TemplateExercise.uniform(
        name: 'Bench',
        setCount: 0,
        reps: reps,
        load: load,
        restSeconds: 60,
      ),
      isA<Err<TemplateExercise>>(),
    );
    final range = (RepPrescription.range(5, 8) as Ok<RepPrescription>).value;
    expect(
      TemplateExercise.create(
        name: 'Bench',
        sets: [
          first,
          (TemplateSet.create(
            reps: range,
            load: load,
            restSeconds: 60,
          ) as Ok<TemplateSet>).value,
        ],
      ),
      isA<Err<TemplateExercise>>(),
    );
  });
}
