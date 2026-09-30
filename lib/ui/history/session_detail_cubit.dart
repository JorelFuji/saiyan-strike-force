import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/mass.dart';
import '../../domain/models/session_status.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import 'session_detail_state.dart';

final class SessionDetailCubit extends Cubit<SessionDetailState> {
  SessionDetailCubit({
    required this.sessionId,
    required SessionRepository sessionRepository,
    required SettingsRepository settingsRepository,
  }) : _sessions = sessionRepository,
       _settings = settingsRepository,
       super(const SessionDetailState());

  final int sessionId;
  final SessionRepository _sessions;
  final SettingsRepository _settings;

  Future<void> initialize() async {
    emit(
      state.copyWith(
        loadPhase: SessionDetailLoadPhase.loading,
        clearFailureMessage: true,
        clearSession: true,
      ),
    );

    final unitResult = await _settings.readOrCreateDisplayMassUnit();
    if (isClosed) return;
    if (unitResult case Err(:final failure)) {
      emit(
        state.copyWith(
          loadPhase: SessionDetailLoadPhase.failure,
          failureMessage: failure.message,
        ),
      );
      return;
    }
    final unit = (unitResult as Ok<MassUnit>).value;

    final sessionResult = await _sessions.getById(sessionId);
    if (isClosed) return;
    switch (sessionResult) {
      case Ok(:final value):
        if (value.status != SessionStatus.finished) {
          emit(
            state.copyWith(
              massUnit: unit,
              loadPhase: SessionDetailLoadPhase.notFound,
              clearSession: true,
              failureMessage: 'This session is not available in History.',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            massUnit: unit,
            session: value,
            loadPhase: SessionDetailLoadPhase.ready,
            clearFailureMessage: true,
          ),
        );
      case Err(:final failure):
        if (failure is NotFoundFailure) {
          emit(
            state.copyWith(
              massUnit: unit,
              loadPhase: SessionDetailLoadPhase.notFound,
              clearSession: true,
              failureMessage: failure.message,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            massUnit: unit,
            loadPhase: SessionDetailLoadPhase.failure,
            clearSession: true,
            failureMessage: failure.message,
          ),
        );
    }
  }

  Future<void> retry() => initialize();
}
