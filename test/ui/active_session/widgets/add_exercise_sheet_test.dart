import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
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
}
