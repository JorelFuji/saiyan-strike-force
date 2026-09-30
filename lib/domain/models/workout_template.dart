import '../../core/failure.dart';
import '../../core/result.dart';
import 'exercise_name.dart';
import 'prescriptions.dart';

final class TemplateExercise {
  TemplateExercise._({
    required this.name,
    required this.normalizedName,
    required this.plannedSets,
    required this.reps,
    required this.load,
    required this.restSeconds,
    required this.supersetGroup,
  });
  final String name;
  final String normalizedName;
  final int plannedSets;
  final RepPrescription reps;
  final LoadPrescription load;
  final int restSeconds;
  final int? supersetGroup;

  static Result<TemplateExercise> create({
    required String name,
    required int plannedSets,
    required RepPrescription reps,
    required LoadPrescription load,
    required int restSeconds,
    int? supersetGroup,
  }) {
    final display = validateDisplayName(name);
    if (display case Err(:final failure)) {
      return Err(failure);
    }
    if (plannedSets < 1) {
      return const Err(ValidationFailure('Planned sets must be at least 1.'));
    }
    if (restSeconds < 0) {
      return const Err(ValidationFailure('Rest seconds must not be negative.'));
    }
    if (supersetGroup != null && supersetGroup < 0) {
      return const Err(
        ValidationFailure('Superset group must not be negative.'),
      );
    }
    final trimmed = (display as Ok<String>).value;
    return Ok(
      TemplateExercise._(
        name: trimmed,
        normalizedName: normalizeExerciseName(trimmed),
        plannedSets: plannedSets,
        reps: reps,
        load: load,
        restSeconds: restSeconds,
        supersetGroup: supersetGroup,
      ),
    );
  }
}

final class WorkoutTemplateDraft {
  WorkoutTemplateDraft._(this.name, this.notes, this.exercises);
  final String name;
  final String? notes;
  final List<TemplateExercise> exercises;
  static Result<WorkoutTemplateDraft> create({
    required String name,
    String? notes,
    List<TemplateExercise> exercises = const [],
  }) {
    final display = validateDisplayName(name);
    if (display case Err(:final failure)) {
      return Err(failure);
    }
    return Ok(
      WorkoutTemplateDraft._(
        (display as Ok<String>).value,
        notes,
        List.unmodifiable(exercises),
      ),
    );
  }
}

final class WorkoutTemplate {
  WorkoutTemplate._({
    required this.id,
    required this.name,
    required this.notes,
    required this.createdAt,
    required this.archivedAt,
    required this.exercises,
  });
  final int id;
  final String name;
  final String? notes;
  final DateTime createdAt;
  final DateTime? archivedAt;
  final List<TemplateExercise> exercises;

  static Result<WorkoutTemplate> create({
    required int id,
    required String name,
    String? notes,
    required DateTime createdAt,
    DateTime? archivedAt,
    List<TemplateExercise> exercises = const [],
  }) {
    if (id < 1) {
      return const Err(ValidationFailure('Template ID must be positive.'));
    }
    final draft = WorkoutTemplateDraft.create(
      name: name,
      notes: notes,
      exercises: exercises,
    );
    if (draft case Err(:final failure)) {
      return Err(failure);
    }
    final value = (draft as Ok<WorkoutTemplateDraft>).value;
    return Ok(
      WorkoutTemplate._(
        id: id,
        name: value.name,
        notes: value.notes,
        createdAt: createdAt.toUtc(),
        archivedAt: archivedAt?.toUtc(),
        exercises: value.exercises,
      ),
    );
  }
}
