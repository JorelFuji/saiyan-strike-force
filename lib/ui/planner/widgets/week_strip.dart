import 'package:flutter/material.dart';

import '../../../domain/models/calendar_date.dart';

/// Seven-day strip with previous/next week controls and day selection.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    required this.weekStart,
    required this.selectedDate,
    required this.today,
    required this.entryCountFor,
    required this.onSelectDay,
    required this.onPreviousWeek,
    required this.onNextWeek,
    super.key,
  });

  final CalendarDate weekStart;
  final CalendarDate selectedDate;
  final CalendarDate today;
  final int Function(CalendarDate date) entryCountFor;
  final ValueChanged<CalendarDate> onSelectDay;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final days = [
      for (var offset = 0; offset < 7; offset++) weekStart.addDays(offset),
    ];

    return Column(
      children: [
        Row(
          children: [
            Semantics(
              label: 'Previous week',
              button: true,
              child: IconButton(
                tooltip: 'Previous week',
                onPressed: onPreviousWeek,
                icon: const Icon(Icons.chevron_left),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
            Expanded(
              child: Text(
                _weekLabel(localizations, days.first, days.last),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Semantics(
              label: 'Next week',
              button: true,
              child: IconButton(
                tooltip: 'Next week',
                onPressed: onNextWeek,
                icon: const Icon(Icons.chevron_right),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 80,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -200) {
                onNextWeek();
              } else if (velocity > 200) {
                onPreviousWeek();
              }
            },
            child: Row(
              children: [
                for (final day in days)
                  Expanded(
                    child: _DayCell(
                      date: day,
                      weekdayLabel:
                          localizations.narrowWeekdays[DateTime.utc(
                                day.year,
                                day.month,
                                day.day,
                              ).weekday %
                              7],
                      selected: day == selectedDate,
                      isToday: day == today,
                      entryCount: entryCountFor(day),
                      onTap: () => onSelectDay(day),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _weekLabel(
    MaterialLocalizations localizations,
    CalendarDate start,
    CalendarDate end,
  ) {
    final startLabel = localizations.formatShortDate(
      DateTime(start.year, start.month, start.day),
    );
    final endLabel = localizations.formatShortDate(
      DateTime(end.year, end.month, end.day),
    );
    return '$startLabel – $endLabel';
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.weekdayLabel,
    required this.selected,
    required this.isToday,
    required this.entryCount,
    required this.onTap,
  });

  final CalendarDate date;
  final String weekdayLabel;
  final bool selected;
  final bool isToday;
  final int entryCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semanticLabel = StringBuffer()
      ..write(weekdayLabel)
      ..write(' ')
      ..write(date.day);
    if (isToday) semanticLabel.write(', today');
    if (selected) semanticLabel.write(', selected');
    if (entryCount == 0) {
      semanticLabel.write(', no workouts');
    } else if (entryCount == 1) {
      semanticLabel.write(', 1 workout');
    } else {
      semanticLabel.write(', $entryCount workouts');
    }

    return Semantics(
      label: semanticLabel.toString(),
      button: true,
      selected: selected,
      child: InkWell(
        canRequestFocus: true,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weekdayLabel,
                  style: theme.textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? colorScheme.primary
                        : (isToday
                              ? colorScheme.primaryContainer
                              : colorScheme.surface),
                    border: isToday && !selected
                        ? Border.all(color: colorScheme.primary)
                        : null,
                  ),
                  child: Text(
                    '${date.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: selected || isToday
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 14,
                      height: 1,
                    ),
                  ),
                ),
                Text(
                  entryCount > 0 ? '•' * entryCount.clamp(1, 3) : ' ',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1,
                    fontSize: 10,
                  ),
                  semanticsLabel: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
