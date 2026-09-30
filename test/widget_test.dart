import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drift/native.dart';
import 'package:vulcan_fitness/app/app.dart';
import 'package:vulcan_fitness/app/dependencies.dart';
import 'package:vulcan_fitness/data/database/app_database.dart';
import 'package:vulcan_fitness/ui/core/app_shell.dart';

import 'support/fake_notification_service.dart';

void main() {
  testWidgets('VulcanApp mounts repository providers and tab shell', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      VulcanApp(
        dependencies: AppDependencies(
          database: database,
          notificationService: FakeNotificationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Today'), findsWidgets);

    expect(tester.takeException(), isNull);
  });

  testWidgets('fatal storage app never reveals a failure cause', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FatalStorageApp());

    expect(find.text('Unable to open storage.'), findsOneWidget);
    expect(find.textContaining('private cause'), findsNothing);
  });
}
