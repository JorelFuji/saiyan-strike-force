import 'package:flutter/material.dart';

import '../../../domain/models/mass.dart';
import '../../../domain/models/workout_template.dart';
import '../../active_session/widgets/active_set_row.dart';

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

  @override
  Widget build(BuildContext context) {
    final canMoveEarlier = index > 0;
    final canMoveLater = index < totalCount - 1;
    final subtitle = _summaryLine(exercise, massUnit);
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
                ReorderableDelayedDragStartListener(
                  index: index,
                  child: Semantics(
                    label: 'Drag to reorder ${exercise.name}',
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.drag_handle,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
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
                        Text(subtitle),
                      ],
                    ),
                  ),
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
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
                _ActionChip(
                  label: 'Remove ${exercise.name}',
                  onPressed: onRemove,
                  child: const Text('Remove'),
                ),
                _ActionChip(
                  label: 'Move ${exercise.name} earlier',
                  onPressed: canMoveEarlier ? onMoveEarlier : null,
                  child: const Text('Move earlier'),
                ),
                _ActionChip(
                  label: 'Move ${exercise.name} later',
                  onPressed: canMoveLater ? onMoveLater : null,
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
