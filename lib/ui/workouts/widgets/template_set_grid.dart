import 'package:flutter/material.dart';

import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../domain/models/mass.dart';
import '../../../domain/models/prescriptions.dart';
import '../../../domain/models/workout_template.dart';
import '../../../domain/models/exercise_name.dart';
import '../../core/formatters/load_formatter.dart';
import '../../core/formatters/rest_duration_formatter.dart';
import '../workout_builder_cubit.dart';
import '../workout_builder_state.dart';
import '../previous_set_format.dart';
import 'rest_duration_sheet.dart';

class TemplateSetGrid extends StatefulWidget {
  const TemplateSetGrid({
    required this.row,
    required this.massUnit,
    required this.cubit,
    required this.enabled,
    required this.onRemoveSet,
    super.key,
  });
  final DraftExerciseRow row;
  final MassUnit massUnit;
  final WorkoutBuilderCubit cubit;
  final bool enabled;
  final void Function(int setNumber, RemovedTemplateSet removed) onRemoveSet;

  @override
  State<TemplateSetGrid> createState() => _TemplateSetGridState();
}

class _TemplateSetGridState extends State<TemplateSetGrid> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void didUpdateWidget(covariant TemplateSetGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final live = widget.row.setKeys.map((key) => '$key').toSet();
    for (final key
        in _controllers.keys
            .where((key) => !live.any(key.startsWith))
            .toList()) {
      _controllers.remove(key)?.dispose();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(int setKey, String column, String value) {
    final key = '$setKey:$column';
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: value),
    );
  }

  String _loadText(LoadPrescription load) => switch (load) {
    NoLoad() || BodyweightLoad() => '',
    AbsoluteLoad(:final milligrams) => formatAbsoluteMass(
      milligrams,
      widget.massUnit,
    ),
    PercentageLoad(:final percentage) => '$percentage',
    TargetRpeLoad(:final rpe) => '$rpe',
    TextLoad(:final text) => text,
  };

  String _repText(RepPrescription reps) => switch (reps) {
    FixedReps(:final reps) => '$reps',
    RepRange(:final min, :final max) => '$min–$max',
    Amrap() => 'AMRAP',
  };

  @override
  Widget build(BuildContext context) {
    final exercise = widget.row.exercise;
    final narrow =
        MediaQuery.textScalerOf(context).scale(14) / 14 >= 1.5 ||
        MediaQuery.sizeOf(context).width < 360;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Row(
            children: [
              const SizedBox(width: 48, child: Text('Set')),
              const Expanded(child: Text('Previous')),
              if (exercise.loadType != LoadType.none &&
                  exercise.loadType != LoadType.bodyweight)
                const Expanded(child: Text('Load')),
              const Expanded(child: Text('Reps')),
            ],
          ),
        ),
        for (var i = 0; i < exercise.sets.length; i++)
          _setBlock(context, i, narrow),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: widget.enabled
                ? () => widget.cubit.addSet(widget.row.key)
                : null,
            child: Text(
              '+ Add Set (${formatRestDuration(exercise.lastSet.restSeconds)})',
            ),
          ),
        ),
      ],
    );
  }

  Widget _setBlock(BuildContext context, int index, bool stacked) {
    final exercise = widget.row.exercise;
    final set = exercise.sets[index];
    final setKey = widget.row.setKeys[index];
    final loadVisible =
        exercise.loadType != LoadType.none &&
        exercise.loadType != LoadType.bodyweight;
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _setMenu(context, index, setKey),
        Expanded(
          child: Text(
            formatPreviousSet(
              widget.cubit.state.previousSets[normalizeExerciseName(
                exercise.name,
              )]?[index],
              widget.massUnit,
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (loadVisible) Expanded(child: _loadField(index, setKey, set)),
        Expanded(child: _repsField(index, setKey, set)),
      ],
    );
    return Column(
      children: [
        Semantics(
          container: true,
          label:
              'Set ${index + 1}, previous ${formatPreviousSet(widget.cubit.state.previousSets[normalizeExerciseName(exercise.name)]?[index], widget.massUnit)}, ${_repText(set.reps)} reps',
          child: stacked ? Column(children: [row]) : row,
        ),
        _RestDivider(
          setNumber: index + 1,
          seconds: set.restSeconds,
          enabled: widget.enabled,
          onChanged: (result) => result.applyToAll
              ? widget.cubit.applyRestToAll(widget.row.key, result.seconds)
              : widget.cubit.updateSetRest(
                  widget.row.key,
                  setKey,
                  result.seconds,
                ),
        ),
      ],
    );
  }

  Widget _setMenu(BuildContext context, int index, int setKey) => SizedBox(
    width: 48,
    height: 48,
    child: PopupMenuButton<String>(
      enabled: widget.enabled && widget.row.exercise.plannedSets > 1,
      tooltip: 'Set ${index + 1} options',
      onSelected: (_) {
        final removed = widget.cubit.removeSet(widget.row.key, setKey);
        if (removed != null) widget.onRemoveSet(index + 1, removed);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'remove', child: Text('Remove set')),
      ],
      child: Semantics(
        button: true,
        label: 'Set ${index + 1} options',
        child: Chip(label: Text('${index + 1}')),
      ),
    ),
  );

  Widget _loadField(int index, int setKey, TemplateSet set) {
    final id = DraftCellId(
      rowKey: widget.row.key,
      setKey: setKey,
      column: DraftCellColumn.load,
    );
    final controller = _controller(setKey, 'load', _loadText(set.load));
    return TextField(
      controller: controller,
      enabled: widget.enabled,
      key: ValueKey('load-$setKey'),
      keyboardType: set.load is TextLoad
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Set ${index + 1} load',
        errorText: widget.cubit.state.cellErrors[id],
      ),
      onChanged: (text) {
        final result = _parseLoad(text, set.load.type, widget.massUnit);
        if (result case Err(:final failure)) {
          widget.cubit.reportCellError(id, failure.message);
          return;
        }
        final updated = TemplateSet.create(
          reps: set.reps,
          load: (result as Ok<LoadPrescription>).value,
          restSeconds: set.restSeconds,
        );
        if (updated case Ok(:final value)) {
          widget.cubit.updateSet(widget.row.key, setKey, value);
        }
        widget.cubit.reportCellError(id, null);
      },
    );
  }

  Widget _repsField(int index, int setKey, TemplateSet set) {
    final id = DraftCellId(
      rowKey: widget.row.key,
      setKey: setKey,
      column: DraftCellColumn.reps,
    );
    final reps = set.reps;
    if (reps is Amrap) {
      return const Padding(padding: EdgeInsets.all(12), child: Text('AMRAP'));
    }
    final value = _repText(reps);
    final controller = _controller(setKey, 'reps', value);
    return TextField(
      controller: controller,
      enabled: widget.enabled,
      key: ValueKey('reps-$setKey'),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Set ${index + 1} reps',
        errorText: widget.cubit.state.cellErrors[id],
      ),
      onChanged: (text) {
        final result = _parseReps(text, reps.type);
        if (result case Err(:final failure)) {
          widget.cubit.reportCellError(id, failure.message);
          return;
        }
        final updated = TemplateSet.create(
          reps: (result as Ok<RepPrescription>).value,
          load: set.load,
          restSeconds: set.restSeconds,
        );
        if (updated case Ok(:final value)) {
          widget.cubit.updateSet(widget.row.key, setKey, value);
        }
        widget.cubit.reportCellError(id, null);
      },
    );
  }
}

