import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/app/startup_session_route.dart';

void main() {
  test('prefers notification session when it matches resumable id', () {
    expect(
      resolveStartupSessionRoute(
        notificationSessionId: 5,
        resumableSessionId: 5,
      ),
      5,
    );
  });

  test('falls back to resumable id when notification id mismatches', () {
    expect(
      resolveStartupSessionRoute(
        notificationSessionId: 5,
        resumableSessionId: 7,
      ),
      7,
    );
  });

  test('ignores invalid notification payloads', () {
    expect(parseNotificationTapSessionId('0'), isNull);
    expect(parseNotificationTapSessionId('-1'), isNull);
    expect(parseNotificationTapSessionId('nope'), isNull);
    expect(parseNotificationTapSessionId('4'), 4);
  });
}
