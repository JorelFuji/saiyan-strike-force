import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/domain/models/exercise_history.dart';
import 'package:vulcan_fitness/domain/models/exercise_name.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';

void main() {
  final day = (CalendarDate.fromIso('2026-09-01') as Ok<CalendarDate>).value;

  ActualPrescription absoluteFixed({int mg = 1000000, int reps = 5}) {
    return (ActualPrescription.create(
      reps: (RepPrescription.fixed(reps) as Ok<RepPrescription>).value,
      load: (LoadPrescription.absolute(mg) as Ok<LoadPrescription>).value,
    ) as Ok<ActualPrescription>).value;
  }

  ExerciseHistoryCompletedSet completedSet({
    int setIndex = 0,
    ActualPrescription? actual,
  }) {
    return (ExerciseHistoryCompletedSet.create(
      setIndex: setIndex,
      actual: actual ?? absoluteFixed(),
    ) as Ok<ExerciseHistoryCompletedSet>).value;
  }

  test('ExerciseName.forLookup normalizes route input', () {
    final result = ExerciseName.forLookup('  Bench   Press ');
    expect(result, isA<Ok<ExerciseName>>());
    final name = (result as Ok<ExerciseName>).value;
    expect(name.display, 'Bench   Press');
    expect(name.normalized, 'bench press');
  });

  test('ExerciseHistoryEntry rejects invalid ids and empty sets', () {
    expect(
      ExerciseHistoryEntry.create(
        sessionExerciseId: 0,
        sessionId: 1,
        nameSnapshot: 'Bench',
        normalizedName: 'bench',
        startedAt: DateTime.utc(2026, 9, 1),
        sessionOn: day,
        completedSets: [completedSet()],
      ),
      isA<Err<ExerciseHistoryEntry>>(),
    );
    expect(
      ExerciseHistoryEntry.create(
        sessionExerciseId: 1,
        sessionId: 1,
        nameSnapshot: 'Bench',
        normalizedName: 'squat',
        startedAt: DateTime.utc(2026, 9, 1),
        sessionOn: day,
        completedSets: [completedSet()],
      ),
      isA<Err<ExerciseHistoryEntry>>(),
    );
    expect(
      ExerciseHistoryEntry.create(
        sessionExerciseId: 1,
        sessionId: 1,
        nameSnapshot: 'Bench',
        normalizedName: 'bench',
        startedAt: DateTime.utc(2026, 9, 1),
        sessionOn: day,
        completedSets: const [],
      ),
      isA<Err<ExerciseHistoryEntry>>(),
    );
  });

  test('ExerciseHistoryEntry preserves structured actual variants', () {
    final variants = <ExerciseHistoryCompletedSet>[
      completedSet(
        setIndex: 0,
        actual: (ActualPrescription.create(
          reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
          load: LoadPrescription.bodyweight,
        ) as Ok<ActualPrescription>).value,
      ),
      completedSet(
        setIndex: 1,
        actual: (ActualPrescription.create(
          reps: (RepPrescription.range(3, 7) as Ok<RepPrescription>).value,
          load: (LoadPrescription.percentage(80) as Ok<LoadPrescription>).value,
        ) as Ok<ActualPrescription>).value,
      ),
      completedSet(
        setIndex: 2,
        actual: (ActualPrescription.create(
          reps: const Amrap(),
          load: (LoadPrescription.targetRpe(8.5) as Ok<LoadPrescription>).value,
        ) as Ok<ActualPrescription>).value,
      ),
      completedSet(
        setIndex: 3,
        actual: (ActualPrescription.create(
          reps: (RepPrescription.fixed(10) as Ok<RepPrescription>).value,
          load: (LoadPrescription.text('chains') as Ok<LoadPrescription>).value,
        ) as Ok<ActualPrescription>).value,
      ),
    ];
    final entry = ExerciseHistoryEntry.create(
      sessionExerciseId: 10,
      sessionId: 3,
      nameSnapshot: 'Bench Press',
      normalizedName: 'bench press',
      startedAt: DateTime.utc(2026, 9, 1, 15),
      sessionOn: day,
      completedSets: variants,
    );
    expect(entry, isA<Ok<ExerciseHistoryEntry>>());
    final value = (entry as Ok<ExerciseHistoryEntry>).value;
    expect(value.completedSets, hasLength(4));
    expect(value.completedSets[1].actual.load, isA<PercentageLoad>());
    expect(value.completedSets[2].actual.reps, isA<Amrap>());
    expect(value.startedAt.isUtc, isTrue);
  });

  test('ExerciseHistoryEntry requires ascending set order', () {
    expect(
      ExerciseHistoryEntry.create(
        sessionExerciseId: 1,
        sessionId: 1,
        nameSnapshot: 'Bench',
        normalizedName: 'bench',
        startedAt: DateTime.utc(2026, 9, 1),
        sessionOn: day,
        completedSets: [completedSet(setIndex: 1), completedSet(setIndex: 0)],
      ),
      isA<Err<ExerciseHistoryEntry>>(),
    );
  });
}
