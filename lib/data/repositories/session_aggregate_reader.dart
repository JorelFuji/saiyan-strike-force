// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:drift/drift.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/active_session.dart';
import '../database/app_database.dart';
import 'session_snapshot_mapper.dart';

/// Maps one session's persisted graph; it owns no transaction or error policy.
final class SessionAggregateReader {
  SessionAggregateReader(this.database);
  final AppDatabase database;

  Future<Result<ActiveSession>> load(int sessionId) async {
    final row = await (database.select(
      database.session,
    )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    if (row == null)
      return const Err(NotFoundFailure('Session was not found.'));
    final exerciseRows =
        await (database.select(database.sessionExercise)
              ..where((t) => t.sessionId.equals(sessionId))
              ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
            .get();
    final exercises = <SessionExerciseSnapshot>[];
    for (final exerciseRow in exerciseRows) {
      final setRows =
          await (database.select(database.sessionSet)
                ..where((t) => t.sessionExerciseId.equals(exerciseRow.id))
                ..orderBy([(t) => OrderingTerm.asc(t.setIndex)]))
              .get();
      final sets = <SessionSetSnapshot>[];
      for (final set in setRows) {
        final mapped = mapSessionSetRow(set);
        if (mapped case Err(:final failure)) return Err(failure);
        sets.add((mapped as Ok).value);
      }
      final mapped = mapSessionExerciseRow(exerciseRow, sets);
      if (mapped case Err(:final failure)) return Err(failure);
      exercises.add((mapped as Ok).value);
    }
    return mapSessionAggregate(row, exercises);
  }

  Stream<Result<ActiveSession>> watch(int sessionId) async* {
    final trigger = database.customSelect(
      'SELECT s.id FROM session s LEFT JOIN session_exercise se ON se.session_id = s.id LEFT JOIN session_set ss ON ss.session_exercise_id = se.id WHERE s.id = ?',
      variables: [Variable.withInt(sessionId)],
      readsFrom: {
        database.session,
        database.sessionExercise,
        database.sessionSet,
      },
    );
    yield await load(sessionId);
    await for (final _ in trigger.watch()) {
      yield await load(sessionId);
    }
  }
}
