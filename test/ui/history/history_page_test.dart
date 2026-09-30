import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/calendar_date.dart';
import 'package:vulcan_fitness/domain/models/completed_session_summary.dart';
import 'package:vulcan_fitness/domain/repositories/session_repository.dart';
import 'package:vulcan_fitness/domain/repositories/settings_repository.dart';
import 'package:vulcan_fitness/ui/history/history_list_cubit.dart';
import 'package:vulcan_fitness/ui/history/history_page.dart';

import '../../support/fake_session_repository.dart';
import '../../support/fake_settings_repository.dart';
import '../../support/vulcan_test_app.dart';

void main() {
  final day = (CalendarDate.fromIso('2026-09-01') as Ok<CalendarDate>).value;

  CompletedSessionSummary summary({
    int id = 1,
    String name = 'Push',
    CalendarDate? on,
  }) {
    return (CompletedSessionSummary.create(
      id: id,
      workoutNameSnapshot: name,
      startedOn: on ?? day,
      startedAt: DateTime.utc(2026, 9, 1, 15),
      endedAt: DateTime.utc(2026, 9, 1, 16, 30),
      timezone: 'America/Denver',
      completedSetCount: 18,
      totalSetCount: 20,
      absoluteVolumeMilligramReps: 1000000,
    ) as Ok<CompletedSessionSummary>).value;
  }

  Future<void> pumpHistory(
    WidgetTester tester, {
    FakeSessionRepository? sessions,
    FakeSettingsRepository? settings,
    double textScale = 1,
  }) async {
    final sessionRepo = sessions ?? FakeSessionRepository();
    final settingsRepo = settings ?? FakeSettingsRepository();
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/history',
          builder: (context, state) => BlocProvider(
            create: (_) => HistoryListCubit(
              sessionRepository: sessionRepo,
              settingsRepository: settingsRepo,
            )..initialize(),
            child: const HistoryPage(),
          ),
          routes: [
            GoRoute(
              path: 'session/:sessionId',
              builder: (context, state) => Scaffold(
                body: Text('Detail ${state.pathParameters['sessionId']}'),
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SessionRepository>.value(value: sessionRepo),
          RepositoryProvider<SettingsRepository>.value(value: settingsRepo),
        ],
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: vulcanMaterialAppRouter(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows empty state when no finished sessions', (tester) async {
    final sessions = FakeSessionRepository()
      ..summarySeedEvents.add(const Ok([]));
    await pumpHistory(tester, sessions: sessions);
    expect(find.text('No completed sessions yet.'), findsOneWidget);
    expect(find.byKey(const Key('history_name_filter')), findsOneWidget);
  });

  testWidgets('shows grouped sessions and navigates on tap', (tester) async {
    final sessions = FakeSessionRepository()
      ..summarySeedEvents.add(
        Ok([summary(id: 2, name: 'Pull'), summary(id: 1, name: 'Push')]),
      );
    await pumpHistory(tester, sessions: sessions);

    expect(find.text('Sep 1, 2026'), findsOneWidget);
    expect(find.text('Push'), findsOneWidget);
    expect(find.text('Pull'), findsOneWidget);
    expect(find.textContaining('18/20'), findsWidgets);

    await tester.tap(find.text('Push'));
    await tester.pumpAndSettle();
    expect(find.text('Detail 1'), findsOneWidget);
  });

  testWidgets('filters by name and shows filter-empty copy', (tester) async {
    final sessions = FakeSessionRepository()
      ..summarySeedEvents.add(Ok([summary(name: 'Push')]));
    await pumpHistory(tester, sessions: sessions);

    await tester.enterText(find.byKey(const Key('history_name_filter')), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No sessions match these filters.'), findsOneWidget);
  });

  testWidgets('shows error state with retry affordance', (tester) async {
    final sessions = FakeSessionRepository()
      ..summarySeedEvents.add(const Err(StorageFailure('load failed')));
    await pumpHistory(tester, sessions: sessions);
    expect(find.text('load failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('large text smoke keeps list readable', (tester) async {
    final sessions = FakeSessionRepository()
      ..summarySeedEvents.add(Ok([summary()]));
    await pumpHistory(tester, sessions: sessions, textScale: 1.6);
    expect(find.text('Push'), findsOneWidget);
    expect(find.byKey(const Key('history_date_range_button')), findsOneWidget);
  });
}
