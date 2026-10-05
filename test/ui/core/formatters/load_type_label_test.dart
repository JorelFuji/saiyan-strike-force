import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/ui/core/formatters/load_type_label.dart';

void main() {
  test('maps every LoadType to a humanized label', () {
    expect(loadTypeLabel(LoadType.none), 'No load');
    expect(loadTypeLabel(LoadType.bodyweight), 'Bodyweight');
    expect(loadTypeLabel(LoadType.absolute), 'Weight');
    expect(loadTypeLabel(LoadType.percentage), 'Percentage');
    expect(loadTypeLabel(LoadType.targetRpe), 'Target RPE');
    expect(loadTypeLabel(LoadType.text), 'Text');
  });

  test('absolute load mode uses Weight, not Absolute weight', () {
    expect(loadTypeLabel(LoadType.absolute), isNot('Absolute weight'));
    expect(loadTypeLabel(LoadType.absolute), 'Weight');
  });
}
