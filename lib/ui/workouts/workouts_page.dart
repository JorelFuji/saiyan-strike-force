import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'workout_list_cubit.dart';
import 'workout_list_state.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutListCubit, WorkoutListState>(
      listenWhen: (previous, current) =>
          previous.postCommitArchiveId != current.postCommitArchiveId &&
          current.postCommitArchiveId != null,
      listener: (context, state) {
        final id = state.postCommitArchiveId!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Workout archived.'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => context.read<WorkoutListCubit>().restore(id),
              ),
            ),
          );
        context.read<WorkoutListCubit>().consumePostCommitArchive();
      },
      builder: (context, state) {
        final cubit = context.read<WorkoutListCubit>();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Workouts'),
            actions: [
              Semantics(
                button: true,
                label: 'Create workout',
                child: TextButton.icon(
                  onPressed: () => context.push('/workouts/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('New workout'),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  onChanged: cubit.setQuery,
                  decoration: const InputDecoration(
                    labelText: 'Search workouts',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<WorkoutListFilter>(
                  segments: const [
                    ButtonSegment(
                      value: WorkoutListFilter.active,
                      label: Text('Active'),
                    ),
                    ButtonSegment(
                      value: WorkoutListFilter.archived,
                      label: Text('Archived'),
                    ),
                  ],
                  selected: {state.filter},
                  onSelectionChanged: (value) => cubit.setFilter(value.first),
                ),
              ),
              if (state.failureMessage != null &&
                  state.loadPhase != WorkoutListLoadPhase.failure)
                _FailureBanner(
                  message: state.failureMessage!,
                  onRetry: cubit.retry,
                ),
              Expanded(child: _WorkoutListBody(state: state)),
            ],
          ),
        );
      },
    );
  }
}

class _WorkoutListBody extends StatelessWidget {
  const _WorkoutListBody({required this.state});
  final WorkoutListState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutListCubit>();
    if (state.loadPhase == WorkoutListLoadPhase.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.loadPhase == WorkoutListLoadPhase.failure) {
      return Center(
        child: _FailureBanner(
          message: state.failureMessage ?? 'Unable to load workouts.',
          onRetry: cubit.retryLoad,
        ),
      );
    }
    final visible = state.visibleTemplates;
    if (visible.isEmpty) {
      final hasItemsForFilter = state.templates.any(
        (template) => state.filter == WorkoutListFilter.active
            ? template.archivedAt == null
            : template.archivedAt != null,
      );
      final message = hasItemsForFilter
          ? 'No workouts match your search.'
          : state.filter == WorkoutListFilter.active
          ? 'No active workouts.'
          : 'No archived workouts.';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              if (!hasItemsForFilter &&
                  state.filter == WorkoutListFilter.active) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/workouts/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create workout'),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final template = visible[index];
        final pending = state.pendingTemplateId == template.id;
        final archived = template.archivedAt != null;
        return ListTile(
          onTap: () => context.push('/workouts/${template.id}/edit'),
          title: Text(template.name),
          subtitle: template.notes == null ? null : Text(template.notes!),
          trailing: SizedBox(
            width: 48,
            height: 48,
            child: pending
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : MenuAnchor(
                    builder: (context, controller, child) => IconButton(
                      tooltip:
                          '${archived ? 'Restore' : 'Archive'} ${template.name}',
                      onPressed: controller.open,
                      icon: const Icon(Icons.more_vert),
                    ),
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () => archived
                            ? cubit.restore(template.id)
                            : cubit.archive(template.id),
                        child: Semantics(
                          label:
                              '${archived ? 'Restore' : 'Archive'} ${template.name}',
                          child: Text(archived ? 'Restore' : 'Archive'),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
