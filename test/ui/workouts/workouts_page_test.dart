import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';
import 'package:vulcan_fitness/ui/workouts/workout_list_cubit.dart';
import 'package:vulcan_fitness/ui/workouts/workouts_page.dart';

import '../../support/fake_workout_repository.dart';
import '../../support/vulcan_test_app.dart';

void main() {
  WorkoutTemplate template(int id, String name, {bool archived = false}) =>
      (WorkoutTemplate.create(
        id: id,
        name: name,
        createdAt: DateTime.utc(2026, 9, id),
        archivedAt: archived ? DateTime.utc(2026, 9, 29) : null,
      ) as Ok<WorkoutTemplate>).value;

  Future<void> pumpPage(
    WidgetTester tester,
    FakeWorkoutRepository repository, {
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: vulcanMaterialApp(
          child: BlocProvider(
            create: (_) =>
                WorkoutListCubit(workoutRepository: repository)..initialize(),
            child: const WorkoutsPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('searches, switches archived view, and exposes named actions', (
    tester,
  ) async {
    await pumpPage(
      tester,
      FakeWorkoutRepository(
        seed: [template(1, 'Push Day'), template(2, 'Pull', archived: true)],
      ),
      textScale: 1.6,
    );
    expect(find.text('Push Day'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'push');
    await tester.pump();
    expect(find.text('Push Day'), findsOneWidget);
    expect(find.byTooltip('Archive Push Day'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.tap(find.text('Archived'));
    await tester.pumpAndSettle();
    expect(find.text('Pull'), findsOneWidget);
    expect(find.byTooltip('Restore Pull'), findsOneWidget);
  });

  testWidgets('archives through menu and undo restores after commit', (
    tester,
  ) async {
    final repository = FakeWorkoutRepository(seed: [template(1, 'Push')]);
    await pumpPage(tester, repository);

    await tester.tap(find.byTooltip('Archive Push'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    expect(find.text('No active workouts.'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Push'), findsOneWidget);
  });

  testWidgets('offers labeled create actions in the app bar and empty state', (
    tester,
  ) async {
    await pumpPage(tester, FakeWorkoutRepository());

    expect(find.text('New workout'), findsOneWidget);
    expect(find.text('Create workout'), findsOneWidget);
    final appBarTarget = tester.getSize(
      find.widgetWithText(TextButton, 'New workout'),
    );
    expect(appBarTarget.height, greaterThanOrEqualTo(48));
    final target = tester.getSize(
      find.widgetWithText(FilledButton, 'Create workout'),
    );
    expect(target.height, greaterThanOrEqualTo(48));
  });
}
