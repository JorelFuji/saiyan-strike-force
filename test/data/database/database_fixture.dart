import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';

/// Opens an in-memory database through the test executor.
AppDatabase openTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}

/// Opens a file-backed SQLite database for close/reopen recovery evidence.
Future<({AppDatabase database, File file, Directory directory})>
openFileTestDatabase() async {
  final directory = await Directory.systemTemp.createTemp('vulcan_file_db_');
  final file = File('${directory.path}/test.db');
  final database = AppDatabase(NativeDatabase(file));
  return (database: database, file: file, directory: directory);
}

final DateTime startedAt = DateTime.utc(2026, 9, 1, 15);

Future<int> insertWorkout(AppDatabase db, {String name = 'Push'}) {
  return db
      .into(db.workout)
      .insert(WorkoutCompanion.insert(name: name, createdAt: startedAt));
}

Future<int> insertExercise(
  AppDatabase db, {
  required int workoutId,
  int orderIndex = 0,
  int plannedSets = 3,
  String repType = 'fixed',
  int? targetReps = 5,
  int? minReps,
  int? maxReps,
  String loadType = 'absolute',
  int? weightCanonicalMg = 102058280,
  int? percentage,
  double? targetRpe,
  String? freeformText,
  int restSeconds = 90,
  int? supersetGroup,
}) async {
  final exerciseId = await db
      .into(db.workoutExercise)
      .insert(
        WorkoutExerciseCompanion.insert(
          workoutId: workoutId,
          name: 'Bench Press',
          normalizedName: 'bench press',
          orderIndex: orderIndex,
          plannedSets: plannedSets,
          repType: repType,
          targetReps: Value(targetReps),
          minReps: Value(minReps),
          maxReps: Value(maxReps),
          loadType: loadType,
          weightCanonicalMg: Value(weightCanonicalMg),
          percentage: Value(percentage),
          targetRpe: Value(targetRpe),
          freeformText: Value(freeformText),
          restSeconds: restSeconds,
          supersetGroup: Value(supersetGroup),
        ),
      );
  await db.batch(
    (batch) => batch.insertAll(db.workoutSet, [
      for (var index = 0; index < plannedSets; index++)
        WorkoutSetCompanion.insert(
          workoutExerciseId: exerciseId,
          setIndex: index,
          repType: repType,
          targetReps: Value(targetReps),
          minReps: Value(minReps),
          maxReps: Value(maxReps),
          loadType: loadType,
          weightCanonicalMg: Value(weightCanonicalMg),
          percentage: Value(percentage),
          targetRpe: Value(targetRpe),
          freeformText: Value(freeformText),
          restSeconds: restSeconds,
        ),
    ]),
  );
  return exerciseId;
}

Future<int> insertWorkoutSet(
  AppDatabase db, {
  required int workoutExerciseId,
  int setIndex = 0,
  String repType = 'fixed',
  int? targetReps = 5,
  int? minReps,
  int? maxReps,
  String loadType = 'absolute',
  int? weightCanonicalMg = 102058280,
  int? percentage,
  double? targetRpe,
  String? freeformText,
  int restSeconds = 90,
}) {
  return db
      .into(db.workoutSet)
      .insert(
        WorkoutSetCompanion.insert(
          workoutExerciseId: workoutExerciseId,
          setIndex: setIndex,
          repType: repType,
          targetReps: Value(targetReps),
          minReps: Value(minReps),
          maxReps: Value(maxReps),
          loadType: loadType,
          weightCanonicalMg: Value(weightCanonicalMg),
          percentage: Value(percentage),
          targetRpe: Value(targetRpe),
          freeformText: Value(freeformText),
          restSeconds: restSeconds,
        ),
      );
}

Future<int> insertSchedule(
  AppDatabase db, {
  required int workoutId,
  String date = '2026-09-22',
  int? startTime,
  String? label,
  String status = 'planned',
  int? sessionId,
}) {
  return db
      .into(db.scheduleEntry)
      .insert(
        ScheduleEntryCompanion.insert(
          workoutId: workoutId,
          date: date,
          startTime: Value(startTime),
          label: Value(label),
          status: status,
          sessionId: Value(sessionId),
        ),
      );
}

