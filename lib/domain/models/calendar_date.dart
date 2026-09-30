import '../../core/failure.dart';
import '../../core/result.dart';

/// A local calendar date (year/month/day), never an instant.
///
/// Planner and schedule storage use this type so day arithmetic and ISO
/// round-trips stay free of timezone/`DateTime` instant semantics.
final class CalendarDate implements Comparable<CalendarDate> {
  const CalendarDate._(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  /// Creates a validated calendar date.
  static Result<CalendarDate> create({
    required int year,
    required int month,
    required int day,
  }) {
    if (year < 1 || year > 9999) {
      return const Err(ValidationFailure('Calendar year is out of range.'));
    }
    if (month < 1 || month > 12) {
      return const Err(ValidationFailure('Calendar month is out of range.'));
    }
    if (day < 1 || day > _daysInMonth(year, month)) {
      return const Err(ValidationFailure('Calendar day is out of range.'));
    }
    return Ok(CalendarDate._(year, month, day));
  }

  /// Parses `YYYY-MM-DD` with independent validation (not `DateTime.parse`).
  static Result<CalendarDate> fromIso(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      return const Err(ValidationFailure('Calendar date must be YYYY-MM-DD.'));
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    return create(year: year, month: month, day: day);
  }

  /// Formats as `YYYY-MM-DD`.
  String toIso() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Returns this date shifted by [days] (may be negative).
  CalendarDate addDays(int days) {
    // UTC DateTime is an internal arithmetic helper only — not a public API.
    final shifted = DateTime.utc(year, month, day).add(Duration(days: days));
    return CalendarDate._(shifted.year, shifted.month, shifted.day);
  }

  @override
  int compareTo(CalendarDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  bool operator <(CalendarDate other) => compareTo(other) < 0;
  bool operator <=(CalendarDate other) => compareTo(other) <= 0;
  bool operator >(CalendarDate other) => compareTo(other) > 0;
  bool operator >=(CalendarDate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDate &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => 'CalendarDate(${toIso()})';

  static int _daysInMonth(int year, int month) {
    const lengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && _isLeapYear(year)) {
      return 29;
    }
    return lengths[month - 1];
  }

  static bool _isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
}
