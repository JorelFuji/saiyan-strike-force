import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/ui/planner/planner_state.dart';
import 'package:vulcan_fitness/ui/planner/widgets/month_grid.dart';

import '../../support/vulcan_test_app.dart';

void main() {
  CalendarDate date(String iso) =>
      (CalendarDate.fromIso(iso) as Ok<CalendarDate>).value;

  testWidgets('renders selectable full-week cells and bounded dots', (
    tester,
  ) async {
    final anchor = date('2026-05-01');
    final range = monthRangeFor(monthAnchor: anchor, firstDayOfWeekIndex: 0);
    CalendarDate? selected;
    var previous = 0;
    var next = 0;
    await tester.pumpWidget(
      vulcanMaterialApp(
        child: Scaffold(
          body: MonthGrid(
            monthAnchor: anchor,
            dates: range.dates,
            firstDayOfWeekIndex: 0,
            selectedDate: date('2026-04-26'),
            today: date('2026-05-01'),
            entryCountFor: (value) => value == date('2026-04-26') ? 5 : 0,
            onSelectDay: (value) => selected = value,
            onPreviousMonth: () => previous++,
            onNextMonth: () => next++,
          ),
        ),
      ),
    );

    expect(range.dates, hasLength(42));
    expect(find.byTooltip('Previous month'), findsOneWidget);
    expect(find.byTooltip('Next month'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('outside displayed month.*5 workouts')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('today')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('selected')), findsOneWidget);
    await tester.tap(find.byTooltip('Previous month'));
    await tester.tap(find.byTooltip('Next month'));
    await tester.tap(
      find.bySemanticsLabel(RegExp('outside displayed month.*5 workouts')),
    );
    expect(previous, 1);
    expect(next, 1);
    expect(selected, date('2026-04-26'));
  });

  testWidgets('renders four, five, and six complete week rows', (tester) async {
    for (final (anchor, expectedCells) in <(CalendarDate, int)>[
      (date('2026-02-01'), 28),
      (date('2024-02-01'), 35),
      (date('2026-05-01'), 42),
    ]) {
      final range = monthRangeFor(monthAnchor: anchor, firstDayOfWeekIndex: 0);
      await tester.pumpWidget(
        vulcanMaterialApp(
          child: Scaffold(
            body: MonthGrid(
              monthAnchor: anchor,
              dates: range.dates,
              firstDayOfWeekIndex: 0,
              selectedDate: anchor,
              today: anchor,
              entryCountFor: (_) => 0,
              onSelectDay: (_) {},
              onPreviousMonth: () {},
              onNextMonth: () {},
            ),
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget.key is ValueKey<String> &&
              (widget.key as ValueKey<String>).value.startsWith('month-day-'),
        ),
        findsNWidgets(expectedCells),
      );
    }
  });
}
