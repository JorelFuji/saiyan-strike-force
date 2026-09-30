import 'package:flutter/material.dart';

import '../../../domain/models/calendar_date.dart';

/// Read-only structural month overview. Day actions remain in the drill-in.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    required this.monthAnchor,
    required this.dates,
    required this.firstDayOfWeekIndex,
    required this.selectedDate,
    required this.today,
    required this.entryCountFor,
    required this.onSelectDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.actionPending = false,
    super.key,
  }) : assert(
         dates.length >= 28 && dates.length <= 42 && dates.length % 7 == 0,
       );

  final CalendarDate monthAnchor;
  final List<CalendarDate> dates;
  final int firstDayOfWeekIndex;
  final CalendarDate selectedDate;
  final CalendarDate today;
  final int Function(CalendarDate) entryCountFor;
  final ValueChanged<CalendarDate> onSelectDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final bool actionPending;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final weekdays = [
      for (var index = 0; index < 7; index++)
        localizations.narrowWeekdays[(firstDayOfWeekIndex + index) % 7],
    ];
    return Column(
      children: [
        Row(
          children: [
            Semantics(
              label: 'Previous month',
              button: true,
              child: IconButton(
                tooltip: 'Previous month',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: actionPending ? null : onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
            ),
            Expanded(
              child: Text(
                localizations.formatMonthYear(
                  DateTime(monthAnchor.year, monthAnchor.month),
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Semantics(
              label: 'Next month',
              button: true,
              child: IconButton(
                tooltip: 'Next month',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: actionPending ? null : onNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 336),
            child: Column(
              children: [
                Row(
                  children: [
                    for (final weekday in weekdays)
                      SizedBox(
                        width: 48,
                        height: 32,
                        child: Center(
                          child: Text(
                            weekday,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ),
                  ],
                ),
                for (var row = 0; row < dates.length ~/ 7; row++)
                  Row(
                    children: [
                      for (final date in dates.skip(row * 7).take(7))
                        _MonthDayCell(
                          date: date,
                          monthAnchor: monthAnchor,
                          selected: date == selectedDate,
                          isToday: date == today,
                          entryCount: entryCountFor(date),
                          onTap: actionPending ? null : () => onSelectDay(date),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthDayCell extends StatelessWidget {
  const _MonthDayCell({
    required this.date,
    required this.monthAnchor,
    required this.selected,
    required this.isToday,
    required this.entryCount,
    required this.onTap,
  });

  final CalendarDate date;
  final CalendarDate monthAnchor;
  final bool selected;
  final bool isToday;
  final int entryCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final outsideMonth =
        date.year != monthAnchor.year || date.month != monthAnchor.month;
    final localizations = MaterialLocalizations.of(context);
    final semanticLabel = StringBuffer(
      localizations.formatFullDate(DateTime(date.year, date.month, date.day)),
    );
    if (isToday) semanticLabel.write(', today');
    if (selected) semanticLabel.write(', selected');
    if (outsideMonth) semanticLabel.write(', outside displayed month');
    semanticLabel.write(
      entryCount == 1 ? ', 1 workout' : ', $entryCount workouts',
    );
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel.toString(),
      button: true,
      selected: selected,
      child: InkWell(
        key: ValueKey('month-day-${date.toIso()}'),
        onTap: onTap,
        canRequestFocus: true,
        child: SizedBox(
          width: 48,
          height: 56,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: selected ? colors.primaryContainer : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? colors.primary
                    : (isToday ? colors.tertiary : Colors.transparent),
                width: selected || isToday ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: outsideMonth ? colors.onSurfaceVariant : null,
                    fontWeight: selected || isToday ? FontWeight.w700 : null,
                  ),
                ),
                SizedBox(
                  height: 8,
                  child: entryCount == 0
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            entryCount.clamp(1, 3),
                            (_) => Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
