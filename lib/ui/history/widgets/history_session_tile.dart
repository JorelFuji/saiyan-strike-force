import 'package:flutter/material.dart';

import '../../../domain/models/calendar_date.dart';
import '../../../domain/models/completed_session_summary.dart';
import '../../../domain/models/mass.dart';

/// Formats absolute milligram-rep volume for the current display unit.
///
/// [absoluteVolumeMilligramReps] is `sum(mg × reps)`, not a single mass. Convert
/// that product into [unit] without the plate-step rounding used by
/// [displayMass] for load entry.
String formatHistoryVolume(int absoluteVolumeMilligramReps, MassUnit unit) {
  final value = switch (unit) {
    MassUnit.kg => absoluteVolumeMilligramReps / 1000000.0,
    MassUnit.lb => (absoluteVolumeMilligramReps * 100) / 45359237.0,
  };
  return '${_formatVolumeNumber(value)} ${unit.wireValue}';
}

String _formatVolumeNumber(double value) {
  if (value == 0) {
    return '0';
  }
  if (value >= 100) {
    return value.round().toString();
  }
  if (value >= 10) {
    final oneDecimal = (value * 10).round() / 10;
    return oneDecimal == oneDecimal.roundToDouble()
        ? oneDecimal.toInt().toString()
        : oneDecimal.toStringAsFixed(1);
  }
  final twoDecimal = (value * 100).round() / 100;
  if (twoDecimal == twoDecimal.roundToDouble()) {
    return twoDecimal.toInt().toString();
  }
  final asFixed = twoDecimal.toStringAsFixed(2);
  return asFixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String formatHistoryDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  final seconds = duration.inSeconds.remainder(60);
  if (minutes > 0) {
    return '${minutes}m ${seconds}s';
  }
  return '${seconds}s';
}

class HistorySessionTile extends StatelessWidget {
  const HistorySessionTile({
    required this.summary,
    required this.massUnit,
    required this.onTap,
    super.key,
  });

  final CompletedSessionSummary summary;
  final MassUnit massUnit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durationText = formatHistoryDuration(summary.duration);
    final volumeText = formatHistoryVolume(
      summary.absoluteVolumeMilligramReps,
      massUnit,
    );
    final completionText = summary.completionLabel;
    final semanticsLabel =
        '${summary.workoutNameSnapshot}, duration $durationText, '
        'completed $completionText sets, volume $volumeText';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.workoutNameSnapshot,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$durationText · $completionText sets · $volumeText',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  semanticLabel: null,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String formatHistoryDateHeading(CalendarDate date) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