Future<int> insertSession(
  AppDatabase db, {
  int? workoutId,
  int? scheduleEntryId,
  String status = 'running',
  String workoutNameSnapshot = 'Push',
  DateTime? startedAtOverride,
  DateTime? endedAt,
  String timezone = 'America/Denver',
  DateTime? restStartedAt,
  int? restDurationSeconds,
  DateTime? restTargetAt,
  bool includeRest = false,
}) {
  final sessionStartedAt = startedAtOverride ?? startedAt;
  final restStart = includeRest
      ? (restStartedAt ?? sessionStartedAt)
      : restStartedAt;
  final restDuration = includeRest
      ? (restDurationSeconds ?? 90)
      : restDurationSeconds;
  final restTarget = includeRest
      ? (restTargetAt ?? restStart?.add(Duration(seconds: restDuration ?? 0)))
      : restTargetAt;

  return db
      .into(db.session)
      .insert(
        SessionCompanion.insert(
          workoutId: Value(workoutId),
          scheduleEntryId: Value(scheduleEntryId),
          workoutNameSnapshot: workoutNameSnapshot,
          startedAt: sessionStartedAt,
          endedAt: Value(endedAt),
          timezone: timezone,
          status: status,
          restStartedAt: Value(restStart),
          restDurationSeconds: Value(restDuration),
          restTargetAt: Value(restTarget),
        ),
      );
}

Future<int> insertSessionExercise(
  AppDatabase db, {
  required int sessionId,
  int orderIndex = 0,
  String nameSnapshot = 'Bench Press',
  String normalizedName = 'bench press',
}) {
  return db
      .into(db.sessionExercise)
      .insert(
        SessionExerciseCompanion.insert(
          sessionId: sessionId,
          nameSnapshot: nameSnapshot,
          normalizedName: normalizedName,
          orderIndex: orderIndex,
          plannedSets: 3,
          plannedRepType: 'fixed',
          plannedTargetReps: const Value(5),
          plannedLoadType: 'absolute',
          plannedWeightCanonicalMg: const Value(102058280),
          plannedRestSeconds: 90,
        ),
      );
}

Future<int> insertSet(
  AppDatabase db, {
  required int sessionExerciseId,
  int setIndex = 0,
  bool completed = false,
  DateTime? completedAt,
  double? rpe,
  String plannedRepType = 'fixed',
  int? plannedTargetReps = 5,
  int? plannedMinReps,
  int? plannedMaxReps,
  String plannedLoadType = 'absolute',
  int? plannedWeightCanonicalMg = 102058280,
  int? plannedPercentage,
  double? plannedTargetRpe,
  String? plannedFreeformText,
  String? actualRepType,
  int? actualTargetReps,
  int? actualMinReps,
  int? actualMaxReps,
  String? actualLoadType,
  int? actualWeightCanonicalMg,
  int? actualPercentage,
  double? actualTargetRpe,
  String? actualFreeformText,
  int? plannedRestSeconds,
}) {
  return db
      .into(db.sessionSet)
      .insert(
        SessionSetCompanion.insert(
          sessionExerciseId: sessionExerciseId,
          setIndex: setIndex,
          plannedRepType: plannedRepType,
          plannedTargetReps: Value(plannedTargetReps),
          plannedMinReps: Value(plannedMinReps),
          plannedMaxReps: Value(plannedMaxReps),
          plannedLoadType: plannedLoadType,
          plannedWeightCanonicalMg: Value(plannedWeightCanonicalMg),
          plannedPercentage: Value(plannedPercentage),
          plannedTargetRpe: Value(plannedTargetRpe),
          plannedFreeformText: Value(plannedFreeformText),
          actualRepType: Value(actualRepType),
          actualTargetReps: Value(actualTargetReps),
          actualMinReps: Value(actualMinReps),
          actualMaxReps: Value(actualMaxReps),
          actualLoadType: Value(actualLoadType),
          actualWeightCanonicalMg: Value(actualWeightCanonicalMg),
          actualPercentage: Value(actualPercentage),
          actualTargetRpe: Value(actualTargetRpe),
          actualFreeformText: Value(actualFreeformText),
          plannedRestSeconds: Value(plannedRestSeconds),
          rpe: Value(rpe),
          completed: completed,
          completedAt: Value(completedAt),
        ),
      );
}
