import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/data/services/mass_unit_default.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';

void main() {
  test('returns lb for every imperial country code', () {
    for (final code in imperialMassUnitCountryCodes) {
      expect(massUnitForCountryCode(code), MassUnit.lb);
      expect(massUnitForCountryCode(code.toLowerCase()), MassUnit.lb);
    }
  });

  test('returns kg for metric, unknown, and absent country codes', () {
    expect(massUnitForCountryCode('DE'), MassUnit.kg);
    expect(massUnitForCountryCode('GB'), MassUnit.kg);
    expect(massUnitForCountryCode('JP'), MassUnit.kg);
    expect(massUnitForCountryCode('ZZ'), MassUnit.kg);
    expect(massUnitForCountryCode(null), MassUnit.kg);
    expect(massUnitForCountryCode(''), MassUnit.kg);
  });
}
