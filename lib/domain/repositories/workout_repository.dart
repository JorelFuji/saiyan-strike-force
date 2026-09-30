import '../../core/result.dart';
import '../models/workout_template.dart';

abstract interface class WorkoutRepository {
  Stream<Result<List<WorkoutTemplate>>> watchAll({
    bool includeArchived = false,
  });
  Future<Result<WorkoutTemplate?>> getById(int id);
  Future<Result<WorkoutTemplate>> create(WorkoutTemplateDraft draft);
  Future<Result<WorkoutTemplate>> update(WorkoutTemplate template);
  Future<Result<WorkoutTemplate>> duplicate(int id);
  Future<Result<WorkoutTemplate>> archive(int id);

  /// Clears archive metadata only; it never rewrites template exercises.
  Future<Result<WorkoutTemplate>> restore(int id);
  Future<Result<void>> delete(int id);
}
