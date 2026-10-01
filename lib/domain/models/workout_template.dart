import '../../core/failure.dart';
import '../../core/result.dart';
import 'exercise_name.dart';
import 'prescriptions.dart';

final class TemplateSet {
  const TemplateSet._({
    required this.reps,
    required this.load,
    required this.restSeconds,
  });
  final RepPrescription reps;
  final LoadPrescription load;
  final int restSeconds;

  static Result<TemplateSet> create({
    required RepPrescription reps,
    required LoadPrescription load,
    required int restSeconds,
  }) => restSeconds < 0
      ? const Err(ValidationFailure('Rest seconds must not be negative.'))
      : Ok(TemplateSet._(reps: reps, load: load, restSeconds: restSeconds));

  @override
  bool operator ==(Object other) =>
      other is TemplateSet &&
      other.reps == reps &&
      other.load == load &&
      other.restSeconds == restSeconds;

  @override
  int get hashCode => Object.hash(reps, load, restSeconds);
}

final class TemplateExercise {
  TemplateExercise._({
    required this.name,
    required this.normalizedName,
    required List<TemplateSet> sets,
    required this.supersetGroup,
  }) : sets = List.unmodifiable(sets);
  final String name;
  final String normalizedName;
  final List<TemplateSet> sets;
  final int? supersetGroup;
  int get plannedSets => sets.length;
  RepType get repType => sets.first.reps.type;
  LoadType get loadType => sets.first.load.type;
  TemplateSet get lastSet => sets.last;

  static Result<TemplateExercise> create({
    required String name,
    required List<TemplateSet> sets,
    int? supersetGroup,
  }) {
    final display = validateDisplayName(name);
    if (display case Err(:final failure)) {
      return Err(failure);
    }
    if (sets.isEmpty) {
      return const Err(
        ValidationFailure('An exercise needs at least one set.'),
      );
    }
    final first = sets.first;
    if (sets.any(
      (set) =>
          set.reps.type != first.reps.type || set.load.type != first.load.type,
    )) {
      return const Err(
        ValidationFailure(
          'All sets in an exercise must use the same rep and load mode.',
        ),
      );
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
        sets: sets,
        supersetGroup: supersetGroup,
      ),
    );
  }

  static Result<TemplateExercise> uniform({
    required String name,
    required int setCount,
    required RepPrescription reps,
    required LoadPrescription load,
    required int restSeconds,
    int? supersetGroup,
  }) {
    if (setCount < 1) {
      return const Err(ValidationFailure('Planned sets must be at least 1.'));
    }
    final set = TemplateSet.create(
      reps: reps,
      load: load,
      restSeconds: restSeconds,
    );
    if (set case Err(:final failure)) return Err(failure);
    return create(
      name: name,
      sets: List.filled(setCount, (set as Ok<TemplateSet>).value),
      supersetGroup: supersetGroup,
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
