import '../core/result.dart';
import '../domain/rest/rest_notification_mapping.dart';

/// Chooses the session route after cold start when a notification may apply.
int? resolveStartupSessionRoute({
  required int? notificationSessionId,
  required int? resumableSessionId,
}) {
  if (notificationSessionId != null &&
      resumableSessionId != null &&
      notificationSessionId == resumableSessionId) {
    return notificationSessionId;
  }
  return resumableSessionId;
}

/// Validates a notification payload for warm tap routing.
int? parseNotificationTapSessionId(String? payload) {
  return switch (parseRestNotificationPayload(payload)) {
    Ok(:final value) => value,
    Err() => null,
  };
}
