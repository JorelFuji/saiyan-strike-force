import 'package:flutter/material.dart';

import '../../../core/result.dart';
import '../../../domain/models/active_session.dart';
import '../../../domain/models/mass.dart';
import '../../../domain/models/prescriptions.dart';
import '../../core/formatters/load_type_label.dart';

/// Focused, local form for a session-only exercise prescription.
class AddExerciseSheet extends StatefulWidget {
  const AddExerciseSheet({required this.massUnit, super.key});

  final MassUnit massUnit;

  @override
  State<AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<AddExerciseSheet> {
  final _name = TextEditingController();
  final _sets = TextEditingController(text: '3');
  final _repPrimary = TextEditingController(text: '8');
  final _repMaximum = TextEditingController();
  final _loadValue = TextEditingController();
  final _rest = TextEditingController(text: '90');
  RepType _repType = RepType.fixed;
  LoadType _loadType = LoadType.none;
  String? _error;

  @override
  void dispose() {
    for (final controller in [
      _name,
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
    if (_name.text.trim().isEmpty ||
        count == null ||
        count < 1 ||
        rest == null ||
        rest < 0) {
      setState(
        () => _error =
            'Enter an exercise name, at least one set, and a nonnegative rest.',
      );
      return;
    }
    Navigator.of(context).pop(
      AddExerciseDraft(
        name: _name.text,
        initialSetCount: count,
        reps: (reps as Ok<RepPrescription>).value,
        load: (load as Ok<LoadPrescription>).value,
        restSeconds: rest,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add exercise',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Exercise name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sets,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Initial sets'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RepType>(
              initialValue: _repType,
              decoration: const InputDecoration(labelText: 'Rep mode'),
              items: RepType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.name)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _repType = value!),
            ),
            if (_repType != RepType.amrap) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _repPrimary,
                keyboardType: TextInputType.number,
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
                  decoration: const InputDecoration(labelText: 'Maximum reps'),
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
                      child: Text(loadTypeLabel(type)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _loadType = value!),
            ),
            if (_loadType != LoadType.none &&
                _loadType != LoadType.bodyweight) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _loadValue,
                keyboardType: _loadType == LoadType.text
                    ? TextInputType.text
                    : const TextInputType.numberWithOptions(decimal: true),
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
              decoration: const InputDecoration(labelText: 'Rest seconds'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Add exercise'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

final class AddExerciseDraft {
  const AddExerciseDraft({
    required this.name,
    required this.initialSetCount,
    required this.reps,
    required this.load,
    required this.restSeconds,
  });
  final String name;
  final int initialSetCount;
  final RepPrescription reps;
  final LoadPrescription load;
  final int restSeconds;

  Result<AddSessionExerciseCommand> toCommand(int sessionId) =>
      AddSessionExerciseCommand.create(
        sessionId: sessionId,
        name: name,
        initialSetCount: initialSetCount,
        reps: reps,
        load: load,
        restSeconds: restSeconds,
      );
}

Result<LoadPrescription> _absoluteLoad(String input, MassUnit unit) {
  final mass = massToMilligrams(input, unit);
  return switch (mass) {
    Ok(:final value) => LoadPrescription.absolute(value),
    Err(:final failure) => Err(failure),
  };
}
