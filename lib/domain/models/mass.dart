import '../../core/failure.dart';
import '../../core/result.dart';

enum MassUnit {
  kg('kg'),
  lb('lb');

  const MassUnit(this.wireValue);
  final String wireValue;

  static Result<MassUnit> fromWire(String value) => switch (value) {
    'kg' => const Ok(MassUnit.kg),
    'lb' => const Ok(MassUnit.lb),
    _ => const Err(ValidationFailure('Unknown mass unit wire value.')),
  };
}

/// Parses a non-negative base-10 decimal without using floating point.
Result<int> massToMilligrams(String input, MassUnit unit) {
  final value = input.trim();
  final parts = value.split('.');
  if (parts.first.length > 11 || (parts.length == 2 && parts.last.length > 9)) {
    return const Err(
      ValidationFailure('Mass input is outside supported precision.'),
    );
  }
  final match = RegExp(r'^(?:0|[1-9]\d*)(?:\.(\d+))?$').firstMatch(value);
  if (match == null) {
    return const Err(ValidationFailure('Mass must be a non-negative decimal.'));
  }
  final dot = value.indexOf('.');
  final whole = BigInt.parse(dot < 0 ? value : value.substring(0, dot));
  final fraction = dot < 0 ? '' : value.substring(dot + 1);
  var scale = BigInt.one;
  for (var index = 0; index < fraction.length; index++) {
    scale *= BigInt.from(10);
  }
  final fractional = fraction.isEmpty ? BigInt.zero : BigInt.parse(fraction);
  final numerator = whole * scale + fractional;
  final unitNumerator = BigInt.from(unit == MassUnit.kg ? 1000000 : 45359237);
  final unitDenominator = BigInt.from(unit == MassUnit.kg ? 1 : 100);
  final denominator = scale * unitDenominator;
  final milligrams =
      (numerator * unitNumerator + denominator ~/ BigInt.two) ~/ denominator;
  if (milligrams > BigInt.from(9223372036854775807)) {
    return const Err(ValidationFailure('Mass is too large.'));
  }
  return Ok(milligrams.toInt());
}

double displayMass(int milligrams, MassUnit unit) {
  if (unit == MassUnit.kg) {
    final halfKg = (milligrams + 250000) ~/ 500000;
    return halfKg / 2;
  }
  final pounds = (milligrams * 100 + 45359237 ~/ 2) ~/ 45359237;
  return pounds.toDouble();
}
