import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'workout_builder_cubit.dart';
import 'workout_builder_state.dart';
import 'widgets/template_exercise_editor_sheet.dart';
import 'widgets/template_exercise_summary.dart';

class WorkoutBuilderPage extends StatefulWidget {
  const WorkoutBuilderPage({super.key});

  @override
  State<WorkoutBuilderPage> createState() => _WorkoutBuilderPageState();
}

class _WorkoutBuilderPageState extends State<WorkoutBuilderPage> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Discard them and leave this screen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handlePop(
    BuildContext context,
    WorkoutBuilderState state,
  ) async {
    if (!state.isDirty) {
      if (context.mounted) Navigator.of(context).pop();
      return;
    }
    final discard = await _confirmDiscard(context);
    if (discard && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WorkoutBuilderCubit cubit,
    int key,
    String exerciseName,
  ) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove exercise?'),
        content: Text('Remove $exerciseName from this template?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (remove == true) {
      cubit.removeExercise(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutBuilderCubit, WorkoutBuilderState>(
      listenWhen: (previous, current) =>
          previous.savedTemplate != current.savedTemplate ||
          (previous.phase != WorkoutBuilderPhase.ready &&
              current.phase == WorkoutBuilderPhase.ready),
      listener: (context, state) {
        if (!_seeded && state.phase == WorkoutBuilderPhase.ready) {
          _nameController.text = state.name;
          _notesController.text = state.notes;
          _seeded = true;
        }
        if (state.savedTemplate != null && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(state.savedTemplate);
        }
      },
      builder: (context, state) {
        final cubit = context.read<WorkoutBuilderCubit>();
        final title = state.isCreate ? 'New workout' : 'Edit workout';
        return PopScope(
          canPop: !state.isDirty,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _handlePop(context, state);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(title),
              leading: BackButton(onPressed: () => _handlePop(context, state)),
            ),
            body: switch (state.phase) {
              WorkoutBuilderPhase.initial || WorkoutBuilderPhase.loading =>
                const Center(child: CircularProgressIndicator()),
              WorkoutBuilderPhase.loadFailure => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.loadFailureMessage ??
                            'Unable to load this workout.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: cubit.retryLoad,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              WorkoutBuilderPhase.ready || WorkoutBuilderPhase.saving => Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            key: const Key('workout_builder_name'),
                            controller: _nameController,
                            enabled: !state.isSaving,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Workout name',
                            ),
                            onChanged: cubit.updateName,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notesController,
                            enabled: !state.isSaving,
                            textInputAction: TextInputAction.next,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Notes (optional)',
                            ),
                            onChanged: cubit.updateNotes,
                          ),
                          if (state.suggestionFailureMessage != null) ...[
                            const SizedBox(height: 12),
                            _InlineBanner(
                              message: state.suggestionFailureMessage!,
                              actionLabel: 'Retry suggestions',
                              onAction: cubit.retrySuggestions,
                            ),
                          ],
                          if (state.validationFailureMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              state.validationFailureMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                          if (state.saveFailureMessage != null) ...[
                            const SizedBox(height: 12),
                            _InlineBanner(
                              message: state.saveFailureMessage!,
                              actionLabel: 'Retry save',
                              onAction: cubit.save,
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (state.exercises.isEmpty)
                            const Text('No exercises yet. Add one below.')
                          else
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              onReorderItem: cubit.reorder,
                              itemCount: state.exercises.length,
                              itemBuilder: (context, index) {
                                final row = state.exercises[index];
                                return TemplateExerciseSummary(
                                  key: ValueKey(row.key),
                                  exercise: row.exercise,
                                  massUnit: state.massUnit,
                                  index: index,
                                  totalCount: state.exercises.length,
                                  onEdit: () async {
                                    final updated =
                                        await showTemplateExerciseEditorSheet(
                                          context,
                                          massUnit: state.massUnit,
                                          suggestions: state.suggestions,
                                          initial: row.exercise,
                                        );
                                    if (updated != null) {
                                      cubit.replaceExercise(row.key, updated);
                                    }
                                  },
                                  onRemove: () => _confirmRemove(
                                    context,
                                    cubit,
                                    row.key,
                                    row.exercise.name,
                                  ),
                                  onMoveEarlier: () =>
                                      cubit.moveEarlier(row.key),
                                  onMoveLater: () => cubit.moveLater(row.key),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    minimum: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: state.isSaving
                                ? null
                                : () async {
                                    final exercise =
                                        await showTemplateExerciseEditorSheet(
                                          context,
                                          massUnit: state.massUnit,
                                          suggestions: state.suggestions,
                                        );
                                    if (exercise != null) {
                                      cubit.addExercise(exercise);
                                    }
                                  },
                            child: const Text('Add exercise'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: state.isSaving ? null : cubit.save,
                            child: Text(
                              state.isSaving ? 'Saving…' : 'Save workout',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            },
          ),
        );
      },
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ),
      ],
    );
  }
}

class WorkoutBuilderInvalidRoutePage extends StatelessWidget {
  const WorkoutBuilderInvalidRoutePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Workout unavailable')),
    body: const Center(child: Text('This workout link is invalid.')),
  );
}
