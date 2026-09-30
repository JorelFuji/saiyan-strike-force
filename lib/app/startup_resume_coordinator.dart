import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/result.dart';
import '../domain/repositories/session_repository.dart';
import 'startup_session_route.dart';

/// Pushes a bootstrapped resumable session once after the tab shell mounts.
class StartupResumeCoordinator extends StatefulWidget {
  const StartupResumeCoordinator({
    required this.router,
    required this.sessionRepository,
    required this.resumeSessionId,
    required this.notificationTapSessionIds,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final SessionRepository sessionRepository;
  final int? resumeSessionId;
  final Stream<int> notificationTapSessionIds;
  final Widget child;

  @override
  State<StartupResumeCoordinator> createState() =>
      _StartupResumeCoordinatorState();
}

class _StartupResumeCoordinatorState extends State<StartupResumeCoordinator> {
  var _pushed = false;
  StreamSubscription<int>? _tapSubscription;

  @override
  void initState() {
    super.initState();
    _schedulePush(widget.resumeSessionId);
    _tapSubscription = widget.notificationTapSessionIds.listen(
      _onNotificationTap,
    );
  }

  @override
  void dispose() {
    unawaited(_tapSubscription?.cancel());
    super.dispose();
  }

  Future<void> _onNotificationTap(int sessionId) async {
    final resumable = await _readResumableSessionId();
    if (!mounted) {
      return;
    }
    final target = resolveStartupSessionRoute(
      notificationSessionId: sessionId,
      resumableSessionId: resumable,
    );
    if (target != null) {
      widget.router.push('/session/$target');
    }
  }

  Future<int?> _readResumableSessionId() async {
    final result = await widget.sessionRepository.findResumableSessionId();
    return switch (result) {
      Ok(:final value) => value,
      Err() => null,
    };
  }

  void _schedulePush(int? id) {
    if (id == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pushed) {
        return;
      }
      _pushSession(id);
    });
  }

  void _pushSession(int id) {
    if (_pushed) {
      return;
    }
    _pushed = true;
    widget.router.push('/session/$id');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
