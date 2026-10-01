import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';
import 'package:vulcan_fitness/ui/workouts/workout_builder_cubit.dart';
import 'package:vulcan_fitness/ui/workouts/workout_builder_page.dart';
import 'package:vulcan_fitness/ui/workouts/widgets/template_exercise_editor_sheet.dart';

import '../../support/fake_exercise_name_repository.dart';
import '../../support/fake_settings_repository.dart';
import '../../support/fake_workout_repository.dart';
import '../../support/fake_session_repository.dart';
import '../../support/vulcan_test_app.dart';

Future<void> settleBuilderTest(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// Visible action on one exercise card. Labels such as "Move later" repeat
/// across rows; the semantics name includes the exercise, the button text does not.
Finder _exerciseAction(String exerciseName, String action) {
  final card = find.ancestor(
    of: find.text(exerciseName),
    matching: find.byType(Card),
  );
  expect(card, findsOneWidget);
  return find.descendant(
    of: card,
    matching: find.widgetWithText(TextButton, action),
  );
}

void main() {
  Future<WorkoutBuilderCubit> pumpBuilder(
    WidgetTester tester, {
    FakeWorkoutRepository? workouts,
    FakeExerciseNameRepository? names,
    FakeSettingsRepository? settings,
    int? workoutId,
    ThemeMode themeMode = ThemeMode.light,
    double textScale = 1,
  }) async {
    final cubit = WorkoutBuilderCubit(
      workoutRepository: workouts ?? FakeWorkoutRepository(),
      exerciseNameRepository:
          names ?? FakeExerciseNameRepository(names: ['Bench Press']),
      settingsRepository:
          settings ?? FakeSettingsRepository(unitResult: const Ok(MassUnit.kg)),
      sessionRepository: FakeSessionRepository(),
      workoutId: workoutId,
    );
    addTearDown(cubit.close);
    await cubit.initialize();
    await tester.pumpWidget(
      vulcanMaterialApp(
        themeMode: themeMode,
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: BlocProvider.value(
              value: cubit,
              child: const WorkoutBuilderPage(),
            ),
          ),
        ),
      ),
    );
    await settleBuilderTest(tester);
    return cubit;
  }

  TemplateExercise exercise(String name) => (TemplateExercise.uniform(
    name: name,
    setCount: 3,
    reps: (RepPrescription.fixed(8) as Ok<RepPrescription>).value,
    load: LoadPrescription.noLoad,
    restSeconds: 90,
  ) as Ok<TemplateExercise>).value;

  Future<void> pushBuilder(WidgetTester tester) async {
    final cubit = WorkoutBuilderCubit(
      workoutRepository: FakeWorkoutRepository(),
      exerciseNameRepository: FakeExerciseNameRepository(),
      settingsRepository: FakeSettingsRepository(),
      sessionRepository: FakeSessionRepository(),
    );
    addTearDown(cubit.close);
    await cubit.initialize();
    await tester.pumpWidget(
      vulcanMaterialApp(
        child: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: const WorkoutBuilderPage(),
                      ),
                    ),
                  );
                },
                child: const Text('Open builder'),
              ),
            ),
          ),
        ),
      ),
    );
    await settleBuilderTest(tester);
    await tester.tap(find.text('Open builder'));
    await settleBuilderTest(tester);
  }

  testWidgets('create flow saves valid empty-exercise template', (
    tester,
  ) async {
    final workouts = FakeWorkoutRepository();
    final cubit = await pumpBuilder(tester, workouts: workouts);
    await tester.enterText(
      find.byKey(const Key('workout_builder_name')),
      'Push',
    );
    await tester.tap(find.text('Save workout'));
    await settleBuilderTest(tester);
    expect(workouts.createCalls, 1);
    expect(workouts.lastCreateDraft?.name, 'Push');
    expect(cubit.state.savedTemplate?.name, 'Push');
  });

  testWidgets('dirty back asks to discard', (tester) async {
    await pushBuilder(tester);
    await tester.enterText(
      find.byKey(const Key('workout_builder_name')),
      'Push',
    );
    await tester.pump();
    await tester.pageBack();
    await settleBuilderTest(tester);
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await settleBuilderTest(tester);
    expect(find.text('Open builder'), findsOneWidget);
  });

  testWidgets('clean back pops without confirmation', (tester) async {
    await pushBuilder(tester);
    await tester.pageBack();
    await settleBuilderTest(tester);
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('Open builder'), findsOneWidget);
  });

  testWidgets('reorder, remove confirmation, and save failure retry', (
    tester,
  ) async {
    final workouts = FakeWorkoutRepository()
      ..createResult = const Err(StorageFailure('write failed'));
    final cubit = await pumpBuilder(tester, workouts: workouts);
    await tester.enterText(
      find.byKey(const Key('workout_builder_name')),
      'Leg',
    );
    cubit
      ..addExercise(exercise('Squat'))
      ..addExercise(exercise('Bench'));
    await tester.pump();
    expect(find.text('Squat'), findsOneWidget);
    await tester.tap(_exerciseAction('Squat', 'Move later'));
    await settleBuilderTest(tester);
    await tester.tap(_exerciseAction('Squat', 'Remove'));
    await settleBuilderTest(tester);
    await tester.tap(find.text('Cancel'));
    await settleBuilderTest(tester);
    expect(find.text('Squat'), findsOneWidget);
    await tester.tap(_exerciseAction('Squat', 'Remove'));
    await settleBuilderTest(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await settleBuilderTest(tester);
    expect(find.text('Squat'), findsNothing);
    await tester.tap(find.text('Save workout'));
    await settleBuilderTest(tester);
    expect(find.text('Retry save'), findsOneWidget);
    workouts.createResult = null;
    await tester.tap(find.text('Retry save'));
    await settleBuilderTest(tester);
    expect(workouts.createCalls, 2);
    expect(cubit.state.savedTemplate?.name, 'Leg');
  });

  testWidgets(
    'exercise editor supports free text, suggestions, kg, and text scale',
    (tester) async {
      final initial = (TemplateExercise.uniform(
        name: 'Bench Press',
        setCount: 3,
        reps: (RepPrescription.fixed(8) as Ok<RepPrescription>).value,
        load: (LoadPrescription.absolute(
          100000000,
        ) as Ok<LoadPrescription>).value,
        restSeconds: 90,
      ) as Ok<TemplateExercise>).value;
      await tester.pumpWidget(
        vulcanMaterialApp(
          child: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.6)),
              child: Material(
                child: TemplateExerciseEditorSheet(
                  massUnit: MassUnit.kg,
                  suggestions: FakeExerciseNameRepository(
                    names: ['Bench Press'],
                  ).suggestions,
                  initial: initial,
                ),
              ),
            ),
          ),
        ),
      );
      await settleBuilderTest(tester);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('template_exercise_load')))
            .controller
            ?.text,
        '100',
      );
      await tester.enterText(
        find.byKey(const Key('template_exercise_name')),
        'ben',
      );
      await settleBuilderTest(tester);
      expect(find.text('Bench Press'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renders in dark theme without overflow', (tester) async {
    await pumpBuilder(tester, themeMode: ThemeMode.dark, textScale: 1.6);
    expect(tester.takeException(), isNull);
    expect(find.text('New workout'), findsOneWidget);
  });

  testWidgets('disables all exercise reordering controls while saving', (
    tester,
  ) async {
    final workouts = FakeWorkoutRepository()
      ..createDelay = const Duration(milliseconds: 100);
    final cubit = await pumpBuilder(tester, workouts: workouts);
    cubit.addExercise(exercise('Squat'));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('workout_builder_name')),
      'Leg day',
    );

    await tester.tap(find.text('Save workout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(cubit.state.isSaving, isTrue);
    expect(find.byType(ReorderableDelayedDragStartListener), findsNothing);
    final moveLater = tester.widget<TextButton>(
      _exerciseAction('Squat', 'Move later'),
    );
    expect(moveLater.onPressed, isNull);
    expect(
      tester.widget<BackButton>(find.byType(BackButton)).onPressed,
      isNull,
    );
    await tester.pump(const Duration(milliseconds: 100));
  });
}
