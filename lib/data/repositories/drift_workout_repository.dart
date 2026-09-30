import 'package:drift/drift.dart';

import '../../core/clock.dart';
import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/prescriptions.dart';
import '../../domain/models/workout_template.dart';
import '../../domain/repositories/workout_repository.dart';
import '../database/app_database.dart';
import 'workout_exercise_mapper.dart';

final class DriftWorkoutRepository implements WorkoutRepository {
  DriftWorkoutRepository(this.database, this.clock);

  final AppDatabase database;
  final Clock clock;

  @override
  Stream<Result<List<WorkoutTemplate>>> watchAll({
    bool includeArchived = false,
  }) {
    final query = database.select(database.workout)
      ..orderBy([
        (table) => OrderingTerm.asc(table.createdAt),
        (table) => OrderingTerm.asc(table.id),
      ]);
    if (!includeArchived) {
      query.where((table) => table.archivedAt.isNull());
    }
    return () async* {
      try {
        await for (final rows in query.watch()) {
          final values = <WorkoutTemplate>[];
          var mappingFailed = false;
          for (final row in rows) {
            final mapped = await _readRow(row);
            if (mapped case Err(:final failure)) {
              yield Err<List<WorkoutTemplate>>(failure);
              mappingFailed = true;
              continue;
            }
            values.add((mapped as Ok<WorkoutTemplate>).value);
          }
          if (!mappingFailed) {
            yield Ok<List<WorkoutTemplate>>(values);
          }
        }
      } on Exception catch (error, stack) {
        yield Err<List<WorkoutTemplate>>(_storageFailure(error, stack));
      }
    }();
  }

