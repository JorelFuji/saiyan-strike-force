import '../../domain/models/mass.dart';

/// Country codes whose primary customary mass unit for training is pounds.
const imperialMassUnitCountryCodes = <String>{'US', 'LR', 'MM'};

/// Resolves the first-use display mass unit from an optional locale country code.
MassUnit massUnitForCountryCode(String? countryCode) {
  if (countryCode == null || countryCode.isEmpty) {
    return MassUnit.kg;
  }
  final normalized = countryCode.toUpperCase();
  if (imperialMassUnitCountryCodes.contains(normalized)) {
    return MassUnit.lb;
  }
  return MassUnit.kg;
}
