import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
          appBar: AppBar(title: const Text('Planner')),
          floatingActionButton: Semantics(
            label: 'Add workout',
            button: true,
            child: FloatingActionButton(
              onPressed: () => showAddWorkoutSheet(context),
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
