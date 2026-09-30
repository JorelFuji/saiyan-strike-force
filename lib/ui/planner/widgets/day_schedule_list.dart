import 'package:flutter/material.dart';

import '../../../domain/models/schedule_status.dart';
import '../planner_state.dart';

/// Selected-day schedule entries with start / skip / move actions.
class DayScheduleList extends StatelessWidget {
  const DayScheduleList({
    required this.entries,
    required this.actionPending,
    required this.startPendingEntryId,
    required this.onStart,
    required this.onSkip,
    required this.onUnskip,
    required this.onMove,
    super.key,
  });

  final List<PlannerEntryView> entries;
  final bool actionPending;
  final int? startPendingEntryId;
  final ValueChanged<int> onStart;
  final ValueChanged<int> onSkip;
  final ValueChanged<int> onUnskip;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No workouts planned',
              style: Theme.of(context).textTheme.bodyLarge,
              semanticsLabel: 'No workouts planned for this day',
            ),
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final view = entries[index];
        final entry = view.workout;
        final busy = actionPending || startPendingEntryId == entry.id;
        return _EntryTile(
          name: entry.workoutName,
          archived: entry.workoutArchived,
          label: entry.label,
          displayStatus: view.displayStatus,
          busy: busy,
          onStart:
              view.displayStatus == PlannerDisplayStatus.planned ||
                  view.displayStatus == PlannerDisplayStatus.missed
              ? () => onStart(entry.id)
              : null,
          onSkip: entry.status == ScheduleStatus.planned
              ? () => onSkip(entry.id)
              : null,
          onUnskip: entry.status == ScheduleStatus.skipped
              ? () => onUnskip(entry.id)
              : null,
          onMove: () => onMove(entry.id),
        );
      },
      separatorBuilder: (_, _) => const Divider(height: 1),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.name,
    required this.archived,
    required this.label,
    required this.displayStatus,
    required this.busy,
    required this.onStart,
    required this.onSkip,
    required this.onUnskip,
    required this.onMove,
  });

  final String name;
  final bool archived;
  final String? label;
  final PlannerDisplayStatus displayStatus;
  final bool busy;
  final VoidCallback? onStart;
  final VoidCallback? onSkip;
  final VoidCallback? onUnskip;
  final VoidCallback onMove;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (displayStatus) {
      PlannerDisplayStatus.planned => 'Planned',
      PlannerDisplayStatus.skipped => 'Skipped',
      PlannerDisplayStatus.completed => 'Completed',
      PlannerDisplayStatus.missed => 'Missed',
    };
    final title = label == null || label!.isEmpty ? name : '$name ($label)';
    final subtitle = archived
        ? '$statusLabel · Archived template'
        : statusLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(title),
            subtitle: Text(subtitle),
            leading: Icon(switch (displayStatus) {
              PlannerDisplayStatus.planned => Icons.event_available,
              PlannerDisplayStatus.skipped => Icons.event_busy,
              PlannerDisplayStatus.completed => Icons.check_circle_outline,
              PlannerDisplayStatus.missed => Icons.warning_amber_outlined,
            }, semanticLabel: statusLabel),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onStart != null)
                Semantics(
                  label: 'Start $name',
                  button: true,
                  child: FilledButton(
                    onPressed: busy ? null : onStart,
                    child: const Text('Start'),
                  ),
                ),
              if (onSkip != null)
                Semantics(
                  label: 'Skip $name',
                  button: true,
                  child: OutlinedButton(
                    onPressed: busy ? null : onSkip,
                    child: const Text('Skip'),
                  ),
                ),
              if (onUnskip != null)
                Semantics(
                  label: 'Undo skip $name',
                  button: true,
                  child: OutlinedButton(
                    onPressed: busy ? null : onUnskip,
                    child: const Text('Undo skip'),
                  ),
                ),
              Semantics(
                label: 'Move $name',
                button: true,
                child: TextButton(
                  onPressed: busy ? null : onMove,
                  child: const Text('Move'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
