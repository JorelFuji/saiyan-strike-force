import '../../../domain/models/prescriptions.dart';

/// Presentation-only label for a [LoadType] in Load mode menus.
String loadTypeLabel(LoadType type) => switch (type) {
  LoadType.none => 'No load',
  LoadType.bodyweight => 'Bodyweight',
  LoadType.absolute => 'Weight',
  LoadType.percentage => 'Percentage',
  LoadType.targetRpe => 'Target RPE',
  LoadType.text => 'Text',
};
