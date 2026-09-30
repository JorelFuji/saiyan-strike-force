import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/rest/rest_notification_mapping.dart';
import '../../domain/services/notification_service.dart';

const _restChannelId = 'vulcan_rest_timer';
const _restChannelName = 'Rest timer';
const _restChannelDescription = 'Alerts when a rest period ends';

/// Loads IANA zones for zoned scheduling; call once during bootstrap.
void initializeTimezoneDatabase() {
  tzdata.initializeTimeZones();
}

final class FlutterLocalNotificationService implements NotificationService {
  FlutterLocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  var _initialized = false;
  RestNotificationTapHandler? _onTap;

  @override
  Future<Result<void>> initialize({RestNotificationTapHandler? onTap}) async {
    if (_initialized) {
      _onTap = onTap;
      return const Ok(null);
    }
    _onTap = onTap;
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      final initialized = await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
          macOS: darwinSettings,
        ),
        onDidReceiveNotificationResponse: _handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            _notificationTapBackgroundHandler,
      );
      if (initialized != true) {
        return const Err(
          StorageFailure('Notification plugin failed to initialize.'),
        );
      }
      if (!kIsWeb && Platform.isAndroid) {
        await _androidPlugin?.createNotificationChannel(
          const AndroidNotificationChannel(
            _restChannelId,
            _restChannelName,
            description: _restChannelDescription,
            importance: Importance.defaultImportance,
          ),
        );
      }
      _initialized = true;
      return const Ok(null);
    } on Exception catch (error, stack) {
      return Err(
        StorageFailure(
          'Notification plugin failed to initialize.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> requestNotificationPermission() async {
    try {
      if (kIsWeb) {
        return const Ok(true);
      }
      if (Platform.isAndroid) {
        final granted = await _androidPlugin?.requestNotificationsPermission();
        return Ok(granted ?? false);
      }
      if (Platform.isIOS) {
        final granted = await _iosPlugin?.requestPermissions(
          alert: true,
          badge: false,
          sound: true,
        );
        return Ok(granted ?? false);
      }
      return const Ok(true);
    } on Exception catch (error, stack) {
      return Err(
        PermissionFailure(
          'Unable to request notification permission.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> canScheduleExactAlarms({
    bool openSettingsIfNeeded = false,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      return const Ok(true);
    }
    try {
      final android = _androidPlugin;
      if (android == null) {
        return const Ok(false);
      }
      var canSchedule = await android.canScheduleExactNotifications() ?? false;
      if (!canSchedule && openSettingsIfNeeded) {
        await android.requestExactAlarmsPermission();
        canSchedule = await android.canScheduleExactNotifications() ?? false;
      }
      return Ok(canSchedule);
    } on Exception catch (error, stack) {
      return Err(
        PermissionFailure(
          'Unable to read exact alarm capability.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void>> scheduleRestAlert({
    required int sessionId,
    required DateTime targetAtUtc,
    required String ianaTimeZone,
  }) async {
    if (!_initialized) {
      return const Err(StorageFailure('Notifications are not initialized.'));
    }
    if (sessionId < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    try {
      final location = tz.getLocation(ianaTimeZone);
      final scheduled = tz.TZDateTime.from(targetAtUtc.toUtc(), location);

      AndroidScheduleMode scheduleMode =
          AndroidScheduleMode.inexactAllowWhileIdle;
      if (!kIsWeb && Platform.isAndroid) {
        final exact = await canScheduleExactAlarms();
        if (exact case Ok(:final value) when value) {
          scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
        }
      }

      await _plugin.zonedSchedule(
        id: notificationIdForSession(sessionId),
        scheduledDate: scheduled,
        androidScheduleMode: scheduleMode,
        title: restNotificationTitle,
        body: restNotificationBody,
        payload: encodeRestNotificationPayload(sessionId),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _restChannelId,
            _restChannelName,
            channelDescription: _restChannelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            visibility: NotificationVisibility.private,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
          ),
        ),
      );
      return const Ok(null);
    } on Exception catch (error, stack) {
      return Err(
        StorageFailure(
          'Unable to schedule rest notification.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void>> cancelRestAlert(int sessionId) async {
    if (sessionId < 1) {
      return const Err(ValidationFailure('Session ID must be positive.'));
    }
    try {
      await _plugin.cancel(id: notificationIdForSession(sessionId));
      return const Ok(null);
    } on Exception catch (error, stack) {
      return Err(
        StorageFailure(
          'Unable to cancel rest notification.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<int?>> readColdStartSessionId() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp != true) {
        return const Ok(null);
      }
      return switch (parseRestNotificationPayload(
        details?.notificationResponse?.payload,
      )) {
        Ok(:final value) => Ok(value),
        Err() => const Ok(null),
      };
    } on Exception catch (error, stack) {
      return Err(
        StorageFailure(
          'Unable to read notification launch details.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final parsed = parseRestNotificationPayload(response.payload);
    if (parsed case Ok(:final value)) {
      _onTap?.call(value);
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _iosPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();
}

@pragma('vm:entry-point')
void _notificationTapBackgroundHandler(NotificationResponse response) {
  // Tap routing while terminated is handled via launch details at startup.
}
