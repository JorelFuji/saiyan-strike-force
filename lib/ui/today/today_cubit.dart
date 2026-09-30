import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/services/timezone_service.dart';
import '../../domain/usecases/start_session.dart';
import 'today_state.dart';

final class TodayCubit extends Cubit<TodayState> {
  TodayCubit({
    required this.startSession,
    required this.timezoneService,
    required this.clock,
  }) : super(const TodayState());

  final StartSession startSession;
  final TimezoneService timezoneService;
  final Clock clock;

  Future<void> startFreestyle() async {
    if (state.startPending) return;
    emit(state.copyWith(startPending: true, clearFailure: true));
    final timezone = await timezoneService.localIanaIdentifier();
    if (isClosed) return;
    if (timezone case Err(:final failure)) {
      emit(
        state.copyWith(startPending: false, failureMessage: failure.message),
      );
      return;
    }
    final command = StartFreestyleSessionCommand.create(
      startedAt: clock.now(),
      timezone: (timezone as Ok<String>).value,
    );
    if (command case Err(:final failure)) {
      emit(
        state.copyWith(startPending: false, failureMessage: failure.message),
      );
      return;
    }
    final result = await startSession.startFreestyle(
      (command as Ok<StartFreestyleSessionCommand>).value,
    );
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            startPending: false,
            startedSessionId: value,
            clearFailure: true,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(startPending: false, failureMessage: failure.message),
        );
    }
  }

  void clearStartedSession() =>
      emit(state.copyWith(clearStartedSessionId: true));
}
