import 'package:flutter/material.dart';

import '../../../core/result.dart';
import '../../../domain/models/exercise_name.dart';
import '../../../domain/models/mass.dart';
import '../../../domain/models/prescriptions.dart';
import '../../../domain/models/workout_template.dart';
import '../../core/formatters/load_formatter.dart';

/// Opens the template exercise editor and returns a validated [TemplateExercise].
Future<TemplateExercise?> showTemplateExerciseEditorSheet(
  BuildContext context, {
  required MassUnit massUnit,
  required List<ExerciseNameSuggestion> suggestions,
  TemplateExercise? initial,
}) {
  if (initial != null) {
    return showTemplateExerciseDetailsSheet(
      context,
      initial: initial,
      massUnit: massUnit,
      suggestions: suggestions,
    ).then((edit) {
      if (edit == null) return null;
      final sets = initial.sets
          .map(
            (set) => TemplateSet.create(
              reps: edit.reps ?? set.reps,
              load: edit.load ?? set.load,
              restSeconds: set.restSeconds,
            ),
          )
          .map((result) => (result as Ok<TemplateSet>).value)
          .toList();
      final result = TemplateExercise.create(
        name: edit.name,
        sets: sets,
        supersetGroup: initial.supersetGroup,
      );
      return (result as Ok<TemplateExercise>).value;
    });
  }
  return showModalBottomSheet<TemplateExercise>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => TemplateExerciseEditorSheet(
      massUnit: massUnit,
      suggestions: suggestions,
      initial: initial,
    ),
  );
}

final class TemplateExerciseDetailsEdit {
  const TemplateExerciseDetailsEdit({required this.name, this.reps, this.load});
  final String name;
  final RepPrescription? reps;
  final LoadPrescription? load;
}

Future<TemplateExerciseDetailsEdit?> showTemplateExerciseDetailsSheet(
  BuildContext context, {
  required TemplateExercise initial,
  required MassUnit massUnit,
  required List<ExerciseNameSuggestion> suggestions,
}) => showModalBottomSheet<TemplateExerciseDetailsEdit>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _TemplateExerciseDetailsSheet(
    initial: initial,
    massUnit: massUnit,
    suggestions: suggestions,
  ),
);

class _TemplateExerciseDetailsSheet extends StatefulWidget {
  const _TemplateExerciseDetailsSheet({
    required this.initial,
    required this.massUnit,
    required this.suggestions,
  });
  final TemplateExercise initial;
  final MassUnit massUnit;
  final List<ExerciseNameSuggestion> suggestions;
  @override
  State<_TemplateExerciseDetailsSheet> createState() =>
      _TemplateExerciseDetailsSheetState();
}

