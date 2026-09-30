import 'package:flutter/material.dart';

class RestTimerControls extends StatelessWidget {
  const RestTimerControls({
    required this.onSkip,
    required this.onSubtractThirty,
    required this.onAddThirty,
    required this.onReset,
    required this.enabled,
    super.key,
  });

  final VoidCallback onSkip;
  final VoidCallback onSubtractThirty;
  final VoidCallback onAddThirty;
  final VoidCallback onReset;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _RestControlButton(
          label: 'Skip rest',
          onPressed: enabled ? onSkip : null,
        ),
        _RestControlButton(
          label: 'Subtract 30 seconds',
          onPressed: enabled ? onSubtractThirty : null,
          child: const Text('−30s'),
        ),
        _RestControlButton(
          label: 'Add 30 seconds',
          onPressed: enabled ? onAddThirty : null,
          child: const Text('+30s'),
        ),
        _RestControlButton(
          label: 'Reset rest timer',
          onPressed: enabled ? onReset : null,
          child: const Text('Reset'),
        ),
      ],
    );
  }
}

class _RestControlButton extends StatelessWidget {
  const _RestControlButton({
    required this.label,
    required this.onPressed,
    this.child,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      child: SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: onPressed,
          child: child ?? Text(label),
        ),
      ),
    );
  }
}
