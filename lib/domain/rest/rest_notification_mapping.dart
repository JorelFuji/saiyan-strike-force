import '../../core/failure.dart';
import '../../core/result.dart';

const restNotificationTitle = 'Rest complete';
const restNotificationBody = 'Your rest timer finished.';

const restAlertsDeniedMessage =
    'Background rest alerts are off. The in-app timer still runs.';

const restExactAlarmDeniedMessage =
    'Precise background alerts need permission in system settings. '
    'The in-app timer still runs.';

/// One pending rest alert per session; notification id equals [sessionId].
int notificationIdForSession(int sessionId) => sessionId;

String encodeRestNotificationPayload(int sessionId) => sessionId.toString();

Result<int> parseRestNotificationPayload(String? payload) {
  if (payload == null || payload.isEmpty) {
    return const Err(
      ValidationFailure('Rest notification payload is missing.'),
    );
  }
  final id = int.tryParse(payload);
  if (id == null || id < 1) {
    return const Err(
      ValidationFailure('Rest notification payload is invalid.'),
    );
  }
  return Ok(id);
}
