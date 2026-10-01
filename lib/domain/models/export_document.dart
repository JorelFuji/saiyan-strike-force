/// Versioned, portable representation of the app's local training data.
///
/// Maps are intentionally hand-built so the public JSON contract does not
/// depend on Drift row types or generated serializers.
final class ExportDocument {
  const ExportDocument({
    required this.exportedAt,
    required this.appVersion,
    required this.collections,
  });

  static const schemaVersion = 2;
  final DateTime exportedAt;
  final String appVersion;
  final ExportCollections collections;

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'appVersion': appVersion,
    'collections': collections.toJson(),
  };
}

final class ExportCollections {
  ExportCollections({
    required List<Map<String, Object?>> settings,
    required List<Map<String, Object?>> workouts,
    required List<Map<String, Object?>> workoutExercises,
    required List<Map<String, Object?>> workoutSets,
    required List<Map<String, Object?>> scheduleEntries,
    required List<Map<String, Object?>> sessions,
    required List<Map<String, Object?>> sessionExercises,
    required List<Map<String, Object?>> sessionSets,
  }) : settings = _freeze(settings),
       workouts = _freeze(workouts),
       workoutExercises = _freeze(workoutExercises),
       workoutSets = _freeze(workoutSets),
       scheduleEntries = _freeze(scheduleEntries),
       sessions = _freeze(sessions),
       sessionExercises = _freeze(sessionExercises),
       sessionSets = _freeze(sessionSets);

  static List<Map<String, Object?>> _freeze(List<Map<String, Object?>> rows) =>
      List.unmodifiable(rows.map(Map<String, Object?>.unmodifiable));

  final List<Map<String, Object?>> settings;
  final List<Map<String, Object?>> workouts;
  final List<Map<String, Object?>> workoutExercises;
  final List<Map<String, Object?>> workoutSets;
  final List<Map<String, Object?>> scheduleEntries;
  final List<Map<String, Object?>> sessions;
  final List<Map<String, Object?>> sessionExercises;
  final List<Map<String, Object?>> sessionSets;

  Map<String, Object?> toJson() => {
    'settings': settings,
    'workouts': workouts,
    'workoutExercises': workoutExercises,
    'workoutSets': workoutSets,
    'scheduleEntries': scheduleEntries,
    'sessions': sessions,
    'sessionExercises': sessionExercises,
    'sessionSets': sessionSets,
  };
}

final class ExportShareOrigin {
  const ExportShareOrigin({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
  final double x;
  final double y;
  final double width;
  final double height;
}

enum ExportShareOutcome { shared, dismissed, unavailable }
