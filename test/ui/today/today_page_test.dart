import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/clock.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/usecases/start_session.dart';
import 'package:vulcan_fitness/ui/today/today_cubit.dart';
import 'package:vulcan_fitness/ui/today/today_page.dart';

import '../../support/fake_session_repository.dart';
import '../../support/fake_timezone_service.dart';

final class _Clock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 9, 29);
}

void main() {
  testWidgets('offers an accessible freestyle start control', (tester) async {
    final sessions = FakeSessionRepository()
      ..startFreestyleResult = const Err(StorageFailure('write failed'));
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => TodayCubit(
            startSession: StartSession(sessions),
            timezoneService: FakeTimezoneService(),
            clock: _Clock(),
          ),
          child: const TodayPage(),
        ),
      ),
    );
    expect(find.text('Start Freestyle Workout'), findsOneWidget);
    await tester.tap(find.text('Start Freestyle Workout'));
    await tester.pump();
    expect(sessions.startFreestyleCalls, 1);
    expect(find.text('Retry'), findsOneWidget);
  });
}
