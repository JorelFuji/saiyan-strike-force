import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/services/notification_service.dart';

final class FakeNotificationService implements NotificationService {
  int initializeCalls = 0;
  int scheduleCalls = 0;
  int cancelCalls = 0;
  int permissionCalls = 0;
  int exactAlarmCalls = 0;

  Result<void> initializeResult = const Ok(null);
  Result<bool> permissionResult = const Ok(true);
  Result<bool> exactAlarmResult = const Ok(true);
  Result<void> scheduleResult = const Ok(null);
  Result<void> cancelResult = const Ok(null);
  Result<int?> coldStartSessionId = const Ok(null);

  RestNotificationTapHandler? onTap;
  final List<int> scheduledSessionIds = [];
  final List<int> canceledSessionIds = [];

  @override
  Future<Result<void>> initialize({RestNotificationTapHandler? onTap}) async {
    initializeCalls++;
    this.onTap = onTap;
    return initializeResult;
  }

  @override
  Future<Result<bool>> requestNotificationPermission() async {
    permissionCalls++;
    return permissionResult;
  }

  @override
  Future<Result<bool>> canScheduleExactAlarms({
    bool openSettingsIfNeeded = false,
  }) async {
    exactAlarmCalls++;
    return exactAlarmResult;
  }

  @override
  Future<Result<void>> scheduleRestAlert({
    required int sessionId,
    required DateTime targetAtUtc,
    required String ianaTimeZone,
  }) async {
    scheduleCalls++;
    scheduledSessionIds.add(sessionId);
    return scheduleResult;
  }

  @override
  Future<Result<void>> cancelRestAlert(int sessionId) async {
    cancelCalls++;
    canceledSessionIds.add(sessionId);
    return cancelResult;
  }

  @override
  Future<Result<int?>> readColdStartSessionId() async => coldStartSessionId;

  void simulateTap(int sessionId) => onTap?.call(sessionId);
}
