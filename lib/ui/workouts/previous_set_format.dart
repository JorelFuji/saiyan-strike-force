import '../../domain/models/exercise_history.dart';
import '../../domain/models/mass.dart';
import '../../domain/models/prescriptions.dart';
import '../core/formatters/load_formatter.dart';

String formatPreviousSet(ExerciseHistoryCompletedSet? set, MassUnit unit) {
  if (set == null) return '—';

  final reps = formatCommittedReps(set.actual.reps);
  return switch (set.actual.load) {
    NoLoad() || BodyweightLoad() => '$reps reps',
    _ => '${formatCommittedLoad(set.actual.load, unit)} × $reps',
  };
}
