import 'package:flutter/material.dart';

import '../../../core/clock.dart';
import '../../../domain/models/active_session.dart';

/// Circular rest progress with remaining time text.
class RestTimerRing extends StatelessWidget {
  const RestTimerRing({
    required this.rest,
    required this.clock,
    required this.uiTick,
    super.key,
  });

  final AbsoluteRestState rest;
  final Clock clock;
  final int uiTick;

  @override
  Widget build(BuildContext context) {
    final _ = uiTick;
    final remainingSeconds = restSecondsUntil(rest.targetAt, clock);
    final overdue = remainingSeconds < 0;
    final displaySeconds = overdue ? -remainingSeconds : remainingSeconds;
    final fraction = restRemainingFraction(
      startedAtUtc: rest.startedAt,
      targetAtUtc: rest.targetAt,
      clock: clock,
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    final progressColor = overdue ? colorScheme.error : colorScheme.primary;

    return Semantics(
      label: overdue
          ? 'Rest overdue by ${_formatDuration(displaySeconds)}'
          : 'Rest remaining ${_formatDuration(displaySeconds)}',
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!reduceMotion)
              CircularProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                strokeWidth: 4,
                color: progressColor,
                backgroundColor: colorScheme.surfaceContainerHighest,
              )
            else
              CircularProgressIndicator(
                value: overdue ? 0 : 1,
                strokeWidth: 4,
                color: progressColor,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            Text(
              overdue
                  ? '+${_formatDuration(displaySeconds)}'
                  : _formatDuration(displaySeconds),
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: overdue ? colorScheme.error : null),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
