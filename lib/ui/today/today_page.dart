import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'today_cubit.dart';
import 'today_state.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodayCubit, TodayState>(
      listenWhen: (previous, current) =>
          previous.startedSessionId != current.startedSessionId &&
          current.startedSessionId != null,
      listener: (context, state) {
        final id = state.startedSessionId;
        if (id == null) return;
        context.read<TodayCubit>().clearStartedSession();
        context.push('/session/$id');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Today'),
          actions: [
            Semantics(
              label: 'Open settings',
              button: true,
              child: IconButton(
                onPressed: () => context.push('/settings'),
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
              ),
            ),
          ],
        ),
        body: BlocBuilder<TodayCubit, TodayState>(
          builder: (context, state) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Today',
                    semanticsLabel: 'Today tab',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: state.startPending
                          ? null
                          : () => context.read<TodayCubit>().startFreestyle(),
                      icon: state.startPending
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: const Text('Start Freestyle Workout'),
                    ),
                  ),
                  if (state.failureMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(state.failureMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: state.startPending
                          ? null
                          : () => context.read<TodayCubit>().startFreestyle(),
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