Result<LoadPrescription> _parseLoad(
  String input,
  LoadType type,
  MassUnit unit,
) => switch (type) {
  LoadType.none => const Ok(NoLoad()),
  LoadType.bodyweight => const Ok(BodyweightLoad()),
  LoadType.absolute => switch (massToMilligrams(input, unit)) {
    Ok(:final value) => LoadPrescription.absolute(value),
    Err(:final failure) => Err(failure),
  },
  LoadType.percentage => LoadPrescription.percentage(int.tryParse(input) ?? -1),
  LoadType.targetRpe => LoadPrescription.targetRpe(
    double.tryParse(input) ?? double.nan,
  ),
  LoadType.text => LoadPrescription.text(input),
};

Result<RepPrescription> _parseReps(String input, RepType type) {
  if (type == RepType.range) {
    final parts = input.split(RegExp(r'[-–]'));
    return parts.length == 2
        ? RepPrescription.range(
            int.tryParse(parts[0].trim()) ?? 0,
            int.tryParse(parts[1].trim()) ?? 0,
          )
        : const Err(ValidationFailure('Enter reps as min–max.'));
  }
  return RepPrescription.fixed(int.tryParse(input) ?? 0);
}

class _RestDivider extends StatelessWidget {
  const _RestDivider({
    required this.setNumber,
    required this.seconds,
    required this.enabled,
    required this.onChanged,
  });
  final int setNumber;
  final int seconds;
  final bool enabled;
  final ValueChanged<RestDurationResult> onChanged;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Rest after set $setNumber, ${formatRestDuration(seconds)}',
    hint: 'Edit rest',
    child: SizedBox(
      height: 48,
      child: InkWell(
        onTap: enabled
            ? () async {
                final result = await showRestDurationSheet(
                  context,
                  setNumber: setNumber,
                  initialSeconds: seconds,
                );
                if (result != null) onChanged(result);
              }
            : null,
        child: Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(formatRestDuration(seconds)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
      ),
    ),
  );
}
