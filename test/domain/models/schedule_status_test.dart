import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/schedule_status.dart';

void main() {
  test('decodes every wire status and rejects corrupt values', () {
    for (final status in ScheduleStatus.values) {
      expect(
        (ScheduleStatus.fromWire(status.wireValue) as Ok<ScheduleStatus>).value,
        status,
      );
    }
    expect(ScheduleStatus.fromWire('missed'), isA<Err<ScheduleStatus>>());
    expect(ScheduleStatus.fromWire('planned '), isA<Err<ScheduleStatus>>());
    expect(ScheduleStatus.fromWire(''), isA<Err<ScheduleStatus>>());
  });
}
