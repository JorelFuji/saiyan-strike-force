import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/prescriptions.dart';

/// Tap-to-edit field with owned controller lifecycle and commit-on-blur/submit.
class DraftFieldEditor extends StatefulWidget {
  const DraftFieldEditor({
    required this.label,
    required this.value,
    required this.semanticsLabel,
    required this.onChanged,
    required this.onCommit,
    super.key,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.errorText,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.inputFormatters,
  });

  final String label;
  final String value;
  final String semanticsLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback onCommit;
  final TextInputType keyboardType;
  final bool readOnly;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<DraftFieldEditor> createState() => _DraftFieldEditorState();
}

class _DraftFieldEditorState extends State<DraftFieldEditor> {
  late final TextEditingController _controller;
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? _ownedFocusNode!;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    if (widget.focusNode == null) {
      _ownedFocusNode = FocusNode();
    }
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onCommit();
    }
  }

  @override
  void didUpdateWidget(covariant DraftFieldEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text && !_focusNode.hasFocus) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.readOnly) {
      return Semantics(
        label: widget.semanticsLabel,
        readOnly: true,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          child: Text(widget.value, style: theme.textTheme.bodyLarge),
        ),
      );
    }

    return Semantics(
      label: widget.semanticsLabel,
      textField: true,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: widget.errorText,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: widget.onChanged,
        onEditingComplete: widget.onCommit,
        onSubmitted: (_) {
          widget.onCommit();
          widget.onSubmitted?.call();
        },
        onTapOutside: (_) => widget.onCommit(),
      ),
    );
  }
}

/// Load field for the set's planned load type (not session RPE).
class SetLoadEditor extends StatelessWidget {
  const SetLoadEditor({
    required this.loadKind,
    required this.draft,
    required this.massUnitLabel,
    required this.onDraftChanged,
    required this.onCommit,
    super.key,
    this.errorText,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final LoadType loadKind;
  final ({
    String absoluteMassText,
    String percentageText,
    String targetRpeText,
    String textLoadText,
  })
  draft;
  final String massUnitLabel;
  final void Function({
    String? absoluteMassText,
    String? percentageText,
    String? targetRpeText,
    String? textLoadText,
  })
  onDraftChanged;
  final VoidCallback onCommit;
  final String? errorText;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return switch (loadKind) {
      LoadType.none => DraftFieldEditor(
        label: 'Load',
        value: 'No load',
        semanticsLabel: 'Load, no load',
        onChanged: (_) {},
        onCommit: () {},
        readOnly: true,
      ),
      LoadType.bodyweight => DraftFieldEditor(
        label: 'Load',
        value: 'Bodyweight',
        semanticsLabel: 'Load, bodyweight',
        onChanged: (_) {},
        onCommit: () {},
        readOnly: true,
      ),
      LoadType.absolute => DraftFieldEditor(
        label: 'Load ($massUnitLabel)',
        value: draft.absoluteMassText,
        semanticsLabel: 'Load in $massUnitLabel',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        readOnly: readOnly,
        errorText: errorText,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        onChanged: (text) => onDraftChanged(absoluteMassText: text),
        onCommit: onCommit,
      ),
      LoadType.percentage => DraftFieldEditor(
        label: 'Load (%)',
        value: draft.percentageText,
        semanticsLabel: 'Load percentage',
        keyboardType: TextInputType.number,
        readOnly: readOnly,
        errorText: errorText,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        onChanged: (text) => onDraftChanged(percentageText: text),
        onCommit: onCommit,
      ),
      LoadType.targetRpe => DraftFieldEditor(
        label: 'Load (target RPE)',
        value: draft.targetRpeText,
        semanticsLabel: 'Load target RPE',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        readOnly: readOnly,
        errorText: errorText,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        onChanged: (text) => onDraftChanged(targetRpeText: text),
        onCommit: onCommit,
      ),
      LoadType.text => DraftFieldEditor(
        label: 'Load',
        value: draft.textLoadText,
        semanticsLabel: 'Load description',
        readOnly: readOnly,
        errorText: errorText,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        onChanged: (text) => onDraftChanged(textLoadText: text),
        onCommit: onCommit,
      ),
    };
  }
}
