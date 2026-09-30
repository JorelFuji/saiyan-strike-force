import 'package:flutter/material.dart';

import '../../../domain/models/mass.dart';
import '../../../domain/models/workout_template.dart';
import '../../core/formatters/load_formatter.dart';

/// Accessible summary row for one draft exercise with reorder and edit controls.
class TemplateExerciseSummary extends StatelessWidget {
  const TemplateExerciseSummary({
    required this.exercise,
    required this.massUnit,
    required this.index,
    required this.totalCount,
    required this.onEdit,
    required this.onRemove,
    required this.onMoveEarlier,
    required this.onMoveLater,
    required this.onGroupWithPrevious,
    required this.onRemoveFromSuperset,
    this.enabled = true,
    super.key,
  });

  final TemplateExercise exercise;
  final MassUnit massUnit;
  final int index;
  final int totalCount;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onMoveEarlier;
  final VoidCallback onMoveLater;
  final VoidCallback onGroupWithPrevious;
  final VoidCallback onRemoveFromSuperset;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final canMoveEarlier = index > 0;
    final canMoveLater = index < totalCount - 1;
    final subtitle = _summaryLine(exercise, massUnit);
    final grouped = exercise.supersetGroup != null;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DragHandle(
                  index: index,
                  exerciseName: exercise.name,
                  enabled: enabled,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          grouped
                              ? 'Superset ${exercise.supersetGroup! + 1} · $subtitle'
                              : subtitle,
                        ),
                      ],
                    ),
                  ),
                ),
                _GroupAction(
                  exerciseName: exercise.name,
                  grouped: grouped,
                  enabled: enabled && (grouped || index > 0),
                  onPressed: grouped
                      ? onRemoveFromSuperset
                      : onGroupWithPrevious,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _ActionChip(
                  label: 'Edit ${exercise.name}',
                  onPressed: enabled ? onEdit : null,
                  child: const Text('Edit'),
                ),
                _ActionChip(
                  label: 'Remove ${exercise.name}',
                  onPressed: enabled ? onRemove : null,
                  child: const Text('Remove'),
                ),
                _ActionChip(
                  label: 'Move ${exercise.name} earlier',
                  onPressed: enabled && canMoveEarlier ? onMoveEarlier : null,
                  child: const Text('Move earlier'),
                ),
                _ActionChip(
                  label: 'Move ${exercise.name} later',
                  onPressed: enabled && canMoveLater ? onMoveLater : null,
                  child: const Text('Move later'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _summaryLine(TemplateExercise exercise, MassUnit unit) {
    final reps = formatCommittedReps(exercise.reps);
    final load = formatCommittedLoad(exercise.load, unit);
    final sets = '${exercise.plannedSets} sets';
    final rest = '${exercise.restSeconds}s rest';
    return '$sets · $reps · $load · $rest';
  }
}

class _GroupAction extends StatelessWidget {
  const _GroupAction({
    required this.exerciseName,
    required this.grouped,
    required this.enabled,
    required this.onPressed,
  });

  final String exerciseName;
  final bool grouped;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = grouped
        ? 'Remove $exerciseName from superset'
        : 'Superset $exerciseName with previous exercise';
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Tooltip(
        message: grouped ? 'Remove from superset' : 'Superset with previous',
        child: SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: enabled ? onPressed : null,
            icon: Icon(grouped ? Icons.link_off : Icons.link),
            tooltip: label,
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({
    required this.index,
    required this.exerciseName,
    required this.enabled,
  });

  final int index;
  final String exerciseName;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final handle = Semantics(
      label: enabled
          ? 'Drag to reorder $exerciseName'
          : 'Reordering $exerciseName is unavailable while saving',
      enabled: enabled,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Icon(
          Icons.drag_handle,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
    return enabled
        ? ReorderableDelayedDragStartListener(index: index, child: handle)
        : handle;
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.onPressed,
    required this.child,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: SizedBox(
        height: 48,
        child: TextButton(onPressed: onPressed, child: child),
      ),
    );
  }
}
