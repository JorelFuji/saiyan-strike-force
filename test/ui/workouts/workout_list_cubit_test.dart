import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';
import 'package:vulcan_fitness/ui/workouts/workout_list_cubit.dart';
import 'package:vulcan_fitness/ui/workouts/workout_list_state.dart';

import '../../support/fake_workout_repository.dart';

void main() {
  WorkoutTemplate template(int id, String name, {bool archived = false}) =>
      (WorkoutTemplate.create(
        id: id,
        name: name,
        createdAt: DateTime.utc(2026, 9, id),
        archivedAt: archived ? DateTime.utc(2026, 9, 29) : null,
      ) as Ok<WorkoutTemplate>).value;

  test(
    'uses one inclusive stream and derives filter and normalized search',
    () async {
      final repository = FakeWorkoutRepository(
        seed: [
          template(1, 'Push Day'),
          template(2, 'Pull Day', archived: true),
        ],
      );
      final cubit = WorkoutListCubit(workoutRepository: repository)
        ..initialize();
      await pumpEventQueue();

      expect(repository.watchCalls, 1);
      expect(cubit.state.visibleTemplates.single.name, 'Push Day');
      cubit.setQuery(' push ');
      expect(cubit.state.query, 'push');
      expect(cubit.state.visibleTemplates.single.name, 'Push Day');
      cubit.setFilter(WorkoutListFilter.archived);
      expect(cubit.state.visibleTemplates, isEmpty);
      cubit.setQuery('PULL');
      expect(cubit.state.visibleTemplates.single.name, 'Pull Day');
      await cubit.close();
    },
  );

  test(
    'archive is committed through the repository and signals one-shot undo',
    () async {
      final repository = FakeWorkoutRepository(seed: [template(1, 'Push')]);
      final cubit = WorkoutListCubit(workoutRepository: repository)
        ..initialize();
      await pumpEventQueue();

      await cubit.archive(1);
      expect(repository.archiveCalls, 1);
      expect(cubit.state.visibleTemplates, isEmpty);
      expect(cubit.state.postCommitArchiveId, 1);
      cubit.consumePostCommitArchive();
      expect(cubit.state.postCommitArchiveId, isNull);
      await cubit.restore(1);
      expect(repository.restoreCalls, 1);
      expect(cubit.state.visibleTemplates.single.name, 'Push');
      await cubit.close();
    },
  );

  test('failed action retains rows and is retryable', () async {
    final repository = FakeWorkoutRepository(seed: [template(1, 'Push')])
      ..archiveResult = const Err(StorageFailure('write failed'));
    final cubit = WorkoutListCubit(workoutRepository: repository)..initialize();
    await pumpEventQueue();

    await cubit.archive(1);
    expect(cubit.state.visibleTemplates.single.name, 'Push');
    expect(cubit.state.failureMessage, 'write failed');
    repository.archiveResult = null;
    await cubit.retry();
    expect(repository.archiveCalls, 2);
    expect(cubit.state.visibleTemplates, isEmpty);
    await cubit.close();
  });

  test('retries an inclusive stream after a load failure', () async {
    final repository = FakeWorkoutRepository(seed: [template(1, 'Push')]);
    final cubit = WorkoutListCubit(workoutRepository: repository)..initialize();
    await pumpEventQueue();
    repository.emitFailure(const StorageFailure('read failed'));
    await pumpEventQueue();

    expect(cubit.state.loadPhase, WorkoutListLoadPhase.failure);
    await cubit.retryLoad();
    await pumpEventQueue();
    expect(repository.watchCalls, 2);
    expect(cubit.state.loadPhase, WorkoutListLoadPhase.ready);
    expect(cubit.state.visibleTemplates.single.name, 'Push');
    await cubit.close();
  });
}
