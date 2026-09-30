import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/ui/core/formatters/load_formatter.dart';

void main() {
  LoadPrescription absolute(int milligrams) =>
      (LoadPrescription.absolute(milligrams) as Ok<LoadPrescription>).value;

  test('formats none and bodyweight loads', () {
    expect(formatCommittedLoad(const NoLoad(), MassUnit.kg), 'No load');
    expect(
      formatCommittedLoad(const BodyweightLoad(), MassUnit.lb),
      'Bodyweight',
    );
  });

  test('formats absolute loads with established kg and lb rounding', () {
    expect(formatCommittedLoad(absolute(102058280), MassUnit.kg), '102 kg');
    expect(formatCommittedLoad(absolute(102058280), MassUnit.lb), '225 lb');
    expect(formatCommittedLoad(absolute(102500000), MassUnit.kg), '102.5 kg');
  });

  test('formats non-absolute structured loads without changing text', () {
    final percentage =
        (LoadPrescription.percentage(75) as Ok<LoadPrescription>).value;
    final rpe = (LoadPrescription.targetRpe(7.5) as Ok<LoadPrescription>).value;
    final wholeRpe =
        (LoadPrescription.targetRpe(8) as Ok<LoadPrescription>).value;
    final text =
        (LoadPrescription.text('Two plates') as Ok<LoadPrescription>).value;

    expect(formatCommittedLoad(percentage, MassUnit.kg), '75%');
    expect(formatCommittedLoad(rpe, MassUnit.kg), 'RPE 7.5');
    expect(formatCommittedLoad(wholeRpe, MassUnit.kg), 'RPE 8');
    expect(formatCommittedLoad(text, MassUnit.kg), 'Two plates');
  });

  test('formats every structured rep prescription', () {
    final fixed = (RepPrescription.fixed(5) as Ok<RepPrescription>).value;
    final range = (RepPrescription.range(6, 8) as Ok<RepPrescription>).value;

    expect(formatCommittedReps(fixed), '5');
    expect(formatCommittedReps(range), '6–8');
    expect(formatCommittedReps(const Amrap()), 'AMRAP');
  });
}
