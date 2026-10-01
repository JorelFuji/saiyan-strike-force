import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/domain/models/export_document.dart';

void main() {
  test('serializes a stable versioned envelope and all eight collections', () {
    final document = ExportDocument(
      exportedAt: DateTime.parse('2026-09-26T10:00:00-06:00'),
      appVersion: '1.0.0+1',
      collections: ExportCollections(
        settings: const [],
        workouts: const [],
        workoutExercises: const [],
        workoutSets: const [],
        scheduleEntries: const [],
        sessions: const [],
        sessionExercises: const [],
        sessionSets: const [],
      ),
    );
    expect(document.toJson(), {
      'schemaVersion': 2,
      'exportedAt': '2026-09-26T16:00:00.000Z',
      'appVersion': '1.0.0+1',
      'collections': {
        'settings': [],
        'workouts': [],
        'workoutExercises': [],
        'workoutSets': [],
        'scheduleEntries': [],
        'sessions': [],
        'sessionExercises': [],
        'sessionSets': [],
      },
    });
  });

  test(
    'preserves nulls, wire strings, canonical mass, and snapshot divergence',
    () {
      final document = ExportDocument(
        exportedAt: DateTime.utc(2026, 9, 26),
        appVersion: '1.0.0+1',
        collections: ExportCollections(
          settings: const [],
          workouts: const [
            {'id': 4, 'name': 'Current template', 'notes': null},
          ],
          workoutExercises: const [
            {
              'id': 8,
              'workoutId': 4,
              'repType': 'fixed',
              'weightCanonicalMg': 102058280,
            },
          ],
          workoutSets: const [],
          scheduleEntries: const [],
          sessions: const [
            {
              'id': 12,
              'workoutId': null,
              'workoutNameSnapshot': 'Historical snapshot',
              'status': 'running',
              'endedAt': null,
              'timezone': 'America/Denver',
            },
          ],
          sessionExercises: const [
            {'id': 13, 'sessionId': 12, 'plannedWeightCanonicalMg': 102058280},
          ],
          sessionSets: const [
            {
              'id': 14,
              'sessionExerciseId': 13,
              'completed': false,
              'completedAt': null,
              'actualRepType': null,
              'plannedLoadType': 'absolute',
            },
          ],
        ),
      );

      final json = document.toJson();
      final collections = json['collections']! as Map<String, Object?>;
      expect(collections['workoutExercises'], [
        {
          'id': 8,
          'workoutId': 4,
          'repType': 'fixed',
          'weightCanonicalMg': 102058280,
        },
      ]);
      expect(collections['sessions'], [
        {
          'id': 12,
          'workoutId': null,
          'workoutNameSnapshot': 'Historical snapshot',
          'status': 'running',
          'endedAt': null,
          'timezone': 'America/Denver',
        },
      ]);
      expect(collections['sessionSets'], [
        {
          'id': 14,
          'sessionExerciseId': 13,
          'completed': false,
          'completedAt': null,
          'actualRepType': null,
          'plannedLoadType': 'absolute',
        },
      ]);
      expect(
        (collections['workouts'] as List).single,
        containsPair('name', 'Current template'),
      );
    },
  );
}
