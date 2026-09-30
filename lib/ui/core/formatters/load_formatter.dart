import '../../../domain/models/mass.dart';
import '../../../domain/models/prescriptions.dart';

/// Formats a canonical absolute mass using the documented display rounding.
String formatAbsoluteMass(int milligrams, MassUnit unit) {
  final display = displayMass(milligrams, unit);
  if (display == display.roundToDouble()) {
    return display.toInt().toString();
  }
  final text = display.toString();
  return text.contains('.') ? text.replaceAll(RegExp(r'\.?0+$'), '') : text;
}

/// Presentation-only text for an already committed structured load.
String formatCommittedLoad(LoadPrescription load, MassUnit unit) {
  return switch (load) {
    NoLoad() => 'No load',
    BodyweightLoad() => 'Bodyweight',
    AbsoluteLoad(:final milligrams) =>
      '${formatAbsoluteMass(milligrams, unit)} ${unit.wireValue}',
    PercentageLoad(:final percentage) => '$percentage%',
    TargetRpeLoad(:final rpe) =>
      'RPE ${rpe == rpe.roundToDouble() ? rpe.toInt() : rpe}',
    TextLoad(:final text) => text,
  };
}

/// Presentation-only text for an already committed rep prescription.
String formatCommittedReps(RepPrescription reps) => switch (reps) {
  FixedReps(:final reps) => '$reps',
  RepRange(:final min, :final max) => '$min–$max',
  Amrap() => 'AMRAP',
};
