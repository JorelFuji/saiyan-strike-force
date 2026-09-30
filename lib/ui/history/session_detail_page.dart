import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/active_session.dart';
import '../../domain/models/mass.dart';
import '../../domain/models/prescriptions.dart';
import '../active_session/widgets/active_set_row.dart';
import 'session_detail_cubit.dart';
import 'session_detail_state.dart';
import 'widgets/history_session_tile.dart';

class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({required this.sessionId, super.key});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionDetailCubit, SessionDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.session?.workoutNameSnapshot ?? 'Session'),
          ),
          body: switch (state.loadPhase) {
            SessionDetailLoadPhase.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            SessionDetailLoadPhase.failure => _MessageBody(
              message: state.failureMessage ?? 'Unable to load session.',
              onRetry: context.read<SessionDetailCubit>().retry,
            ),
            SessionDetailLoadPhase.notFound => _MessageBody(
              message:
                  state.failureMessage ??
                  'This session was not found in History.',
            ),
            SessionDetailLoadPhase.ready => _SessionDetailBody(
              session: state.session!,
              massUnit: state.massUnit,
            ),
          },
        );
      },
    );
  }
}

class SessionDetailInvalidRoutePage extends StatelessWidget {
  const SessionDetailInvalidRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'This session link is invalid.',
            textAlign: TextAlign.center,
            semanticsLabel: 'This session link is invalid',
          ),
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionDetailBody extends StatelessWidget {
  const _SessionDetailBody({required this.session, required this.massUnit});

  final ActiveSession session;
  final MassUnit massUnit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final endedAt = session.endedAt!;
    final duration = endedAt.difference(session.startedAt);
    final completed = session.exercises
        .expand((e) => e.sets)
        .where((s) => s.completed)
        .length;
    final total = session.exercises.expand((e) => e.sets).length;
    final volume = _absoluteVolume(session);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.workoutNameSnapshot,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${formatHistoryDuration(duration)} · '
                '$completed/$total sets · '
                '${formatHistoryVolume(volume, massUnit)}',
                style: theme.textTheme.bodyLarge,
              ),
              if (session.notes case final notes?) ...[
                const SizedBox(height: 8),
                Text('Notes: $notes', style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        for (final exercise in session.exercises) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Semantics(
              button: true,
              label:
                  '${exercise.nameSnapshot}. '
                  'View prior performance for this exercise',
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () {
                    final encoded = Uri.encodeComponent(exercise.nameSnapshot);
                    context.push('/history/exercise?name=$encoded');
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          exercise.nameSnapshot,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          for (var i = 0; i < exercise.sets.length; i++)
            _HistorySetRow(
              setNumber: i + 1,
              set: exercise.sets[i],
              massUnit: massUnit,
            ),
        ],
      ],
    );
  }

  static int _absoluteVolume(ActiveSession session) {
    var total = 0;
    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        if (!set.completed) continue;
        final actual = set.actual;
        if (actual == null) continue;
        if (actual.load case AbsoluteLoad(:final milligrams)) {
          if (actual.reps case FixedReps(:final reps)) {
            total += milligrams * reps;
          }
        }
      }
    }
    return total;
  }
}

class _HistorySetRow extends StatelessWidget {
  const _HistorySetRow({
    required this.setNumber,
    required this.set,
    required this.massUnit,
  });

  final int setNumber;
  final SessionSetSnapshot set;
  final MassUnit massUnit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = set.completed ? 'Completed' : 'Incomplete';
    final planned =
        '${formatCommittedLoad(set.plannedLoad, massUnit)} × '
        '${formatCommittedReps(set.plannedReps)}';
    final actualText = set.actual == null
        ? 'Not logged'
        : '${formatCommittedLoad(set.actual!.load, massUnit)} × '
              '${formatCommittedReps(set.actual!.reps)}';

    final semantics =
        'Set $setNumber, $statusLabel. '
        'Planned $planned. '
        '${set.completed ? 'Logged $actualText' : 'Logged values $actualText'}'
        '${set.rpe != null ? '. ${_formatRpeLabel(set.rpe!)}' : ''}';

    return Semantics(
      label: semantics,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        leading: CircleAvatar(radius: 16, child: Text('$setNumber')),
        title: Text(
          set.completed ? actualText : planned,
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          set.completed
              ? 'Completed · planned $planned'
                    '${set.rpe != null ? ' · ${_formatRpeLabel(set.rpe!)}' : ''}'
              : 'Incomplete · planned $planned',
        ),
        trailing: Icon(
          set.completed
              ? Icons.check_circle_outline
              : Icons.radio_button_unchecked,
          semanticLabel: statusLabel,
        ),
      ),
    );
  }

  static String _formatRpe(double rpe) {
    if (rpe == rpe.roundToDouble()) {
      return rpe.toInt().toString();
    }
    return rpe.toString();
  }

  static String _formatRpeLabel(double rpe) => 'RPE ${_formatRpe(rpe)}';
}
