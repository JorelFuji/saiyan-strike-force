import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/local_start_time.dart';

void main() {
  test('accepts minutes in 0…1439', () {
    expect(
      (LocalStartTime.create(
        0,
      ) as Ok<LocalStartTime>).value.minutesFromMidnight,
      0,
    );
    expect(
      (LocalStartTime.create(
        1439,
      ) as Ok<LocalStartTime>).value.minutesFromMidnight,
      1439,
    );
    expect(
      (LocalStartTime.create(
        90,
      ) as Ok<LocalStartTime>).value.minutesFromMidnight,
      90,
    );
  });

  test('rejects values outside 0…1439', () {
    expect(LocalStartTime.create(-1), isA<Err<LocalStartTime>>());
    expect(LocalStartTime.create(1440), isA<Err<LocalStartTime>>());
  });
}
