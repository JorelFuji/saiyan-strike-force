// ignore_for_file: curly_braces_in_flow_control_structures, prefer_initializing_formals

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/active_session.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/rest/rest_notification_mapping.dart';

/// Coordinates durable rest changes with their best-effort OS alert.
final class RestTimerCoordinator {
  RestTimerCoordinator({
    required int sessionId,
    required SessionRepository sessions,
    required NotificationService notifications,
  }) : _sessionId = sessionId,
       _sessions = sessions,
       _notifications = notifications;

  final int _sessionId;
  final SessionRepository _sessions;
  final NotificationService _notifications;
  bool _requestedPermission = false;
  bool _permitted = true;
  bool _promptedExactAlarmSettings = false;
  DateTime? _lastScheduledTarget;

  Future<RestTimerOutcome> commit(
    AbsoluteRestState rest,
    String timezone,
  ) async {
    final command = UpdateSessionRestCommand.create(
      sessionId: _sessionId,
      rest: rest,
    );
    if (command case Err(:final failure))
      return RestTimerOutcome.persistenceFailure(failure);
    final persisted = await _sessions.updateSessionRest((command as Ok).value);
    if (persisted case Err(:final failure))
      return RestTimerOutcome.persistenceFailure(failure);
    return _schedule(rest, timezone);
  }

  Future<RestTimerOutcome> clear() async {
    final command = ClearSessionRestCommand.create(sessionId: _sessionId);
    if (command case Err(:final failure))
      return RestTimerOutcome.persistenceFailure(failure);
    final persisted = await _sessions.clearSessionRest((command as Ok).value);
    if (persisted case Err(:final failure))
      return RestTimerOutcome.persistenceFailure(failure);
    return cancel();
  }

  Future<RestTimerOutcome> successfulSetFollowUp(
    AbsoluteRestState? rest,
    String timezone,
  ) => rest == null ? cancel() : _schedule(rest, timezone);

  Future<RestTimerOutcome> reconcile(
    AbsoluteRestState rest,
    String timezone,
  ) async {
    if (_lastScheduledTarget == rest.targetAt) {
      return const RestTimerOutcome.success();
    }
    return _schedule(rest, timezone);
  }

  Future<RestTimerOutcome> cancel() async {
    _lastScheduledTarget = null;
    final result = await _notifications.cancelRestAlert(_sessionId);
    return switch (result) {
      Ok() => const RestTimerOutcome.cancelled(),
      Err(:final failure) => RestTimerOutcome.alertFailure(failure),
    };
  }

  Future<RestTimerOutcome> _schedule(
    AbsoluteRestState rest,
    String timezone,
  ) async {
    if (!_permitted)
      return const RestTimerOutcome.degraded(restAlertsDeniedMessage);
    if (!_requestedPermission) {
      _requestedPermission = true;
      final permission = await _notifications.requestNotificationPermission();
      if (permission case Ok(value: false)) {
        _permitted = false;
        return const RestTimerOutcome.degraded(restAlertsDeniedMessage);
      }
    }
    var degradedMessage = false;
    if (!_promptedExactAlarmSettings) {
      final exact = await _notifications.canScheduleExactAlarms();
      if (exact case Ok(value: false)) {
        final afterPrompt = await _notifications.canScheduleExactAlarms(
          openSettingsIfNeeded: true,
        );
        _promptedExactAlarmSettings = true;
        if (afterPrompt case Ok(value: false)) degradedMessage = true;
      }
    } else {
      final exact = await _notifications.canScheduleExactAlarms();
      if (exact case Ok(value: false)) degradedMessage = true;
    }
    final scheduled = await _notifications.scheduleRestAlert(
      sessionId: _sessionId,
      targetAtUtc: rest.targetAt,
      ianaTimeZone: timezone,
    );
    if (scheduled case Err(:final failure))
      return RestTimerOutcome.alertFailure(failure);
    _lastScheduledTarget = rest.targetAt;
    return degradedMessage
        ? const RestTimerOutcome.degraded(restExactAlarmDeniedMessage)
        : const RestTimerOutcome.success();
  }
}

sealed class RestTimerOutcome {
  const RestTimerOutcome();
  const factory RestTimerOutcome.success() = RestTimerSuccess;
  const factory RestTimerOutcome.cancelled() = RestTimerCancelled;
  const factory RestTimerOutcome.persistenceFailure(Failure failure) =
      RestPersistenceFailure;
  const factory RestTimerOutcome.alertFailure(Failure failure) =
      RestAlertFailure;
  const factory RestTimerOutcome.degraded(String message) = RestAlertDegraded;
}

final class RestTimerSuccess extends RestTimerOutcome {
  const RestTimerSuccess();
}

final class RestTimerCancelled extends RestTimerOutcome {
  const RestTimerCancelled();
}

final class RestPersistenceFailure extends RestTimerOutcome {
  const RestPersistenceFailure(this.failure);
  final Failure failure;
}

final class RestAlertFailure extends RestTimerOutcome {
  const RestAlertFailure(this.failure);
  final Failure failure;
}

final class RestAlertDegraded extends RestTimerOutcome {
  const RestAlertDegraded(this.message);
  final String message;
}
