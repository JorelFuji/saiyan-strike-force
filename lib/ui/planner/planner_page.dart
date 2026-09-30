import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/calendar_date.dart';
import 'planner_cubit.dart';
import 'planner_state.dart';
import 'widgets/add_workout_sheet.dart';
import 'widgets/day_schedule_list.dart';
import 'widgets/move_entry_sheet.dart';
import 'widgets/week_strip.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlannerCubit, PlannerState>(
      listenWhen: (previous, current) =>
          previous.startedSessionId != current.startedSessionId ||
          previous.copySuccessCount != current.copySuccessCount ||
          (previous.failureMessage != current.failureMessage &&
              current.failureMessage != null &&
              current.loadPhase == PlannerLoadPhase.ready),
      listener: (context, state) {
        final sessionId = state.startedSessionId;
        if (sessionId != null) {
          context.read<PlannerCubit>().clearStartedSessionId();
          context.push('/session/$sessionId');
          return;
        }
        final copyCount = state.copySuccessCount;
        if (copyCount != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(_copySuccessMessage(copyCount))),
            );
          context.read<PlannerCubit>().clearCopySuccessCount();
          return;
        }
        final message = state.failureMessage;
        if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
          context.read<PlannerCubit>().clearFailureMessage();
        }
      },
      builder: (context, state) {
        final cubit = context.read<PlannerCubit>();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Planner'),
            actions: [
              Semantics(
                label: 'Copy week forward',
                button: true,
                child: IconButton(
                  tooltip: 'Copy week forward',
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: state.actionPending
                      ? null
                      : () => _confirmCopyWeekForward(context, state),
                  icon: const Icon(Icons.copy_all_outlined),
                ),
              ),
            ],
          ),
          floatingActionButton: Semantics(
            label: 'Add workout',
            button: true,
            child: FloatingActionButton(
              onPressed: state.actionPending
                  ? null
                  : () => showAddWorkoutSheet(context),
              tooltip: 'Add workout',
              child: const Icon(Icons.add),
            ),
          ),
          body: Column(
            children: [
              WeekStrip(
                weekStart: state.weekStart,
                selectedDate: state.selectedDate,
                today: state.today,
                entryCountFor: state.entryCountFor,
                onSelectDay: cubit.selectDay,
                onPreviousWeek: cubit.goToPreviousWeek,
                onNextWeek: cubit.goToNextWeek,
                actionPending: state.actionPending,
              ),
              const Divider(height: 1),
              Expanded(child: _PlannerBody(state: state)),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _confirmCopyWeekForward(
  BuildContext context,
  PlannerState state,
) async {
  final localizations = MaterialLocalizations.of(context);
  String dateLabel(CalendarDate date) =>
      localizations.formatMediumDate(DateTime(date.year, date.month, date.day));
  final targetStart = state.weekStart.addDays(7);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Copy week forward?'),
      content: Text(
        'Copy planned workouts from ${dateLabel(state.weekStart)} to '
        '${dateLabel(targetStart)}. Planned workouts are added to next week; '
        'existing next-week workouts are not replaced.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Copy week'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await context.read<PlannerCubit>().copyWeekForward();
  }
}

String _copySuccessMessage(int count) {
  if (count == 0) return 'No planned workouts to copy.';
  if (count == 1) return 'Copied 1 workout to next week.';
  return 'Copied $count workouts to next week.';
}

class _PlannerBody extends StatelessWidget {
  const _PlannerBody({required this.state});

  final PlannerState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlannerCubit>();
    return switch (state.loadPhase) {
      PlannerLoadPhase.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      PlannerLoadPhase.error => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.failureMessage ?? 'Unable to load schedule.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => cubit.setWeekStart(state.weekStart),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      PlannerLoadPhase.ready => DayScheduleList(
        entries: state.selectedDayEntries,
        actionPending: state.actionPending,
        startPendingEntryId: state.startPendingEntryId,
        onStart: cubit.startEntry,
        onSkip: (id) => cubit.setSkipped(id, skipped: true),
        onUnskip: (id) => cubit.setSkipped(id, skipped: false),
        onMove: (id) async {
          final target = await showMoveEntrySheet(
            context: context,
            selectedDate: state.selectedDate,
            today: state.today,
          );
          if (target != null) {
            await cubit.moveEntry(id, target);
          }
        },
      ),
    };
  }
}
