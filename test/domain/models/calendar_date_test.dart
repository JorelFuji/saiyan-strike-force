import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';

void main() {
  test('parses and formats ISO calendar dates', () {
    final date = (CalendarDate.fromIso('2026-09-26') as Ok<CalendarDate>).value;
    expect(date.year, 2026);
    expect(date.month, 9);
    expect(date.day, 26);
    expect(date.toIso(), '2026-09-26');
  });

  test('rejects invalid ISO shapes and impossible days', () {
    expect(CalendarDate.fromIso('2026-9-26'), isA<Err<CalendarDate>>());
    expect(CalendarDate.fromIso('26-09-2026'), isA<Err<CalendarDate>>());
    expect(CalendarDate.fromIso('2026-13-01'), isA<Err<CalendarDate>>());
    expect(CalendarDate.fromIso('2026-02-30'), isA<Err<CalendarDate>>());
    expect(CalendarDate.fromIso('2025-02-29'), isA<Err<CalendarDate>>());
    expect(CalendarDate.fromIso('not-a-date'), isA<Err<CalendarDate>>());
  });

  test('accepts leap day on leap years only', () {
    expect(
      (CalendarDate.fromIso('2024-02-29') as Ok<CalendarDate>).value.toIso(),
      '2024-02-29',
    );
    expect(CalendarDate.fromIso('1900-02-29'), isA<Err<CalendarDate>>());
    expect(
      (CalendarDate.fromIso('2000-02-29') as Ok<CalendarDate>).value.toIso(),
      '2000-02-29',
    );
  });

  test('addDays crosses month and year boundaries', () {
    final endOfJan = (CalendarDate.create(
      year: 2026,
      month: 1,
      day: 31,
    ) as Ok<CalendarDate>).value;
    expect(endOfJan.addDays(1).toIso(), '2026-02-01');

    final endOfYear = (CalendarDate.create(
      year: 2026,
      month: 12,
      day: 31,
    ) as Ok<CalendarDate>).value;
    expect(endOfYear.addDays(1).toIso(), '2027-01-01');

    final leap = (CalendarDate.create(
      year: 2024,
      month: 2,
      day: 28,
    ) as Ok<CalendarDate>).value;
    expect(leap.addDays(1).toIso(), '2024-02-29');
    expect(leap.addDays(2).toIso(), '2024-03-01');

    final mid = (CalendarDate.create(
      year: 2026,
      month: 9,
      day: 26,
    ) as Ok<CalendarDate>).value;
    expect(mid.addDays(-7).toIso(), '2026-09-19');
  });

  test('compareTo and equality order calendar dates', () {
    final a = (CalendarDate.fromIso('2026-09-01') as Ok<CalendarDate>).value;
    final b = (CalendarDate.fromIso('2026-09-02') as Ok<CalendarDate>).value;
    final a2 = (CalendarDate.fromIso('2026-09-01') as Ok<CalendarDate>).value;

    expect(a.compareTo(b), lessThan(0));
    expect(b.compareTo(a), greaterThan(0));
    expect(a.compareTo(a2), 0);
    expect(a, a2);
    expect(a < b, isTrue);
    expect(b > a, isTrue);
  });
}
