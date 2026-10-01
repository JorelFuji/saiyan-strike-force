import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/ui/active_session/rest_timer_coordinator.dart';

import '../../support/fake_notification_service.dart';
import '../../support/fake_session_repository.dart';

void main() {
  test(
    'persists rest before scheduling and degrades denied permission',
    () async {
      final sessions = FakeSessionRepository();
      final notifications = FakeNotificationService()
        ..permissionResult = const Ok(false);
      final coordinator = RestTimerCoordinator(
        sessionId: 1,
        sessions: sessions,
        notifications: notifications,
      );
      final rest = (AbsoluteRestState.create(
        startedAt: DateTime.utc(2026),
        durationSeconds: 60,
      ) as Ok<AbsoluteRestState>).value;
      final result = await coordinator.commit(rest, 'UTC');
      expect(sessions.updateRestCalls, 1);
      expect(notifications.scheduleCalls, 0);
      expect(result, isA<RestAlertDegraded>());
    },
  );

  test('failed persistence never schedules', () async {
    final sessions = FakeSessionRepository()
      ..updateRestResult = const Err(StorageFailure('no write'));
    final notifications = FakeNotificationService();
    final coordinator = RestTimerCoordinator(
      sessionId: 1,
      sessions: sessions,
      notifications: notifications,
    );
    final rest = (AbsoluteRestState.create(
      startedAt: DateTime.utc(2026),
      durationSeconds: 60,
    ) as Ok<AbsoluteRestState>).value;
    await coordinator.commit(rest, 'UTC');
    expect(notifications.scheduleCalls, 0);
  });
}
