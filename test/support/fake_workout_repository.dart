import 'dart:async';

import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';
import 'package:vulcan_fitness/domain/repositories/workout_repository.dart';

/// Hand-written fake for Planner template-picker tests.
final class FakeWorkoutRepository implements WorkoutRepository {
  FakeWorkoutRepository({List<WorkoutTemplate>? seed}) {
    if (seed != null) {
      _templates.addAll(seed);
    }
  }

  final List<WorkoutTemplate> _templates = [];
  final List<_Watcher> _watchers = [];

  Result<WorkoutTemplate>? archiveResult;
  Result<WorkoutTemplate>? restoreResult;
  Result<WorkoutTemplate>? createResult;
  Result<WorkoutTemplate>? updateResult;
  int archiveCalls = 0;
  int restoreCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  int watchCalls = 0;
  WorkoutTemplateDraft? lastCreateDraft;
  WorkoutTemplate? lastUpdateTemplate;
  int _nextId = 100;
  Duration? createDelay;

  void seed(List<WorkoutTemplate> values) {
    _templates
      ..clear()
      ..addAll(values);
    _emit();
  }

  void emitFailure(Failure failure) {
    for (final watcher in List.of(_watchers)) {
      if (!watcher.controller.isClosed) {
        watcher.controller.add(Err(failure));
      }
    }
  }

  @override
  Stream<Result<List<WorkoutTemplate>>> watchAll({
    bool includeArchived = false,
  }) {
    watchCalls++;
    late StreamController<Result<List<WorkoutTemplate>>> controller;
    controller = StreamController<Result<List<WorkoutTemplate>>>.broadcast(
      onListen: () {
        if (!controller.isClosed) {
          controller.add(Ok(_visible(includeArchived)));
        }
      },
      onCancel: () {
        _watchers.removeWhere((watcher) => watcher.controller == controller);
        unawaited(controller.close());
      },
    );
    _watchers.add(_Watcher(controller, includeArchived));
    return controller.stream;
  }

  @override
  Future<Result<WorkoutTemplate?>> getById(int id) async {
    for (final template in _templates) {
      if (template.id == id) return Ok(template);
    }
    return const Ok(null);
  }

  @override
  Future<Result<WorkoutTemplate>> create(WorkoutTemplateDraft draft) async {
    createCalls++;
    lastCreateDraft = draft;
    if (createDelay != null) {
      await Future<void>.delayed(createDelay!);
    }
    final configured = createResult;
    if (configured != null) return configured;
    final created = WorkoutTemplate.create(
      id: _nextId++,
      name: draft.name,
      notes: draft.notes,
      createdAt: DateTime.utc(2026, 9, 29),
      exercises: draft.exercises,
    );
    if (created case Err(:final failure)) return Err(failure);
    final value = (created as Ok<WorkoutTemplate>).value;
    _templates.add(value);
    _emit();
    return Ok(value);
  }

  @override
  Future<Result<WorkoutTemplate>> update(WorkoutTemplate template) async {
    updateCalls++;
    lastUpdateTemplate = template;
    final configured = updateResult;
    if (configured != null) return configured;
    final index = _templates.indexWhere((row) => row.id == template.id);
    if (index < 0) {
      return const Err(NotFoundFailure('Workout template was not found.'));
    }
    final valid = WorkoutTemplate.create(
      id: template.id,
      name: template.name,
      notes: template.notes,
      createdAt: template.createdAt,
      archivedAt: template.archivedAt,
      exercises: template.exercises,
    );
    if (valid case Err(:final failure)) return Err(failure);
    final value = (valid as Ok<WorkoutTemplate>).value;
    _templates[index] = value;
    _emit();
    return Ok(value);
  }

  @override
  Future<Result<WorkoutTemplate>> duplicate(int id) =>
      throw UnimplementedError();

  @override
  Future<Result<WorkoutTemplate>> archive(int id) async {
    archiveCalls++;
    final configured = archiveResult;
    if (configured != null) return configured;
    final index = _templates.indexWhere((template) => template.id == id);
    if (index < 0) {
      return const Err(NotFoundFailure('Workout template was not found.'));
    }
    final template = _templates[index];
    if (template.archivedAt == null) {
      final updated = WorkoutTemplate.create(
        id: template.id,
        name: template.name,
        notes: template.notes,
        createdAt: template.createdAt,
        archivedAt: DateTime.utc(2026, 9, 29),
        exercises: template.exercises,
      );
      if (updated case Err(:final failure)) return Err(failure);
      _templates[index] = (updated as Ok<WorkoutTemplate>).value;
      _emit();
    }
    return Ok(_templates[index]);
  }

  @override
  Future<Result<WorkoutTemplate>> restore(int id) async {
    restoreCalls++;
    final configured = restoreResult;
    if (configured != null) return configured;
    final index = _templates.indexWhere((template) => template.id == id);
    if (index < 0) {
      return const Err(NotFoundFailure('Workout template was not found.'));
    }
    final template = _templates[index];
    if (template.archivedAt != null) {
      final updated = WorkoutTemplate.create(
        id: template.id,
        name: template.name,
        notes: template.notes,
        createdAt: template.createdAt,
        exercises: template.exercises,
      );
      if (updated case Err(:final failure)) return Err(failure);
      _templates[index] = (updated as Ok<WorkoutTemplate>).value;
      _emit();
    }
    return Ok(_templates[index]);
  }

  @override
  Future<Result<void>> delete(int id) => throw UnimplementedError();

  List<WorkoutTemplate> _visible(bool includeArchived) {
    return _templates
        .where((template) => includeArchived || template.archivedAt == null)
        .toList();
  }

  void _emit() {
    for (final watcher in List.of(_watchers)) {
      if (!watcher.controller.isClosed) {
        watcher.controller.add(Ok(_visible(watcher.includeArchived)));
      }
    }
  }
}

final class _Watcher {
  const _Watcher(this.controller, this.includeArchived);

  final StreamController<Result<List<WorkoutTemplate>>> controller;
  final bool includeArchived;
}
