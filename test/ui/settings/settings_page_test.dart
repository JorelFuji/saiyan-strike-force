import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/theme_mode.dart';
import 'package:vulcan_fitness/ui/core/theme/theme_controller.dart';
import 'package:vulcan_fitness/ui/core/theme/vulcan_theme.dart';
import 'package:vulcan_fitness/ui/settings/settings_cubit.dart';
import 'package:vulcan_fitness/ui/settings/settings_page.dart';

import '../../support/fake_settings_repository.dart';

void main() {
  testWidgets('shows accessible appearance choices with large text', (
    WidgetTester tester,
  ) async {
    final settings = FakeSettingsRepository(
      themeModeResult: const Ok(VulcanThemeMode.system),
    );
    final controller = ThemeController(settingsRepository: settings);
    await controller.initialize();
    addTearDown(controller.dispose);
    final cubit = SettingsCubit(themeController: controller)..initialize();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: VulcanTheme.light(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: BlocProvider.value(value: cubit, child: const SettingsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(
        'Exported JSON is plaintext training data shared by the app you choose.',
      ),
      200,
    );
    expect(find.text('Your data lives on this device only.'), findsOneWidget);
    expect(
      find.text(
        'Exported JSON is plaintext training data shared by the app you choose.',
      ),
      findsOneWidget,
    );
    expect(find.text('Export data'), findsOneWidget);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    expect(
      tester.getSize(find.byType(ListTile).first).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byType(OutlinedButton)).height,
      greaterThanOrEqualTo(48),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting a mode updates after commit', (
    WidgetTester tester,
  ) async {
    final settings = FakeSettingsRepository(
      themeModeResult: const Ok(VulcanThemeMode.system),
    );
    final controller = ThemeController(settingsRepository: settings);
    await controller.initialize();
    addTearDown(controller.dispose);
    final cubit = SettingsCubit(themeController: controller)..initialize();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: VulcanTheme.light(),
        home: BlocProvider.value(value: cubit, child: const SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(controller.committed, VulcanThemeMode.dark);
    expect(cubit.state.committedMode, VulcanThemeMode.dark);
  });
}
