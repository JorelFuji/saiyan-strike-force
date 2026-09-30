import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/active_session.dart';
import '../../domain/models/mass.dart';
import '../../domain/models/prescriptions.dart';

/// UI-only raw field values for one session set row.
final class SetDraft {
  const SetDraft({
    required this.repsText,
    required this.loadKind,
    this.absoluteMassText = '',
    this.percentageText = '',
    this.targetRpeText = '',
    this.textLoadText = '',
    this.dirty = false,
    this.fieldError,
  });

  final String repsText;
  final LoadType loadKind;
  final String absoluteMassText;
  final String percentageText;
  final String targetRpeText;
  final String textLoadText;
  final bool dirty;
  final String? fieldError;

  SetDraft copyWith({
    String? repsText,
    LoadType? loadKind,
    String? absoluteMassText,
    String? percentageText,
    String? targetRpeText,
    String? textLoadText,
    bool? dirty,
    String? fieldError,
    bool clearFieldError = false,
  }) {
    return SetDraft(
      repsText: repsText ?? this.repsText,
      loadKind: loadKind ?? this.loadKind,
      absoluteMassText: absoluteMassText ?? this.absoluteMassText,
      percentageText: percentageText ?? this.percentageText,
      targetRpeText: targetRpeText ?? this.targetRpeText,
      textLoadText: textLoadText ?? this.textLoadText,
      dirty: dirty ?? this.dirty,
      fieldError: clearFieldError ? null : (fieldError ?? this.fieldError),
    );
  }

  static SetDraft seed(SessionSetSnapshot set, MassUnit unit) {
    final loadSource = set.actual?.load ?? set.plannedLoad;
    final repsText = _seedRepsText(set);
    return SetDraft(
      repsText: repsText,
      loadKind: loadSource.type,
      absoluteMassText: switch (loadSource) {
        AbsoluteLoad(:final milligrams) => formatAbsoluteMass(milligrams, unit),
        _ => '',
      },
      percentageText: switch (loadSource) {
        PercentageLoad(:final percentage) => '$percentage',
        _ => '',
      },
      targetRpeText: switch (loadSource) {
        TargetRpeLoad(:final rpe) => _formatRpe(rpe),
        _ => '',
      },
      textLoadText: switch (loadSource) {
        TextLoad(:final text) => text,
        _ => '',
      },
    );
  }

  static String _seedRepsText(SessionSetSnapshot set) {
    final actualReps = set.actual?.reps;
    if (actualReps != null) {
      return _formatRepPrescription(actualReps);
    }
    return switch (set.plannedReps) {
      FixedReps(:final reps) => '$reps',
      RepRange() || Amrap() => '',
    };
  }

  static String _formatRepPrescription(RepPrescription reps) => switch (reps) {
    FixedReps(:final reps) => '$reps',
    RepRange() || Amrap() => throw StateError('Actual reps must be fixed.'),
  };

  static String formatAbsoluteMass(int milligrams, MassUnit unit) {
    final display = displayMass(milligrams, unit);
    if (display == display.roundToDouble()) {
      return display.toInt().toString();
    }
    final text = display.toString();
    return text.contains('.') ? text.replaceAll(RegExp(r'\.?0+$'), '') : text;
  }

  static String _formatRpe(double rpe) {
    if (rpe == rpe.roundToDouble()) {
      return rpe.toInt().toString();
    }
    return rpe.toString();
  }

  Result<ActualPrescription> toActual(MassUnit unit) {
    final repsResult = _parsePerformedReps(repsText);
    if (repsResult case Err(:final failure)) {
      return Err(failure);
    }
    final loadResult = _parseLoad(unit);
    if (loadResult case Err(:final failure)) {
      return Err(failure);
    }
    return ActualPrescription.create(
      reps: (repsResult as Ok<RepPrescription>).value,
      load: (loadResult as Ok<LoadPrescription>).value,
    );
  }

  Result<RepPrescription> _parsePerformedReps(String text) {
    final trimmed = text.trim();
    if (trimmed.length > 9 || !RegExp(r'^[1-9]\d*$').hasMatch(trimmed)) {
      return const Err(
        ValidationFailure('Performed reps must be a positive whole number.'),
      );
    }
    final value = int.tryParse(trimmed);
    if (value == null) {
      return const Err(
        ValidationFailure('Performed reps must be a positive whole number.'),
      );
    }
    return RepPrescription.fixed(value);
  }

  Result<LoadPrescription> _parseLoad(MassUnit unit) {
    return switch (loadKind) {
      LoadType.none => const Ok(LoadPrescription.noLoad),
      LoadType.bodyweight => const Ok(LoadPrescription.bodyweight),
      LoadType.absolute => _parseAbsoluteLoad(unit),
      LoadType.percentage => _parsePercentageLoad(),
      LoadType.targetRpe => _parseTargetRpeLoad(),
      LoadType.text => _parseTextLoad(),
    };
  }

  Result<LoadPrescription> _parseAbsoluteLoad(MassUnit unit) {
    final mgResult = massToMilligrams(absoluteMassText, unit);
    if (mgResult case Err(:final failure)) {
      return Err(failure);
    }
    return LoadPrescription.absolute((mgResult as Ok<int>).value);
  }

  Result<LoadPrescription> _parsePercentageLoad() {
    final trimmed = percentageText.trim();
    final value = int.tryParse(trimmed);
    if (value == null) {
      return const Err(
        ValidationFailure('Percentage load must be a whole number.'),
      );
    }
    return LoadPrescription.percentage(value);
  }

  Result<LoadPrescription> _parseTargetRpeLoad() {
    final trimmed = targetRpeText.trim();
    final value = double.tryParse(trimmed);
    if (value == null) {
      return const Err(ValidationFailure('Target RPE must be a number.'));
    }
    return LoadPrescription.targetRpe(value);
  }

  Result<LoadPrescription> _parseTextLoad() {
    return LoadPrescription.text(textLoadText);
  }

  bool matchesCommitted(SessionSetSnapshot set, MassUnit unit) {
    if (set.actual == null) {
      return false;
    }
    final parsed = toActual(unit);
    if (parsed case Err()) {
      return false;
    }
    final actual = (parsed as Ok<ActualPrescription>).value;
    return _repEquals(actual.reps, set.actual!.reps) &&
        _loadEquals(actual.load, set.actual!.load);
  }
}

bool _repEquals(RepPrescription a, RepPrescription b) {
  return a is FixedReps && b is FixedReps && a.reps == b.reps;
}

bool _loadEquals(LoadPrescription a, LoadPrescription b) {
  if (a is NoLoad && b is NoLoad) return true;
  if (a is BodyweightLoad && b is BodyweightLoad) return true;
  if (a is AbsoluteLoad && b is AbsoluteLoad) {
    return a.milligrams == b.milligrams;
  }
  if (a is PercentageLoad && b is PercentageLoad) {
    return a.percentage == b.percentage;
  }
  if (a is TargetRpeLoad && b is TargetRpeLoad) return a.rpe == b.rpe;
  if (a is TextLoad && b is TextLoad) return a.text == b.text;
  return false;
}
