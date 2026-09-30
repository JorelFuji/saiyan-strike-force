import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/ui/active_session/widgets/rest_timer_controls.dart';

import '../../support/vulcan_test_app.dart';

void main() {
  testWidgets('rest controls invoke callbacks with 48dp targets', (
    tester,
  ) async {
    var skip = false;
    var minus = false;
    var plus = false;
    var reset = false;

    await tester.pumpWidget(
      vulcanMaterialApp(
        child: Scaffold(
          body: RestTimerControls(
            enabled: true,
            onSkip: () => skip = true,
            onSubtractThirty: () => minus = true,
            onAddThirty: () => plus = true,
            onReset: () => reset = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Skip rest'));
    await tester.tap(find.text('−30s'));
    await tester.tap(find.text('+30s'));
    await tester.tap(find.text('Reset'));

    expect(skip, isTrue);
    expect(minus, isTrue);
    expect(plus, isTrue);
    expect(reset, isTrue);
    expect(tester.getSize(find.byType(OutlinedButton).first).height, 48);
  });
}
