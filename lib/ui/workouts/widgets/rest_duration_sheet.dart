import 'package:flutter/material.dart';

import '../../../core/result.dart';
import '../../core/formatters/rest_duration_formatter.dart';

final class RestDurationResult {
  const RestDurationResult({required this.seconds, required this.applyToAll});
  final int seconds;
  final bool applyToAll;
}

Future<RestDurationResult?> showRestDurationSheet(
  BuildContext context, {
  required int setNumber,
  required int initialSeconds,
}) => showModalBottomSheet<RestDurationResult>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) =>
      _RestDurationSheet(setNumber: setNumber, initialSeconds: initialSeconds),
);

class _RestDurationSheet extends StatefulWidget {
  const _RestDurationSheet({
    required this.setNumber,
    required this.initialSeconds,
  });
  final int setNumber;
  final int initialSeconds;

  @override
  State<_RestDurationSheet> createState() => _RestDurationSheetState();
}

class _RestDurationSheetState extends State<_RestDurationSheet> {
  late final TextEditingController _controller;
  String? _error;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _seconds = widget.initialSeconds;
    _controller = TextEditingController(text: formatRestDuration(_seconds));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(int amount) {
    setState(() {
      _seconds = (_seconds + amount).clamp(0, 86400);
      _controller.text = formatRestDuration(_seconds);
      _error = null;
    });
  }

  void _submit(bool applyToAll) {
    final parsed = parseRestDuration(_controller.text);
    if (parsed case Err(:final failure)) {
      setState(() => _error = failure.message);
      return;
    }
    Navigator.of(context).pop(
      RestDurationResult(
        seconds: (parsed as Ok<int>).value,
        applyToAll: applyToAll,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Rest after set ${widget.setNumber}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Duration (m:ss)',
            errorText: _error,
          ),
          onChanged: (_) => setState(() => _error = null),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                onPressed: () => _step(-15),
                tooltip: 'Subtract 15 seconds',
                icon: const Text('−15s'),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              formatRestDuration(_seconds),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                onPressed: () => _step(15),
                tooltip: 'Add 15 seconds',
                icon: const Text('+15s'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => _submit(false),
          child: const Text('Save'),
        ),
        OutlinedButton(
          onPressed: () => _submit(true),
          child: const Text('Apply to all sets'),
        ),
      ],
    ),
  );
}
