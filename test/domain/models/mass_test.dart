import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';

void main() {
  test('parses exact kilogram and pound decimals', () {
    expect((massToMilligrams('2.5', MassUnit.kg) as Ok<int>).value, 2500000);
    expect((massToMilligrams('1', MassUnit.lb) as Ok<int>).value, 453592);
    expect((massToMilligrams('0.0000005', MassUnit.lb) as Ok<int>).value, 0);
    expect((massToMilligrams('0.0000005', MassUnit.kg) as Ok<int>).value, 1);
  });

  test(
    'rejects malformed and negative input and rounds display increments',
    () {
      expect(massToMilligrams('-1', MassUnit.kg), isA<Err<int>>());
      expect(massToMilligrams('1.', MassUnit.kg), isA<Err<int>>());
      expect(massToMilligrams('1e2', MassUnit.kg), isA<Err<int>>());
      expect(
        massToMilligrams(
          '${List.filled(12, '9').join()}.1234567890',
          MassUnit.kg,
        ),
        isA<Err<int>>(),
      );
      expect(displayMass(750000, MassUnit.kg), 1.0);
      expect(displayMass(453592, MassUnit.lb), 1.0);
      expect(displayMass(226797, MassUnit.lb), 1.0);
    },
  );
}
