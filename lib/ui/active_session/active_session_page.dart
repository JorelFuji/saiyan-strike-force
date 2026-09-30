import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/result.dart';
import '../../domain/models/active_session.dart';
import '../../domain/models/session_status.dart';
import 'active_session_cubit.dart';
import 'active_session_state.dart';
import 'set_draft.dart';
import '../core/widgets/rest_timer_ring.dart';
import 'widgets/active_set_row.dart';
import 'widgets/rest_timer_controls.dart';
import 'widgets/add_exercise_sheet.dart';
import 'superset_rounds.dart';

void _popRoute(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router != null && router.canPop()) {
    router.pop();
    return;
  }
  Navigator.of(context).maybePop();
}

/// Route host for Active Session with tap-first set entry and completion.
class ActiveSessionPage extends StatelessWidget {
  const ActiveSessionPage({required this.sessionId, super.key});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActiveSessionCubit, ActiveSessionState>(
      listenWhen: (previous, current) =>
          !previous.finishSucceeded && current.finishSucceeded,
      listener: (context, state) => _popRoute(context),
      child: Scaffold(
        appBar: AppBar(
          leading: Semantics(
            label: 'Back',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () => _popRoute(context),
            ),
          ),
          title: const Text('Active Session'),
        ),
        body: BlocBuilder<ActiveSessionCubit, ActiveSessionState>(
          buildWhen: (previous, current) =>
              previous.loadPhase != current.loadPhase ||
              previous.session != current.session ||
              previous.streamReadMessage != current.streamReadMessage ||
              previous.finishPending != current.finishPending ||
              previous.restUiTick != current.restUiTick ||
              previous.session?.rest != current.session?.rest ||
              previous.restAlertDegradedMessage !=
                  current.restAlertDegradedMessage ||
              previous.addExercise != current.addExercise ||
              previous.addSet != current.addSet,
          builder: (context, state) {
            return switch (state.loadPhase) {
              ActiveSessionLoadPhase.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              ActiveSessionLoadPhase.initialError => _InitialErrorBody(
                message:
                    state.initialReadMessage ?? 'Unable to load this session.',
                onRetry: () =>
                    context.read<ActiveSessionCubit>().retryInitialLoad(),
                onBack: () => _popRoute(context),
              ),
              ActiveSessionLoadPhase.ready => _ReadyBody(state: state),
            };
          },
        ),
      ),
    );
  }
}

class ActiveSessionInvalidRoutePage extends StatelessWidget {
  const ActiveSessionInvalidRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Session')),
      body: _InitialErrorBody(
        message: 'This session link is invalid.',
        onRetry: null,
        onBack: () => _popRoute(context),
      ),
    );
  }
}

