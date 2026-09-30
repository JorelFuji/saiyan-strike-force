import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';

void main() {
  test('accepts every rep and load branch', () {
    expect(RepPrescription.fixed(5), isA<Ok<RepPrescription>>());
    expect(RepPrescription.range(5, 8), isA<Ok<RepPrescription>>());
    expect(RepPrescription.amrap, isA<Amrap>());
    expect(LoadPrescription.absolute(1000), isA<Ok<LoadPrescription>>());
    expect(LoadPrescription.percentage(100), isA<Ok<LoadPrescription>>());
    expect(LoadPrescription.targetRpe(10), isA<Ok<LoadPrescription>>());
    expect(LoadPrescription.text('tempo'), isA<Ok<LoadPrescription>>());
  });

  test('rejects invalid values and unknown wires', () {
    expect(RepPrescription.fixed(0), isA<Err<RepPrescription>>());
    expect(RepPrescription.range(0, 8), isA<Err<RepPrescription>>());
    expect(RepPrescription.range(8, 5), isA<Err<RepPrescription>>());
    expect(LoadPrescription.absolute(-1), isA<Err<LoadPrescription>>());
    expect(LoadPrescription.percentage(101), isA<Err<LoadPrescription>>());
    expect(LoadPrescription.targetRpe(-0.1), isA<Err<LoadPrescription>>());
    expect(LoadPrescription.text(' \t '), isA<Err<LoadPrescription>>());
    expect(RepType.fromWire('bogus'), isA<Err<RepType>>());
    expect(LoadType.fromWire('bogus'), isA<Err<LoadType>>());
    expect(const ValidationFailure('x'), isA<Failure>());
  });
}
