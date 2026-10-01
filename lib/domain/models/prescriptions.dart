import '../../core/failure.dart';
import '../../core/result.dart';

enum RepType {
  fixed('fixed'),
  range('range'),
  amrap('amrap');

  const RepType(this.wireValue);
  final String wireValue;
  static Result<RepType> fromWire(String value) => switch (value) {
    'fixed' => const Ok(RepType.fixed),
    'range' => const Ok(RepType.range),
    'amrap' => const Ok(RepType.amrap),
    _ => Err(ValidationFailure('Unknown rep type: $value')),
  };
}

enum LoadType {
  none('none'),
  bodyweight('bodyweight'),
  absolute('absolute'),
  percentage('percentage'),
  targetRpe('target_rpe'),
  text('text');

  const LoadType(this.wireValue);
  final String wireValue;
  static Result<LoadType> fromWire(String value) => switch (value) {
    'none' => const Ok(LoadType.none),
    'bodyweight' => const Ok(LoadType.bodyweight),
    'absolute' => const Ok(LoadType.absolute),
    'percentage' => const Ok(LoadType.percentage),
    'target_rpe' => const Ok(LoadType.targetRpe),
    'text' => const Ok(LoadType.text),
    _ => Err(ValidationFailure('Unknown load type: $value')),
  };
}

sealed class RepPrescription {
  const RepPrescription();
  RepType get type;
  static Result<RepPrescription> fixed(int reps) => reps < 1
      ? const Err(ValidationFailure('Fixed reps must be at least 1.'))
      : Ok(FixedReps._(reps));
  static Result<RepPrescription> range(int min, int max) => min < 1 || max < min
      ? const Err(ValidationFailure('Rep range is invalid.'))
      : Ok(RepRange._(min, max));
  static const RepPrescription amrap = Amrap();
}

final class FixedReps extends RepPrescription {
  const FixedReps._(this.reps);
  final int reps;
  @override
  RepType get type => RepType.fixed;
  @override
  bool operator ==(Object other) => other is FixedReps && other.reps == reps;
  @override
  int get hashCode => Object.hash(type, reps);
}

final class RepRange extends RepPrescription {
  const RepRange._(this.min, this.max);
  final int min;
  final int max;
  @override
  RepType get type => RepType.range;
  @override
  bool operator ==(Object other) =>
      other is RepRange && other.min == min && other.max == max;
  @override
  int get hashCode => Object.hash(type, min, max);
}

final class Amrap extends RepPrescription {
  const Amrap();
  @override
  RepType get type => RepType.amrap;
  @override
  bool operator ==(Object other) => other is Amrap;
  @override
  int get hashCode => type.hashCode;
}

sealed class LoadPrescription {
  const LoadPrescription();
  LoadType get type;
  static const noLoad = NoLoad();
  static const bodyweight = BodyweightLoad();
  static Result<LoadPrescription> absolute(int milligrams) => milligrams < 0
      ? const Err(ValidationFailure('Absolute load must not be negative.'))
      : Ok(AbsoluteLoad._(milligrams));
  static Result<LoadPrescription> percentage(int value) =>
      value < 0 || value > 100
      ? const Err(
          ValidationFailure('Percentage load must be between 0 and 100.'),
        )
      : Ok(PercentageLoad._(value));
  static Result<LoadPrescription> targetRpe(double value) =>
      !value.isFinite || value < 0 || value > 10
      ? const Err(ValidationFailure('Target RPE must be between 0 and 10.'))
      : Ok(TargetRpeLoad._(value));
  static Result<LoadPrescription> text(String value) {
    final text = value.trim();
    return text.isEmpty
        ? const Err(ValidationFailure('Text load must not be blank.'))
        : Ok(TextLoad._(text));
  }
}

final class NoLoad extends LoadPrescription {
  const NoLoad();
  @override
  LoadType get type => LoadType.none;
  @override
  bool operator ==(Object other) => other is NoLoad;
  @override
  int get hashCode => type.hashCode;
}

final class BodyweightLoad extends LoadPrescription {
  const BodyweightLoad();
  @override
  LoadType get type => LoadType.bodyweight;
  @override
  bool operator ==(Object other) => other is BodyweightLoad;
  @override
  int get hashCode => type.hashCode;
}

final class AbsoluteLoad extends LoadPrescription {
  const AbsoluteLoad._(this.milligrams);
  final int milligrams;
  @override
  LoadType get type => LoadType.absolute;
  @override
  bool operator ==(Object other) =>
      other is AbsoluteLoad && other.milligrams == milligrams;
  @override
  int get hashCode => Object.hash(type, milligrams);
}

final class PercentageLoad extends LoadPrescription {
  const PercentageLoad._(this.percentage);
  final int percentage;
  @override
  LoadType get type => LoadType.percentage;
  @override
  bool operator ==(Object other) =>
      other is PercentageLoad && other.percentage == percentage;
  @override
  int get hashCode => Object.hash(type, percentage);
}

final class TargetRpeLoad extends LoadPrescription {
  const TargetRpeLoad._(this.rpe);
  final double rpe;
  @override
  LoadType get type => LoadType.targetRpe;
  @override
  bool operator ==(Object other) => other is TargetRpeLoad && other.rpe == rpe;
  @override
  int get hashCode => Object.hash(type, rpe);
}

final class TextLoad extends LoadPrescription {
  const TextLoad._(this.text);
  final String text;
  @override
  LoadType get type => LoadType.text;
  @override
  bool operator ==(Object other) => other is TextLoad && other.text == text;
  @override
  int get hashCode => Object.hash(type, text);
}
