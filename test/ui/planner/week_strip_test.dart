import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/ui/planner/widgets/week_strip.dart';

import '../../support/vulcan_test_app.dart';

void main() {
  final weekStart =
      (CalendarDate.fromIso('2026-09-21') as Ok<CalendarDate>).value;
  final today = (CalendarDate.fromIso('2026-09-24') as Ok<CalendarDate>).value;

  testWidgets('selects days and invokes week navigation', (tester) async {
    CalendarDate? selected = today;
    var previous = 0;
    var next = 0;
    final counts = <CalendarDate, int>{weekStart.addDays(2): 2};

    await tester.pumpWidget(
      vulcanMaterialApp(
        child: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return WeekStrip(
                weekStart: weekStart,
                selectedDate: selected!,
                today: today,
                entryCountFor: (date) => counts[date] ?? 0,
                onSelectDay: (date) => setState(() => selected = date),
                onPreviousWeek: () => previous++,
                onNextWeek: () => next++,
              );
            },
          ),
        ),
      ),
    );

    expect(find.byTooltip('Previous week'), findsOneWidget);
    expect(find.byTooltip('Next week'), findsOneWidget);

    await tester.tap(find.byTooltip('Next week'));
    await tester.pump();
    expect(next, 1);

    await tester.tap(find.byTooltip('Previous week'));
    await tester.pump();
    expect(previous, 1);

    await tester.tap(find.text('21'));
    await tester.pump();
    expect(selected, weekStart);
  });

  testWidgets('announces selected day semantics', (tester) async {
    await tester.pumpWidget(
      vulcanMaterialApp(
        child: Scaffold(
          body: WeekStrip(
            weekStart: weekStart,
            selectedDate: today,
            today: today,
            entryCountFor: (_) => 1,
            onSelectDay: (_) {},
            onPreviousWeek: () {},
            onNextWeek: () {},
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel(RegExp('selected')), findsWidgets);
  });
}
