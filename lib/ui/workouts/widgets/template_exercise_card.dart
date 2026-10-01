import 'package:flutter/material.dart';

import '../../../domain/models/mass.dart';
import '../workout_builder_cubit.dart';
import '../workout_builder_state.dart';
import 'template_set_grid.dart';

class TemplateExerciseCard extends StatelessWidget {
  const TemplateExerciseCard({
    required this.row,
    required this.massUnit,
    required this.index,
    required this.totalCount,
    required this.cubit,
    required this.onEdit,
    required this.onRemove,
    required this.onMoveEarlier,
    required this.onMoveLater,
    required this.onGroupWithPrevious,
    required this.onRemoveFromSuperset,
    required this.onRemoveSet,
    this.enabled = true,
    super.key,
  });
  final DraftExerciseRow row;
  final MassUnit massUnit;
  final int index;
  final int totalCount;
  final WorkoutBuilderCubit cubit;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onMoveEarlier;
  final VoidCallback onMoveLater;
  final VoidCallback onGroupWithPrevious;
  final VoidCallback onRemoveFromSuperset;
  final void Function(int, RemovedTemplateSet) onRemoveSet;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final grouped = row.exercise.supersetGroup != null;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DragHandle(
                  index: index,
                  name: row.exercise.name,
                  enabled: enabled,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      row.exercise.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: enabled
                      ? (grouped ? onRemoveFromSuperset : onGroupWithPrevious)
                      : null,
                  icon: Icon(grouped ? Icons.link_off : Icons.link),
                  tooltip: grouped
                      ? 'Remove from superset'
                      : 'Superset with previous',
                ),
              ],
            ),
            if (grouped)
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text('Superset ${row.exercise.supersetGroup! + 1}'),
              ),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _ActionChip(
                  label: 'Edit details for ${row.exercise.name}',
                  onPressed: enabled ? onEdit : null,
                  child: const Text('Edit details'),
                ),
                _ActionChip(
                  label: 'Remove ${row.exercise.name}',
                  onPressed: enabled ? onRemove : null,
                  child: const Text('Remove'),
                ),
                _ActionChip(
                  label: 'Move ${row.exercise.name} earlier',
                  onPressed: enabled && index > 0 ? onMoveEarlier : null,
                  child: const Text('Move earlier'),
                ),
                _ActionChip(
                  label: 'Move ${row.exercise.name} later',
                  onPressed: enabled && index < totalCount - 1
                      ? onMoveLater
                      : null,
                  child: const Text('Move later'),
                ),
              ],
            ),
            TemplateSetGrid(
              row: row,
              massUnit: massUnit,
              cubit: cubit,
              enabled: enabled,
              onRemoveSet: onRemoveSet,
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({
    required this.index,
    required this.name,
    required this.enabled,
  });
  final int index;
  final String name;
  final bool enabled;
  @override
  Widget build(BuildContext context) => enabled
      ? ReorderableDelayedDragStartListener(
          index: index,
          child: _content(context),
        )
      : _content(context);
  Widget _content(BuildContext context) => Semantics(
    label: 'Drag to reorder $name',
    enabled: enabled,
    child: const SizedBox(
      width: 48,
      height: 48,
      child: Icon(Icons.drag_handle),
    ),
  );
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
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    enabled: onPressed != null,
    child: SizedBox(
      height: 48,
      child: TextButton(onPressed: onPressed, child: child),
    ),
  );
}
