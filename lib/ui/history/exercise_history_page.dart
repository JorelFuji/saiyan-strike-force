import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/exercise_history.dart';
import '../../domain/models/mass.dart';
import '../active_session/widgets/active_set_row.dart';
import 'exercise_history_cubit.dart';
import 'exercise_history_state.dart';
import 'widgets/history_session_tile.dart';

class ExerciseHistoryPage extends StatelessWidget {
  const ExerciseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseHistoryCubit, ExerciseHistoryState>(
      builder: (context, state) {
        final title = state.titleName ?? 'Exercise history';
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: switch (state.loadPhase) {
            ExerciseHistoryLoadPhase.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            ExerciseHistoryLoadPhase.failure => _MessageBody(
              message:
                  state.failureMessage ?? 'Unable to load exercise history.',
              onRetry: context.read<ExerciseHistoryCubit>().retry,
            ),
            ExerciseHistoryLoadPhase.empty => const _MessageBody(
              message: 'No prior performance logged for this exercise.',
              semanticsLabel: 'No prior performance logged for this exercise',
            ),
            ExerciseHistoryLoadPhase.ready => _ExerciseHistoryBody(
              entries: state.entries,
              massUnit: state.massUnit,
            ),
          },
        );
      },
    );
  }
}

class ExerciseHistoryInvalidRoutePage extends StatelessWidget {
  const ExerciseHistoryInvalidRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise history')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'This exercise history link is invalid.',
            textAlign: TextAlign.center,
            semanticsLabel: 'This exercise history link is invalid',
          ),
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({
    required this.message,
    this.onRetry,
    this.semanticsLabel,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          label: semanticsLabel ?? message,
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
      ),
    );
  }
}

class _ExerciseHistoryBody extends StatelessWidget {
  const _ExerciseHistoryBody({required this.entries, required this.massUnit});

  final List<ExerciseHistoryEntry> entries;
  final MassUnit massUnit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final dateLabel = formatHistoryDateHeading(entry.sessionOn);
        final setCount = entry.completedSets.length;
        return Semantics(
          container: true,
          label:
              '$dateLabel, $setCount completed '
              '${setCount == 1 ? 'set' : 'sets'}',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateLabel, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final set in entry.completedSets)
                  _HistoryPerformanceSetRow(set: set, massUnit: massUnit),
                if (index < entries.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Divider(height: 1),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryPerformanceSetRow extends StatelessWidget {
  const _HistoryPerformanceSetRow({required this.set, required this.massUnit});

  final ExerciseHistoryCompletedSet set;
  final MassUnit massUnit;

  @override
  Widget build(BuildContext context) {
    final loadText = formatCommittedLoad(set.actual.load, massUnit);
    final repsText = formatCommittedReps(set.actual.reps);
    final valueText = '$loadText × $repsText';
    final rpeSuffix = set.rpe == null ? '' : '. RPE ${_formatRpe(set.rpe!)}';
    final semantics = 'Logged $valueText$rpeSuffix';

    return Semantics(
      label: semantics,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: 12,
        title: Text(valueText),
        subtitle: set.rpe == null ? null : Text('RPE ${_formatRpe(set.rpe!)}'),
      ),
    );
  }

  static String _formatRpe(double rpe) {
    if (rpe == rpe.roundToDouble()) {
      return rpe.toInt().toString();
    }
    return rpe.toString();
  }
}