  @override
  Future<Result<WorkoutTemplate?>> getById(int id) async {
    try {
      final row = await (database.select(
        database.workout,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) {
        return const Ok(null);
      }
      final mapped = await _readRow(row);
      return switch (mapped) {
        Ok(:final value) => Ok<WorkoutTemplate?>(value),
        Err(:final failure) => Err<WorkoutTemplate?>(failure),
      };
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<WorkoutTemplate>> create(WorkoutTemplateDraft draft) async {
    try {
      final now = clock.now().toUtc();
      final id = await database.transaction(() async {
        final workoutId = await database
            .into(database.workout)
            .insert(
              WorkoutCompanion.insert(
                name: draft.name,
                notes: Value(draft.notes),
                createdAt: now,
              ),
            );
        await _insertExercises(workoutId, draft.exercises);
        return workoutId;
      });
      final result = await getById(id);
      return _requireValue(result);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<WorkoutTemplate>> update(WorkoutTemplate template) async {
    final valid = WorkoutTemplate.create(
      id: template.id,
      name: template.name,
      notes: template.notes,
      createdAt: template.createdAt,
      archivedAt: template.archivedAt,
      exercises: template.exercises,
    );
    if (valid case Err(:final failure)) {
      return Err(failure);
    }
    try {
      await database.transaction(() async {
        final exists = await (database.select(
          database.workout,
        )..where((t) => t.id.equals(template.id))).getSingleOrNull();
        if (exists == null) throw _MissingEntity();
        await (database.update(
          database.workout,
        )..where((t) => t.id.equals(template.id))).write(
          WorkoutCompanion(
            name: Value(template.name),
            notes: Value(template.notes),
            archivedAt: Value(template.archivedAt),
          ),
        );
        await (database.delete(
          database.workoutExercise,
        )..where((t) => t.workoutId.equals(template.id))).go();
        await _insertExercises(template.id, template.exercises);
      });
      final result = await getById(template.id);
      return _requireValue(result);
    } on _MissingEntity {
      return const Err(NotFoundFailure('Workout template was not found.'));
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<WorkoutTemplate>> duplicate(int id) async {
    final source = await getById(id);
    if (source case Err(:final failure)) {
      return Err(failure);
    }
    final template = (source as Ok<WorkoutTemplate?>).value;
    if (template == null) {
      return const Err(NotFoundFailure('Workout template was not found.'));
    }
    final draft = WorkoutTemplateDraft.create(
      name: template.name,
      notes: template.notes,
      exercises: template.exercises,
    );
    if (draft case Err(:final failure)) {
      return Err(failure);
    }
    return create((draft as Ok<WorkoutTemplateDraft>).value);
  }

  @override
  Future<Result<WorkoutTemplate>> archive(int id) async {
    try {
      final existing = await (database.select(
        database.workout,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing == null) {
        return const Err(NotFoundFailure('Workout template was not found.'));
      }
      if (existing.archivedAt == null) {
        await (database.update(database.workout)..where((t) => t.id.equals(id)))
            .write(WorkoutCompanion(archivedAt: Value(clock.now().toUtc())));
      }
      final result = await getById(id);
      return _requireValue(result);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<WorkoutTemplate>> restore(int id) async {
    try {
      final existing = await (database.select(
        database.workout,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing == null) {
        return const Err(NotFoundFailure('Workout template was not found.'));
      }
      if (existing.archivedAt != null) {
        await (database.update(database.workout)..where((t) => t.id.equals(id)))
            .write(const WorkoutCompanion(archivedAt: Value(null)));
      }
      return _requireValue(await getById(id));
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> delete(int id) async {
    try {
      final changed = await (database.delete(
        database.workout,
      )..where((t) => t.id.equals(id))).go();
      if (changed == 0) {
        return const Err(NotFoundFailure('Workout template was not found.'));
      }
      return const Ok(null);
    } on Exception catch (error, stack) {
      return Err(_storageFailure(error, stack));
    }
  }

  Future<void> _insertExercises(
    int workoutId,
    List<TemplateExercise> exercises,
  ) async {
    if (exercises.isEmpty) {
      return;
    }
    await database.batch(
      (batch) => batch.insertAll(database.workoutExercise, [
        for (var index = 0; index < exercises.length; index++)
          _toCompanion(workoutId, index, exercises[index]),
      ]),
    );
  }

  Future<Result<WorkoutTemplate>> _readRow(WorkoutData row) async {
    final children =
        await (database.select(database.workoutExercise)
              ..where((t) => t.workoutId.equals(row.id))
              ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
            .get();
    final exercises = <TemplateExercise>[];
    for (final child in children) {
      final mapped = mapWorkoutExercise(child);
      if (mapped case Err(:final failure)) {
        return Err(failure);
      }
      exercises.add((mapped as Ok<TemplateExercise>).value);
    }
    final result = WorkoutTemplate.create(
      id: row.id,
      name: row.name,
      notes: row.notes,
      createdAt: row.createdAt,
      archivedAt: row.archivedAt,
      exercises: exercises,
    );
    return result;
  }

  WorkoutExerciseCompanion _toCompanion(
    int workoutId,
    int index,
    TemplateExercise exercise,
  ) {
    final rep = exercise.reps;
    final load = exercise.load;
    return WorkoutExerciseCompanion.insert(
      workoutId: workoutId,
      name: exercise.name,
      normalizedName: exercise.normalizedName,
      orderIndex: index,
      plannedSets: exercise.plannedSets,
      repType: rep.type.wireValue,
      targetReps: Value(rep is FixedReps ? rep.reps : null),
      minReps: Value(rep is RepRange ? rep.min : null),
      maxReps: Value(rep is RepRange ? rep.max : null),
      loadType: load.type.wireValue,
      weightCanonicalMg: Value(load is AbsoluteLoad ? load.milligrams : null),
      percentage: Value(load is PercentageLoad ? load.percentage : null),
      targetRpe: Value(load is TargetRpeLoad ? load.rpe : null),
      freeformText: Value(load is TextLoad ? load.text : null),
      restSeconds: exercise.restSeconds,
      supersetGroup: Value(exercise.supersetGroup),
    );
  }

  Result<WorkoutTemplate> _requireValue(Result<WorkoutTemplate?> result) =>
      switch (result) {
        Ok(:final value) when value != null => Ok(value),
        Ok() => const Err(NotFoundFailure('Workout template was not found.')),
        Err(:final failure) => Err(failure),
      };

  StorageFailure _storageFailure(Object error, StackTrace stack) =>
      StorageFailure(
        'Workout template storage operation failed.',
        cause: error,
        stackTrace: stack,
      );
}

final class _MissingEntity implements Exception {}
