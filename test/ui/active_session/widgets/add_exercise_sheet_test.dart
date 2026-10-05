import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/ui/active_session/widgets/add_exercise_sheet.dart';

void main() {
  testWidgets('shows visible editable freestyle defaults', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AddExerciseSheet(massUnit: MassUnit.kg)),
      ),
    );
    expect(find.text('Add exercise'), findsNWidgets(2));
    expect(find.text('Initial sets'), findsOneWidget);
    expect(find.text('Rep mode'), findsOneWidget);
    expect(find.text('Load mode'), findsOneWidget);
    expect(find.text('Rest seconds'), findsOneWidget);
  });

  testWidgets('Load mode menu shows Weight instead of Absolute weight', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AddExerciseSheet(massUnit: MassUnit.kg)),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<LoadType>));
    await tester.pumpAndSettle();

    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('Absolute weight'), findsNothing);
    expect(find.text('absolute'), findsNothing);
    expect(find.text('No load'), findsWidgets);
    expect(find.text('Bodyweight'), findsOneWidget);
  });
}
