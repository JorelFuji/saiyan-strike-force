import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/ui/core/formatters/rest_duration_formatter.dart';

void main() {
  test('formats rest as minutes and seconds', () {
    expect(formatRestDuration(90), '1:30');
    expect(formatRestDuration(0), '0:00');
  });

  test('parses clock and whole-second values', () {
    expect((parseRestDuration('1:30') as Ok<int>).value, 90);
    expect((parseRestDuration('90') as Ok<int>).value, 90);
    expect(parseRestDuration('1:60'), isA<Err<int>>());
    expect(parseRestDuration('-1'), isA<Err<int>>());
    expect(parseRestDuration('oops'), isA<Err<int>>());
  });
}