class _TemplateExerciseDetailsSheetState
    extends State<_TemplateExerciseDetailsSheet> {
  late final TextEditingController _name;
  late final TextEditingController _reps;
  late final TextEditingController _max;
  late final TextEditingController _load;
  late RepType _repType;
  late LoadType _loadType;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial.name);
    _reps = TextEditingController();
    _max = TextEditingController();
    _load = TextEditingController();
    _repType = widget.initial.sets.first.reps.type;
    _loadType = widget.initial.sets.first.load.type;
  }

  @override
  void dispose() {
    _name.dispose();
    _reps.dispose();
    _max.dispose();
    _load.dispose();
    super.dispose();
  }

  void _submit() {
    final repsChanged = _repType != widget.initial.sets.first.reps.type;
    final loadChanged = _loadType != widget.initial.sets.first.load.type;
    if (repsChanged && _repType != RepType.amrap && _reps.text.trim().isEmpty) {
      setState(() => _error = 'Enter a value when changing the rep mode.');
      return;
    }
    if (loadChanged &&
        _loadType != LoadType.none &&
        _loadType != LoadType.bodyweight &&
        _load.text.trim().isEmpty) {
      setState(() => _error = 'Enter a value when changing the load mode.');
      return;
    }
    RepPrescription? reps;
    if (_reps.text.trim().isNotEmpty || _repType == RepType.amrap) {
      final result = switch (_repType) {
        RepType.fixed => RepPrescription.fixed(int.tryParse(_reps.text) ?? 0),
        RepType.range => RepPrescription.range(
          int.tryParse(_reps.text) ?? 0,
          int.tryParse(_max.text) ?? 0,
        ),
        RepType.amrap => const Ok<RepPrescription>(Amrap()),
      };
      if (result case Err(:final failure)) {
        setState(() => _error = failure.message);
        return;
      }
      reps = (result as Ok<RepPrescription>).value;
    }
    LoadPrescription? load;
    if (_load.text.trim().isNotEmpty ||
        _loadType == LoadType.none ||
        _loadType == LoadType.bodyweight) {
      final result = switch (_loadType) {
        LoadType.none => const Ok<LoadPrescription>(NoLoad()),
        LoadType.bodyweight => const Ok<LoadPrescription>(BodyweightLoad()),
        LoadType.absolute => _absoluteLoad(_load.text, widget.massUnit),
        LoadType.percentage => LoadPrescription.percentage(
          int.tryParse(_load.text) ?? -1,
        ),
        LoadType.targetRpe => LoadPrescription.targetRpe(
          double.tryParse(_load.text) ?? double.nan,
        ),
        LoadType.text => LoadPrescription.text(_load.text),
      };
      if (result case Err(:final failure)) {
        setState(() => _error = failure.message);
        return;
      }
      load = (result as Ok<LoadPrescription>).value;
    }
    Navigator.of(context).pop(
      TemplateExerciseDetailsEdit(name: _name.text, reps: reps, load: load),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Exercise name'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<RepType>(
            initialValue: _repType,
            decoration: const InputDecoration(labelText: 'Rep mode'),
            items: RepType.values
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(_repTypeLabel(type)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _repType = value!),
          ),
          const SizedBox(height: 8),
          Text(
            'Leave blank to keep each set\'s value',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_repType != RepType.amrap)
            TextField(
              controller: _reps,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _repType == RepType.range ? 'Minimum reps' : 'Reps',
              ),
            ),
          if (_repType == RepType.range)
            TextField(
              controller: _max,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Maximum reps'),
            ),
          const SizedBox(height: 12),
          DropdownButtonFormField<LoadType>(
            initialValue: _loadType,
            decoration: const InputDecoration(labelText: 'Load mode'),
            items: LoadType.values
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(_loadTypeLabel(type)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _loadType = value!),
          ),
          if (_loadType != LoadType.none && _loadType != LoadType.bodyweight)
            TextField(
              controller: _load,
              keyboardType: _loadType == LoadType.text
                  ? TextInputType.text
                  : const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _loadType == LoadType.absolute
                    ? 'Load (${widget.massUnit.wireValue})'
                    : 'Load value',
              ),
            ),
          if (_error != null)
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Save details'),
            ),
          ),
        ],
      ),
    ),
  );
}

class TemplateExerciseEditorSheet extends StatefulWidget {
  const TemplateExerciseEditorSheet({
    required this.massUnit,
    required this.suggestions,
    this.initial,
    super.key,
  });

  final MassUnit massUnit;
  final List<ExerciseNameSuggestion> suggestions;
  final TemplateExercise? initial;

  @override
  State<TemplateExerciseEditorSheet> createState() =>
      _TemplateExerciseEditorSheetState();
}

