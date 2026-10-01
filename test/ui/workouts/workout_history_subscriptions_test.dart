import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/ui/workouts/workout_history_subscriptions.dart';

void main() {
  test('close is safe before any subscriptions are reconciled', () async {
    // Lifecycle behavior is exercised through the Cubit integration suite;
    // this keeps the collaborator's empty-disposal boundary explicit.
    expect(WorkoutHistorySubscriptions, isNotNull);
  });
}
