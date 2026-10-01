import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';
import 'package:vulcan_fitness/ui/workouts/workout_builder_cubit.dart';
import 'package:vulcan_fitness/ui/workouts/workout_builder_state.dart';

import '../../support/fake_exercise_name_repository.dart';
import '../../support/fake_settings_repository.dart';
import '../../support/fake_workout_repository.dart';

void main() {
  TemplateExercise squat() => (TemplateExercise.uniform(
    name: 'Squat',
    setCount: 3,
    reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
    load: LoadPrescription.bodyweight,
    restSeconds: 90,
  ) as Ok<TemplateExercise>).value;

  WorkoutTemplate template(int id, {List<TemplateExercise>? exercises}) =>
      (WorkoutTemplate.create(
        id: id,
        name: 'Leg Day',
        notes: 'notes',
        createdAt: DateTime.utc(2026, 9, 1),
        archivedAt: DateTime.utc(2026, 9, 29),
        exercises: exercises ?? [squat()],
      ) as Ok<WorkoutTemplate>).value;

  Future<WorkoutBuilderCubit> createCubit({
    int? workoutId,
    FakeWorkoutRepository? workouts,
    FakeExerciseNameRepository? names,
    FakeSettingsRepository? settings,
  }) async {
    final cubit = WorkoutBuilderCubit(
      workoutRepository: workouts ?? FakeWorkoutRepository(),
      exerciseNameRepository: names ?? FakeExerciseNameRepository(),
      settingsRepository: settings ?? FakeSettingsRepository(),
      workoutId: workoutId,
    )..initialize();
    await pumpEventQueue();
    return cubit;
  }

  test(
    'create mode initializes blank draft with display unit and suggestions',
    () async {
      final names = FakeExerciseNameRepository(names: ['Bench Press']);
      final cubit = await createCubit(names: names);
      expect(cubit.state.phase, WorkoutBuilderPhase.ready);
      expect(cubit.state.isCreate, isTrue);
      expect(cubit.state.name, isEmpty);
      expect(cubit.state.exercises, isEmpty);
      expect(cubit.state.massUnit, MassUnit.kg);
      expect(cubit.state.suggestions.single.display, 'Bench Press');
      await cubit.close();
    },
  );

  test(
    'edit mode loads original template without creating a new one',
    () async {
      final workouts = FakeWorkoutRepository(seed: [template(4)]);
      final cubit = await createCubit(workoutId: 4, workouts: workouts);
      expect(cubit.state.original?.id, 4);
      expect(cubit.state.name, 'Leg Day');
      expect(cubit.state.exercises.single.exercise.name, 'Squat');
      expect(workouts.createCalls, 0);
      await cubit.close();
    },
  );

  test('missing edit target surfaces load failure', () async {
    final cubit = await createCubit(workoutId: 99);
    expect(cubit.state.phase, WorkoutBuilderPhase.loadFailure);
    expect(cubit.state.loadFailureMessage, isNotNull);
    await cubit.close();
  });

  test(
    'suggestion failure is retryable and does not block authoring',
    () async {
      final names = FakeExerciseNameRepository()
        ..result = const Err(StorageFailure('suggestions failed'));
      final cubit = await createCubit(names: names);
      expect(cubit.state.phase, WorkoutBuilderPhase.ready);
      expect(cubit.state.suggestionFailureMessage, 'suggestions failed');
      names.result = null;
      await cubit.retrySuggestions();
      await pumpEventQueue();
      expect(cubit.state.suggestionFailureMessage, isNull);
      await cubit.close();
    },
  );

  test('ordering operations keep stable keys', () async {
    final cubit = await createCubit();
    cubit.addExercise(squat());
    cubit.addExercise(
      (TemplateExercise.uniform(
        name: 'Bench',
        setCount: 3,
        reps: (RepPrescription.fixed(8) as Ok<RepPrescription>).value,
        load: LoadPrescription.noLoad,
        restSeconds: 60,
      ) as Ok<TemplateExercise>).value,
    );
    final firstKey = cubit.state.exercises.first.key;
    final secondKey = cubit.state.exercises.last.key;
    cubit.moveLater(firstKey);
    expect(cubit.state.exercises.last.key, firstKey);
    cubit.moveEarlier(firstKey);
    expect(cubit.state.exercises.first.key, firstKey);
    cubit.reorder(0, 2);
    expect(cubit.state.exercises.last.key, firstKey);
    cubit.removeExercise(firstKey);
    expect(cubit.state.exercises.single.key, secondKey);
    await cubit.close();
  });

  test('explicit grouping and removal normalize adjacent membership', () async {
    final cubit = await createCubit();
    cubit.addExercise(squat());
    cubit.addExercise(squat());
    final secondKey = cubit.state.exercises.last.key;

    cubit.groupWithPrevious(secondKey);
    expect(cubit.state.exercises.map((row) => row.exercise.supersetGroup), [
      0,
      0,
    ]);

    cubit.removeFromSuperset(secondKey);
    expect(cubit.state.exercises.map((row) => row.exercise.supersetGroup), [
      null,
      null,
    ]);
    await cubit.close();
  });

  test('save creates once and preserves archived metadata on edit', () async {
    final workouts = FakeWorkoutRepository(seed: [template(2)]);
    final cubit = await createCubit(workoutId: 2, workouts: workouts);
    cubit.updateName('Updated Leg Day');
    await cubit.save();
    await pumpEventQueue();
    expect(workouts.updateCalls, 1);
    expect(workouts.lastUpdateTemplate?.archivedAt, isNotNull);
    expect(workouts.lastUpdateTemplate?.id, 2);
    expect(cubit.state.savedTemplate?.name, 'Updated Leg Day');
    await cubit.close();
  });

  test(
    'empty template name fails validation without repository call',
    () async {
      final workouts = FakeWorkoutRepository();
      final cubit = await createCubit(workouts: workouts);
      cubit.updateName('   ');
      await cubit.save();
      expect(workouts.createCalls, 0);
      expect(cubit.state.validationFailureMessage, isNotNull);
      await cubit.close();
    },
  );

  test('save failure retains draft and succeeds on retry', () async {
    final workouts = FakeWorkoutRepository()
      ..createResult = const Err(StorageFailure('write failed'));
    final cubit = await createCubit(workouts: workouts);
    cubit.updateName('Push Day');
    await cubit.save();
    await pumpEventQueue();
    expect(workouts.createCalls, 1);
    expect(cubit.state.saveFailureMessage, 'write failed');
    expect(cubit.state.name, 'Push Day');
    workouts.createResult = null;
    await cubit.save();
    await pumpEventQueue();
    expect(workouts.createCalls, 2);
    expect(cubit.state.savedTemplate?.name, 'Push Day');
    await cubit.close();
  });

  test('concurrent save intents are ignored while saving', () async {
    final workouts = FakeWorkoutRepository()
      ..createDelay = const Duration(milliseconds: 30);
    final cubit = WorkoutBuilderCubit(
      workoutRepository: workouts,
      exerciseNameRepository: FakeExerciseNameRepository(),
      settingsRepository: FakeSettingsRepository(),
    )..initialize();
    await pumpEventQueue();
    cubit.updateName('Push Day');
    final first = cubit.save();
    await pumpEventQueue();
    cubit.save();
    await first;
    await pumpEventQueue();
    expect(workouts.createCalls, 1);
    await cubit.close();
  });
}
