import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/ui/active_session/superset_rounds.dart';

void main() {
  SessionSetSnapshot set(
    int id,
    int exerciseId,
    int index, {
    bool done = false,
  }) => (SessionSetSnapshot.create(
    id: id,
    sessionExerciseId: exerciseId,
    setIndex: index,
    plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
    plannedLoad: LoadPrescription.bodyweight,
    completed: done,
    completedAt: done ? DateTime.utc(2026, 9, 30) : null,
  ) as Ok<SessionSetSnapshot>).value;

  SessionExerciseSnapshot exercise(
    int id,
    int group,
    List<SessionSetSnapshot> sets,
  ) => (SessionExerciseSnapshot.create(
    id: id,
    sessionId: 1,
    nameSnapshot: 'Exercise $id',
    orderIndex: id - 1,
    plannedSets: sets.length,
    plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
    plannedLoad: LoadPrescription.bodyweight,
    plannedRestSeconds: 90,
    supersetGroup: group,
    sets: sets,
  ) as Ok<SessionExerciseSnapshot>).value;

  test(
    'selects paired members in round order and boundary is final member',
    () {
      final exercises = [
        exercise(1, 0, [set(1, 1, 0), set(2, 1, 1)]),
        exercise(2, 0, [set(3, 2, 0), set(4, 2, 1)]),
      ];
      expect(nextSetInSupersetSession(exercises)?.id, 1);
      expect(completionEndsRound(exercises, 1), isFalse);
      final afterFirst = [
        exercise(1, 0, [set(1, 1, 0, done: true), set(2, 1, 1)]),
        exercises[1],
      ];
      expect(nextSetInSupersetSession(afterFirst)?.id, 3);
      expect(completionEndsRound(afterFirst, 3), isTrue);
    },
  );

  test('skips an exhausted partner in an unequal final round', () {
    final exercises = [
      exercise(1, 0, [set(1, 1, 0, done: true), set(2, 1, 1)]),
      exercise(2, 0, [set(3, 2, 0, done: true)]),
    ];
    expect(nextSetInSupersetSession(exercises)?.id, 2);
    expect(completionEndsRound(exercises, 2), isTrue);
  });

  test('malformed singleton and non-contiguous groups behave as ordinary exercises', () {
    final exercises = [
      exercise(1, 4, [set(1, 1, 0)]),
      exercise(2, 0, [set(2, 2, 0)]),
      exercise(3, 4, [set(3, 3, 0)]),
    ];
    expect(nextSetInSupersetSession(exercises)?.id, 1);
    expect(completionEndsRound(exercises, 1), isTrue);
  });
}
