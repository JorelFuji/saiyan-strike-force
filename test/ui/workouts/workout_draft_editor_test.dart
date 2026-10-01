import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/domain/models/workout_template.dart';
import 'package:vulcan_fitness/ui/workouts/workout_draft_editor.dart';

void main() {
  test('allocates stable distinct exercise and set keys', () {
    final editor = WorkoutDraftEditor();
    final set = (TemplateSet.create(
      reps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      load: const NoLoad(),
      restSeconds: 60,
    ) as Ok<TemplateSet>).value;
    final exercise = (TemplateExercise.create(
      name: 'Squat',
      sets: [set],
    ) as Ok<TemplateExercise>).value;
    final first = editor.row(exercise);
    final second = editor.row(exercise);
    expect(first.key, isNot(second.key));
    expect(first.setKeys.single, isNot(second.setKeys.single));
  });
}
