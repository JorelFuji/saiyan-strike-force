import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/clock.dart';

void main() {
  test('SystemClock returns a UTC instant', () {
    final now = const SystemClock().now();

    expect(now.isUtc, isTrue);
  });

  test('a Clock fake provides deterministic time', () {
    final expected = DateTime.utc(2026, 9, 22, 12);
    final clock = _FixedClock(expected);

    expect(clock.now(), expected);
  });
}

final class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}