class _TemplateExerciseEditorSheetState
    extends State<TemplateExerciseEditorSheet> {
  late final TextEditingController _exerciseName;
  late final TextEditingController _sets;
  late final TextEditingController _repPrimary;
  late final TextEditingController _repMaximum;
  late final TextEditingController _loadValue;
  late final TextEditingController _rest;
  late RepType _repType;
  late LoadType _loadType;
  String? _error;
  bool _syncedAutocompleteName = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _exerciseName = TextEditingController(text: initial?.name ?? '');
    _sets = TextEditingController(text: '${initial?.plannedSets ?? 3}');
    _rest = TextEditingController(
      text: '${initial?.lastSet.restSeconds ?? 90}',
    );
    if (initial != null) {
      _repType = initial.sets.first.reps.type;
      switch (initial.sets.first.reps) {
        case FixedReps(:final reps):
          _repPrimary = TextEditingController(text: '$reps');
          _repMaximum = TextEditingController();
        case RepRange(:final min, :final max):
          _repPrimary = TextEditingController(text: '$min');
          _repMaximum = TextEditingController(text: '$max');
        case Amrap():
          _repPrimary = TextEditingController();
          _repMaximum = TextEditingController();
      }
      _loadType = initial.sets.first.load.type;
      _loadValue = TextEditingController(
        text: _seedLoadText(initial.sets.first.load, widget.massUnit),
      );
    } else {
      _repType = RepType.fixed;
      _loadType = LoadType.none;
      _repPrimary = TextEditingController(text: '8');
      _repMaximum = TextEditingController();
      _loadValue = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _exerciseName,
      _sets,
      _repPrimary,
      _repMaximum,
      _loadValue,
      _rest,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String _seedLoadText(LoadPrescription load, MassUnit unit) => switch (load) {
    NoLoad() || BodyweightLoad() => '',
    AbsoluteLoad(:final milligrams) => formatAbsoluteMass(milligrams, unit),
    PercentageLoad(:final percentage) => '$percentage',
    TargetRpeLoad(:final rpe) =>
      rpe == rpe.roundToDouble() ? '${rpe.toInt()}' : rpe.toString(),
    TextLoad(:final text) => text,
  };

  Iterable<String> _nameOptions(TextEditingValue value) {
    final query = normalizeExerciseName(value.text);
    if (query.isEmpty) {
      return widget.suggestions.map((s) => s.display);
    }
    return widget.suggestions
        .where((s) => s.normalized.contains(query))
        .map((s) => s.display);
  }

  void _onLoadTypeChanged(LoadType? value) {
    if (value == null) return;
    setState(() {
      _loadType = value;
      _loadValue.clear();
      _error = null;
    });
  }

  void _onRepTypeChanged(RepType? value) {
    if (value == null) return;
    setState(() {
      _repType = value;
      if (value == RepType.amrap) {
        _repPrimary.clear();
        _repMaximum.clear();
      } else if (value == RepType.fixed) {
        _repMaximum.clear();
      }
      _error = null;
    });
  }

  void _submit() {
    final reps = switch (_repType) {
      RepType.fixed => RepPrescription.fixed(
        int.tryParse(_repPrimary.text) ?? 0,
      ),
      RepType.range => RepPrescription.range(
        int.tryParse(_repPrimary.text) ?? 0,
        int.tryParse(_repMaximum.text) ?? 0,
      ),
      RepType.amrap => const Ok<RepPrescription>(Amrap()),
    };
    final load = switch (_loadType) {
      LoadType.none => const Ok<LoadPrescription>(NoLoad()),
      LoadType.bodyweight => const Ok<LoadPrescription>(BodyweightLoad()),
      LoadType.absolute => _absoluteLoad(_loadValue.text, widget.massUnit),
      LoadType.percentage => LoadPrescription.percentage(
        int.tryParse(_loadValue.text) ?? -1,
      ),
      LoadType.targetRpe => LoadPrescription.targetRpe(
        double.tryParse(_loadValue.text) ?? double.nan,
      ),
      LoadType.text => LoadPrescription.text(_loadValue.text),
    };
    if (reps case Err(:final failure)) {
      setState(() => _error = failure.message);
      return;
    }
    if (load case Err(:final failure)) {
      setState(() => _error = failure.message);
      return;
    }
    final count = int.tryParse(_sets.text);
    final rest = int.tryParse(_rest.text);
    if (count == null || count < 1 || rest == null || rest < 0) {
      setState(
        () => _error = 'Planned sets must be at least 1 and rest not negative.',
      );
      return;
    }
    final exercise = TemplateExercise.uniform(
      name: _exerciseName.text,
      setCount: count,
      reps: (reps as Ok<RepPrescription>).value,
      load: (load as Ok<LoadPrescription>).value,
      restSeconds: rest,
    );
    if (exercise case Err(:final failure)) {
      setState(() => _error = failure.message);
      return;
    }
    Navigator.of(context).pop((exercise as Ok<TemplateExercise>).value);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.initial == null ? 'Add exercise' : 'Edit exercise';
    final media = MediaQuery.of(context);
    return SizedBox(
      // Leave room for the keyboard while retaining a scrollable editor.
      height: (media.size.height - media.viewInsets.bottom)
          .clamp(0.0, double.infinity)
          .toDouble(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: _exerciseName.text),
                      optionsBuilder: _nameOptions,
                      onSelected: (value) {
                        _exerciseName
                          ..text = value
                          ..selection = TextSelection.collapsed(
                            offset: value.length,
                          );
                      },
                      fieldViewBuilder:
                          (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            if (!_syncedAutocompleteName) {
                              textEditingController.text = _exerciseName.text;
                              textEditingController.addListener(() {
                                _exerciseName.text = textEditingController.text;
                              });
                              _syncedAutocompleteName = true;
                            }
                            return TextField(
                              key: const Key('template_exercise_name'),
                              controller: textEditingController,
                              focusNode: focusNode,
                              autofocus: widget.initial == null,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Exercise name',
                              ),
                              onSubmitted: (_) => onFieldSubmitted(),
                            );
                          },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _sets,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Planned sets',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<RepType>(
                      initialValue: _repType,
                      decoration: const InputDecoration(labelText: 'Rep mode'),
                      items: RepType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(_repTypeLabel(type)),
                            ),
                          )
                          .toList(),
                      onChanged: _onRepTypeChanged,
                    ),
                    if (_repType != RepType.amrap) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _repPrimary,
                        keyboardType: TextInputType.number,
                        textInputAction: _repType == RepType.range
                            ? TextInputAction.next
                            : TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: _repType == RepType.fixed
                              ? 'Reps'
                              : 'Minimum reps',
                        ),
                      ),
                      if (_repType == RepType.range) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _repMaximum,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Maximum reps',
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<LoadType>(
                      initialValue: _loadType,
                      decoration: const InputDecoration(labelText: 'Load mode'),
                      items: LoadType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(_loadTypeLabel(type)),
                            ),
                          )
                          .toList(),
                      onChanged: _onLoadTypeChanged,
                    ),
                    if (_loadType != LoadType.none &&
                        _loadType != LoadType.bodyweight) ...[
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('template_exercise_load'),
                        controller: _loadValue,
                        keyboardType: _loadType == LoadType.text
                            ? TextInputType.text
                            : const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: _loadType == LoadType.absolute
                              ? 'Load (${widget.massUnit.wireValue})'
                              : 'Load value',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rest,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Rest seconds',
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _submit,
                child: Text(
                  widget.initial == null ? 'Add exercise' : 'Save exercise',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _repTypeLabel(RepType type) => switch (type) {
  RepType.fixed => 'Fixed reps',
  RepType.range => 'Rep range',
  RepType.amrap => 'AMRAP',
};

String _loadTypeLabel(LoadType type) => switch (type) {
  LoadType.none => 'No load',
  LoadType.bodyweight => 'Bodyweight',
  LoadType.absolute => 'Absolute weight',
  LoadType.percentage => 'Percentage',
  LoadType.targetRpe => 'Target RPE',
  LoadType.text => 'Text',
};

Result<LoadPrescription> _absoluteLoad(String input, MassUnit unit) {
  final mass = massToMilligrams(input, unit);
  return switch (mass) {
    Ok(:final value) => LoadPrescription.absolute(value),
    Err(:final failure) => Err(failure),
  };
}
