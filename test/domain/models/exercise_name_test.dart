import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/exercise_name.dart';

void main() {
  test(
    'normalizes whitespace and case while preserving display validation',
    () {
      expect(normalizeExerciseName('\t Bench\n  Press '), 'bench press');
      expect(validateDisplayName('  Bench Press  '), isA<Ok<String>>());
      expect(validateDisplayName(' \t\n '), isA<Err<String>>());
    },
  );

  group('ExerciseNameSuggestion', () {
    test('accepts a display whose key follows the normalization policy', () {
      final result = ExerciseNameSuggestion.create(
        display: '  Bench   Press ',
        normalized: 'bench press',
      );

      final value = (result as Ok<ExerciseNameSuggestion>).value;
      expect(value.display, 'Bench   Press');
      expect(value.normalized, 'bench press');
    });

    test('rejects a blank display', () {
      final result = ExerciseNameSuggestion.create(
        display: '  ',
        normalized: '',
      );

      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('rejects a mismatched normalized key', () {
      final result = ExerciseNameSuggestion.create(
        display: 'Bench Press',
        normalized: 'Bench Press',
      );

      expect((result as Err).failure, isA<ValidationFailure>());
    });
  });
}
