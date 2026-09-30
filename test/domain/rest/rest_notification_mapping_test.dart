import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/rest/rest_notification_mapping.dart';

void main() {
  test('notification id equals positive session id', () {
    expect(notificationIdForSession(7), 7);
  });

  test('payload round-trip accepts positive ids only', () {
    expect(encodeRestNotificationPayload(12), '12');
    expect((parseRestNotificationPayload('12') as Ok<int>).value, 12);
    expect(parseRestNotificationPayload('0'), isA<Err<int>>());
    expect(parseRestNotificationPayload('-3'), isA<Err<int>>());
    expect(parseRestNotificationPayload('abc'), isA<Err<int>>());
    expect(parseRestNotificationPayload(null), isA<Err<int>>());
    expect(
      (parseRestNotificationPayload('0') as Err<int>).failure,
      isA<ValidationFailure>(),
    );
  });
}
