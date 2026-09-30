import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/data/services/flutter_local_notification_service.dart';
import 'package:vulcan_fitness/domain/rest/rest_notification_mapping.dart';

void main() {
  test('timezone database initialization is idempotent', () {
    initializeTimezoneDatabase();
    initializeTimezoneDatabase();
  });

  test('notification ids follow session mapping contract', () {
    expect(notificationIdForSession(42), 42);
    expect(encodeRestNotificationPayload(42), '42');
  });
}
