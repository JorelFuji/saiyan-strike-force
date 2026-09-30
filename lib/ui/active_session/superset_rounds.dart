import '../../domain/models/active_session.dart';

List<SessionExerciseSnapshot> _validGroup(
  List<SessionExerciseSnapshot> exercises,
  int index,
) {
  final token = exercises[index].supersetGroup;
  if (token == null) return const [];
  var runCount = 0;
  for (var cursor = 0; cursor < exercises.length; cursor++) {
    if (exercises[cursor].supersetGroup != token) continue;
    runCount++;
    while (cursor + 1 < exercises.length &&
        exercises[cursor + 1].supersetGroup == token) {
      cursor++;
    }
  }
  if (runCount != 1) return const [];
  var start = index;
  while (start > 0 && exercises[start - 1].supersetGroup == token) {
    start--;
  }
  var end = index;
  while (end + 1 < exercises.length &&
      exercises[end + 1].supersetGroup == token) {
    end++;
  }
  if (end - start < 1) return const [];
  if (start > 0 && exercises[start - 1].supersetGroup == token) return const [];
  if (end + 1 < exercises.length && exercises[end + 1].supersetGroup == token) {
    return const [];
  }
  return exercises.sublist(start, end + 1);
}

SessionSetSnapshot? nextSetInSupersetSession(
  List<SessionExerciseSnapshot> exercises,
) {
  for (var index = 0; index < exercises.length; index++) {
    final group = _validGroup(exercises, index);
    if (group.isEmpty) {
      final set = exercises[index].sets.where((set) => !set.completed);
      if (set.isNotEmpty) return set.first;
      continue;
    }
    final maxSets = group.fold<int>(
      0,
      (max, exercise) =>
          exercise.sets.length > max ? exercise.sets.length : max,
    );
    for (var round = 0; round < maxSets; round++) {
      for (final member in group) {
        if (round >= member.sets.length) continue;
        final set = member.sets[round];
        if (!set.completed) return set;
      }
    }
    index += group.length - 1;
  }
  return null;
}

bool completionEndsRound(List<SessionExerciseSnapshot> exercises, int setId) {
  SessionExerciseSnapshot? owner;
  SessionSetSnapshot? completedSet;
  for (final exercise in exercises) {
    for (final set in exercise.sets) {
      if (set.id == setId) {
        owner = exercise;
        completedSet = set;
        break;
      }
    }
  }
  if (owner == null || completedSet == null) return true;
  final index = exercises.indexOf(owner);
  final group = _validGroup(exercises, index);
  if (group.isEmpty) return true;
  for (final member in group) {
    final matching = member.sets.where(
      (set) => set.setIndex == completedSet!.setIndex,
    );
    final roundSet = matching.isEmpty ? null : matching.first;
    if (roundSet != null && roundSet.id != setId && !roundSet.completed) {
      return false;
    }
  }
  return true;
}

String? supersetRoundLabel(
  List<SessionExerciseSnapshot> exercises,
  SessionExerciseSnapshot exercise,
) {
  final index = exercises.indexOf(exercise);
  if (index < 0) return null;
  final group = _validGroup(exercises, index);
  if (group.isEmpty) return null;
  final maxSets = group.fold<int>(
    0,
    (max, member) => member.sets.length > max ? member.sets.length : max,
  );
  var round = 0;
  while (round < maxSets &&
      group.every(
        (member) => member.sets.length <= round || member.sets[round].completed,
      )) {
    round++;
  }
  return 'Superset ${group.first.supersetGroup! + 1} · round ${round + 1}';
}
