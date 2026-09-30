import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/domain/models/exercise_history.dart';
import 'package:vulcan_fitness/domain/models/exercise_name.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/repositories/session_repository.dart';
import 'package:vulcan_fitness/domain/repositories/settings_repository.dart';
import 'package:vulcan_fitness/ui/history/exercise_history_cubit.dart';
import 'package:vulcan_fitness/ui/history/exercise_history_page.dart';

import '../../support/fake_session_repository.dart';
import '../../support/fake_settings_repository.dart';
import '../../support/vulcan_test_app.dart';

void main() {
  final exerciseName =
      (ExerciseName.forLookup('Bench Press') as Ok<ExerciseName>).value;
  final day = (CalendarDate.fromIso('2026-09-02') as Ok<CalendarDate>).value;

  ExerciseHistoryEntry historyEntry({
    List<ExerciseHistoryCompletedSet>? sets,
    CalendarDate? on,
  }) {
    final completedSets =
        sets ??
        [
          (ExerciseHistoryCompletedSet.create(
            setIndex: 0,
            actual: (ActualPrescription.create(
              reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
              load: (LoadPrescription.absolute(
                100000000,
              ) as Ok<LoadPrescription>).value,
            ) as Ok<ActualPrescription>).value,
          ) as Ok<ExerciseHistoryCompletedSet>).value,
        ];
    return (ExerciseHistoryEntry.create(
      sessionExerciseId: 1,
      sessionId: 9,
      nameSnapshot: 'Bench Press',
      normalizedName: 'bench press',
      startedAt: DateTime.utc(2026, 9, 2, 15),
      sessionOn: on ?? day,
      completedSets: completedSets,
    ) as Ok<ExerciseHistoryEntry>).value;
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    required FakeSessionRepository sessions,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SessionRepository>.value(value: sessions),
          RepositoryProvider<SettingsRepository>.value(
            value: FakeSettingsRepository(unitResult: const Ok(MassUnit.kg)),
          ),
        ],
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: vulcanMaterialApp(
            child: BlocProvider(
              create: (_) => ExerciseHistoryCubit(
                exerciseName: exerciseName,
                sessionRepository: sessions,
                settingsRepository: FakeSettingsRepository(
                  unitResult: const Ok(MassUnit.kg),
                ),
              )..initialize(),
              child: const ExerciseHistoryPage(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders absolute and non-absolute completed sets', (
    tester,
  ) async {
    final sets = [
      (ExerciseHistoryCompletedSet.create(
        setIndex: 0,
        actual: (ActualPrescription.create(
          reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
          load: (LoadPrescription.absolute(
            100000000,
          ) as Ok<LoadPrescription>).value,
        ) as Ok<ActualPrescription>).value,
      ) as Ok<ExerciseHistoryCompletedSet>).value,
      (ExerciseHistoryCompletedSet.create(
        setIndex: 1,
        actual: (ActualPrescription.create(
          reps: (RepPrescription.fixed(8) as Ok<RepPrescription>).value,
          load: LoadPrescription.bodyweight,
        ) as Ok<ActualPrescription>).value,
      ) as Ok<ExerciseHistoryCompletedSet>).value,
      (ExerciseHistoryCompletedSet.create(
        setIndex: 2,
        actual: (ActualPrescription.create(
          reps: (RepPrescription.fixed(3) as Ok<RepPrescription>).value,
          load: (LoadPrescription.percentage(75) as Ok<LoadPrescription>).value,
        ) as Ok<ActualPrescription>).value,
      ) as Ok<ExerciseHistoryCompletedSet>).value,
    ];
    final sessions = FakeSessionRepository()
      ..exerciseHistorySeedEvents.add(Ok([historyEntry(sets: sets)]));
    await pumpPage(tester, sessions: sessions);

    expect(find.textContaining('100 kg'), findsOneWidget);
    expect(find.textContaining('Bodyweight'), findsOneWidget);
    expect(find.textContaining('75%'), findsOneWidget);
    expect(find.text('Sep 2, 2026'), findsOneWidget);
  });

  testWidgets('shows empty state and invalid route page', (tester) async {
    final sessions = FakeSessionRepository()
      ..exerciseHistorySeedEvents.add(const Ok([]));
    await pumpPage(tester, sessions: sessions);
    expect(
      find.text('No prior performance logged for this exercise.'),
      findsOneWidget,
    );

    await tester.pumpWidget(
      vulcanMaterialApp(child: const ExerciseHistoryInvalidRoutePage()),
    );
    expect(find.text('This exercise history link is invalid.'), findsOneWidget);
  });

  testWidgets('failure shows retry', (tester) async {
    final sessions = FakeSessionRepository()
      ..exerciseHistorySeedEvents.add(const Err(StorageFailure('load failed')));
    await pumpPage(tester, sessions: sessions);
    expect(find.text('load failed'), findsOneWidget);

    sessions.exerciseHistorySeedEvents.clear();
    sessions.exerciseHistorySeedEvents.add(Ok([historyEntry()]));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.textContaining('kg'), findsWidgets);
  });

  testWidgets('large text smoke', (tester) async {
    final sessions = FakeSessionRepository()
      ..exerciseHistorySeedEvents.add(Ok([historyEntry()]));
    await pumpPage(tester, sessions: sessions, textScale: 1.6);
    expect(find.textContaining('kg'), findsWidgets);
  });
}