class _InitialErrorBody extends StatelessWidget {
  const _InitialErrorBody({
    required this.message,
    required this.onBack,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (onRetry != null)
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            if (onRetry != null) const SizedBox(height: 12),
            TextButton(onPressed: onBack, child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}

int? currentSetIdFor(ActiveSessionState state) {
  final session = state.session;
  if (session == null) {
    return null;
  }
  return nextSetInSupersetSession(session.exercises)?.id;
}

class _ReadyBody extends StatefulWidget {
  const _ReadyBody({required this.state});

  final ActiveSessionState state;

  @override
  State<_ReadyBody> createState() => _ReadyBodyState();
}

class _ReadyBodyState extends State<_ReadyBody> {
  int _selectedExerciseIndex = 0;

  @override
  void didUpdateWidget(covariant _ReadyBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final exercises = widget.state.session?.exercises ?? const [];
    if (_selectedExerciseIndex >= exercises.length) {
      _selectedExerciseIndex = exercises.isEmpty ? 0 : exercises.length - 1;
    }
    _syncSelectionToCurrentSet();
  }

  @override
  void initState() {
    super.initState();
    _selectedExerciseIndex = _exerciseIndexForCurrentSet(widget.state);
  }

  int _exerciseIndexForCurrentSet(ActiveSessionState state) {
    final session = state.session;
    if (session == null) {
      return _selectedExerciseIndex;
    }
    final currentId = currentSetIdFor(state);
    if (currentId == null) {
      return _selectedExerciseIndex;
    }
    for (var i = 0; i < session.exercises.length; i++) {
      if (session.exercises[i].sets.any((set) => set.id == currentId)) {
        return i;
      }
    }
    return _selectedExerciseIndex;
  }

  void _syncSelectionToCurrentSet() {
    final nextIndex = _exerciseIndexForCurrentSet(widget.state);
    if (_selectedExerciseIndex != nextIndex) {
      setState(() => _selectedExerciseIndex = nextIndex);
    }
  }

  Future<void> _confirmFinish(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish workout?'),
        content: const Text(
          'Your logged sets are saved. Finish this session when you are done.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ActiveSessionCubit>().finish();
    }
  }

  Future<void> _addExercise(BuildContext context) async {
    final state = widget.state;
    final draft = await showModalBottomSheet<AddExerciseDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExerciseSheet(massUnit: state.massUnit),
    );
    if (draft == null || !context.mounted) return;
    final command = draft.toCommand(widget.state.session!.id);
    if (command case Ok(:final value)) {
      await context.read<ActiveSessionCubit>().addExercise(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final session = state.session;
    if (session == null) {
      return const Center(child: Text('Session unavailable.'));
    }

    final exercises = session.exercises;
    final paused = session.status == SessionStatus.paused;
    final mutable = state.isSessionMutable;
    final selectedExercise = exercises.isEmpty
        ? null
        : exercises[_selectedExerciseIndex.clamp(0, exercises.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.streamReadMessage != null)
          MaterialBanner(
            content: Text(state.streamReadMessage!),
            actions: const [SizedBox.shrink()],
          ),
        if (state.restAlertDegradedMessage != null)
          MaterialBanner(
            content: Text(state.restAlertDegradedMessage!),
            actions: const [SizedBox.shrink()],
          ),
        if (session.rest case final rest?) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                RestTimerRing(
                  rest: rest,
                  clock: context.read<ActiveSessionCubit>().clock,
                  uiTick: state.restUiTick,
                ),
                const SizedBox(height: 8),
                RestTimerControls(
                  enabled: mutable && !state.finishPending,
                  onSkip: () => context.read<ActiveSessionCubit>().skipRest(),
                  onSubtractThirty: () =>
                      context.read<ActiveSessionCubit>().adjustRestSeconds(-30),
                  onAddThirty: () =>
                      context.read<ActiveSessionCubit>().adjustRestSeconds(30),
                  onReset: () => context.read<ActiveSessionCubit>().resetRest(),
                ),
              ],
            ),
          ),
        ],
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                session.workoutNameSnapshot,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (paused) ...[
                const SizedBox(height: 8),
                Text(
                  'Paused',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
              const SizedBox(height: 16),
              Text('Exercises', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (state.addExercise.failureMessage case final message?) ...[
                Text(
                  message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                TextButton(
                  onPressed: state.addExercise.isBusy
                      ? null
                      : () => context
                            .read<ActiveSessionCubit>()
                            .retryAddExercise(),
                  child: const Text('Retry add exercise'),
                ),
              ],
              if (exercises.isEmpty) ...[
                const Text(
                  'This freestyle workout is blank. Add an exercise to start logging.',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: !mutable || state.addExercise.isBusy
                        ? null
                        : () => _addExercise(context),
                    icon: state.addExercise.isBusy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: const Text('Add exercise'),
                  ),
                ),
              ],
              ...List.generate(exercises.length, (index) {
                final exercise = exercises[index];
                final completedSets = exercise.sets
                    .where((s) => s.completed)
                    .length;
                final groupLabel = supersetRoundLabel(exercises, exercise);
                final selected = index == _selectedExerciseIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label:
                        '${exercise.nameSnapshot}, $completedSets of ${exercise.sets.length} sets complete'
                        '${groupLabel == null ? '' : ', $groupLabel'}',
                    child: Ink(
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            setState(() => _selectedExerciseIndex = index),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${exercise.nameSnapshot}${groupLabel == null ? '' : ' · $groupLabel'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge,
                                  ),
                                ),
                                Text(
                                  '$completedSets / ${exercise.sets.length}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              if (selectedExercise != null) ...[
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: !mutable || state.addExercise.isBusy
                        ? null
                        : () => _addExercise(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add exercise'),
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 8),
                Text(
                  selectedExercise.nameSnapshot,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                BlocBuilder<ActiveSessionCubit, ActiveSessionState>(
                  buildWhen: (previous, current) =>
                      previous.drafts != current.drafts ||
                      previous.operations != current.operations ||
                      previous.session != current.session ||
                      previous.addSet != current.addSet,
                  builder: (context, rowState) {
                    final cubit = context.read<ActiveSessionCubit>();
                    return Column(
                      children: [
                        for (final set in selectedExercise.sets)
                          ActiveSetRow(
                            key: ValueKey(set.id),
                            set: _setFromSession(rowState, set.id) ?? set,
                            draft:
                                rowState.drafts[set.id] ??
                                SetDraft.seed(set, rowState.massUnit),
                            operation:
                                rowState.operations[set.id] ??
                                const SetOperationState.idle(),
                            massUnit: rowState.massUnit,
                            setNumber: set.setIndex + 1,
                            isCurrent: set.id == currentSetIdFor(rowState),
                            isMutable: rowState.isSessionMutable,
                            onDraftChanged: (draft) =>
                                cubit.updateDraft(set.id, draft),
                            onCommitDraft: () =>
                                cubit.saveSetActualValues(set.id),
                            onComplete: () => cubit.completeSet(set.id),
                            onRetry: () => cubit.retrySet(set.id),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed:
                                !rowState.isSessionMutable ||
                                    rowState.addSet.isBusy
                                ? null
                                : () {
                                    final command = AddSessionSetCommand.create(
                                      sessionId: rowState.session!.id,
                                      exerciseId: selectedExercise.id,
                                    );
                                    if (command case Ok(:final value)) {
                                      cubit.addSet(value);
                                    }
                                  },
                            icon: rowState.addSet.isBusy
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add),
                            label: const Text('Add set'),
                          ),
                        ),
                        if (rowState.addSet.failureMessage
                            case final message?) ...[
                          const SizedBox(height: 8),
                          Text(
                            message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          TextButton(
                            onPressed: rowState.addSet.isBusy
                                ? null
                                : cubit.retryAddSet,
                            child: const Text('Retry add set'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.finishPending) const LinearProgressIndicator(),
                if (mutable) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: paused ? 'Continue workout' : 'Pause workout',
                          child: OutlinedButton(
                            onPressed: state.finishPending
                                ? null
                                : () {
                                    if (paused) {
                                      context
                                          .read<ActiveSessionCubit>()
                                          .continueSession();
                                    } else {
                                      context
                                          .read<ActiveSessionCubit>()
                                          .pause();
                                    }
                                  },
                            child: Text(paused ? 'Continue' : 'Pause'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: 'Finish workout',
                          child: SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed: state.finishPending
                                  ? null
                                  : () => _confirmFinish(context),
                              child: const Text('Finish'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  SessionSetSnapshot? _setFromSession(ActiveSessionState state, int setId) {
    for (final exercise in state.session?.exercises ?? const []) {
      for (final set in exercise.sets) {
        if (set.id == setId) {
          return set;
        }
      }
    }
    return null;
  }
}
