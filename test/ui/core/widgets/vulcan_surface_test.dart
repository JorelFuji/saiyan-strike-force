import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/ui/core/widgets/vulcan_surface.dart';

import '../../../support/vulcan_test_app.dart';

void main() {
  Widget wrap(Widget child, {bool disableAnimations = false}) {
    return vulcanMaterialApp(
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('renders raised surface with minimum 48dp constraints', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(VulcanSurface(onTap: () {}, child: const Text('Start'))),
    );

    final box = tester.getSize(find.byType(VulcanSurface));
    expect(box.width, greaterThanOrEqualTo(48));
    expect(box.height, greaterThanOrEqualTo(48));
  });

  testWidgets('shows focus border when focused', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(
        VulcanSurface(
          onTap: () {},
          semanticsLabel: 'Primary action',
          child: const Text('Tap'),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final decorationFinder = find.descendant(
      of: find.byType(VulcanSurface),
      matching: find.byType(AnimatedContainer),
    );
    expect(decorationFinder, findsOneWidget);
    final container = tester.widget<AnimatedContainer>(decorationFinder);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.border, isNotNull);
    expect(decoration.border!.top.width, greaterThanOrEqualTo(2));
  });

  testWidgets('pressed state uses inset decoration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(VulcanSurface(onTap: () {}, child: const Text('Press'))),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(VulcanSurface)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(VulcanSurface),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.border?.top.width, 2);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('reduce motion skips scale animation duration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        VulcanSurface(onTap: () {}, child: const Text('Motion')),
        disableAnimations: true,
      ),
    );

    final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scale.duration, Duration.zero);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(VulcanSurface)),
    );
    await tester.pump();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await gesture.up();
  });
}
