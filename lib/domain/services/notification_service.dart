import '../../core/result.dart';

typedef RestNotificationTapHandler = void Function(int sessionId);

abstract interface class NotificationService {
  Future<Result<void>> initialize({RestNotificationTapHandler? onTap});

  Future<Result<bool>> requestNotificationPermission();

  /// When [openSettingsIfNeeded] is true, may launch system settings on Android.
  Future<Result<bool>> canScheduleExactAlarms({bool openSettingsIfNeeded});

  Future<Result<void>> scheduleRestAlert({
    required int sessionId,
    required DateTime targetAtUtc,
    required String ianaTimeZone,
  });

  Future<Result<void>> cancelRestAlert(int sessionId);

  Future<Result<int?>> readColdStartSessionId();
}
