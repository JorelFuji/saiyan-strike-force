import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/active_session.dart';
import '../../../domain/models/mass.dart';
import '../../core/formatters/load_formatter.dart';
import '../set_draft.dart';
import '../active_session_state.dart';
import 'set_value_editor.dart';

/// One set row with tap-first editors, explicit completion, and commit-first UI.
class ActiveSetRow extends StatefulWidget {
  const ActiveSetRow({
    required this.set,
    required this.draft,
    required this.operation,
    required this.massUnit,
    required this.setNumber,
    required this.isCurrent,
    required this.isMutable,
    required this.onDraftChanged,
    required this.onCommitDraft,
    required this.onComplete,
    required this.onRetry,
    super.key,
  });

  final SessionSetSnapshot set;
  final SetDraft draft;
  final SetOperationState operation;
  final MassUnit massUnit;
  final int setNumber;
  final bool isCurrent;
  final bool isMutable;
  final ValueChanged<SetDraft> onDraftChanged;
  final VoidCallback onCommitDraft;
  final VoidCallback onComplete;
  final VoidCallback onRetry;

  @override
  State<ActiveSetRow> createState() => _ActiveSetRowState();
}

class _ActiveSetRowState extends State<ActiveSetRow> {
  final FocusNode _loadFocus = FocusNode();
  final FocusNode _repsFocus = FocusNode();
  bool _wasCompleted = false;

  @override
  void initState() {
    super.initState();
    _wasCompleted = widget.set.completed;
  }

  @override
  void didUpdateWidget(covariant ActiveSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_wasCompleted && widget.set.completed && !widget.operation.isBusy) {
      HapticFeedback.lightImpact();
    }
    _wasCompleted = widget.set.completed;
  }

  @override
  void dispose() {
    _loadFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  bool get _isPending => widget.operation.isBusy;
  bool get _isFailed => widget.operation.isFailed;
  bool get _isCompleted => widget.set.completed;
  bool get _canEdit => widget.isMutable && !_isCompleted && !_isPending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = widget.isCurrent && !_isCompleted
        ? colorScheme.primary
        : colorScheme.outline;
    final borderWidth = widget.isCurrent && !_isCompleted ? 2.0 : 1.0;

    return Semantics(
      container: true,
      label: 'Set ${widget.setNumber}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Set ${widget.setNumber}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (_isCompleted)
                    Semantics(
                      label: 'Set ${widget.setNumber} completed',
                      child: Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        semanticLabel: 'Completed',
                      ),
                    )
                  else if (_isPending)
                    Semantics(
                      label: 'Set ${widget.setNumber} saving',
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isCompleted) ...[
                if (widget.set.actual case final actual?) ...[
                  _ReadOnlyValues(
                    loadLabel: formatCommittedLoad(
                      actual.load,
                      widget.massUnit,
                    ),
                    repsLabel: formatCommittedReps(actual.reps),
                  ),
                ] else
                  Text(
                    'Completed set data is unavailable.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
              ] else ...[
                SetLoadEditor(
                  loadKind: widget.draft.loadKind,
                  draft: (
                    absoluteMassText: widget.draft.absoluteMassText,
                    percentageText: widget.draft.percentageText,
                    targetRpeText: widget.draft.targetRpeText,
                    textLoadText: widget.draft.textLoadText,
                  ),
                  massUnitLabel: widget.massUnit.wireValue,
                  readOnly: !_canEdit,
                  errorText: widget.draft.fieldError,
                  focusNode: _loadFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: () => _repsFocus.requestFocus(),
                  onDraftChanged:
                      ({
                        absoluteMassText,
                        percentageText,
                        targetRpeText,
                        textLoadText,
                      }) {
                        widget.onDraftChanged(
                          widget.draft.copyWith(
                            absoluteMassText:
                                absoluteMassText ??
                                widget.draft.absoluteMassText,
                            percentageText:
                                percentageText ?? widget.draft.percentageText,
                            targetRpeText:
                                targetRpeText ?? widget.draft.targetRpeText,
                            textLoadText:
                                textLoadText ?? widget.draft.textLoadText,
                            clearFieldError: true,
                          ),
                        );
                      },
                  onCommit: widget.onCommitDraft,
                ),
                const SizedBox(height: 8),
                DraftFieldEditor(
                  label: 'Reps',
                  value: widget.draft.repsText,
                  semanticsLabel: 'Performed reps for set ${widget.setNumber}',
                  keyboardType: TextInputType.number,
                  readOnly: !_canEdit,
                  errorText: widget.draft.fieldError,
                  focusNode: _repsFocus,
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    widget.onDraftChanged(
                      widget.draft.copyWith(
                        repsText: text,
                        clearFieldError: true,
                      ),
                    );
                  },
                  onCommit: widget.onCommitDraft,
                  onSubmitted: () {
                    if (_canEdit) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
                if (_isFailed) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.operation.failureMessage ?? 'Unable to save set.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Semantics(
                      button: true,
                      label: 'Retry set ${widget.setNumber}',
                      child: FilledButton.tonal(
                        onPressed: _canEdit ? widget.onRetry : null,
                        child: const Text('Retry'),
                      ),
                    ),
                  ),
                ],
                if (!_isFailed) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    button: true,
                    label: 'Complete set ${widget.setNumber}',
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _canEdit ? widget.onComplete : null,
                        child: Text('Complete set ${widget.setNumber}'),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyValues extends StatelessWidget {
  const _ReadOnlyValues({required this.loadLabel, required this.repsLabel});

  final String loadLabel;
  final String repsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(loadLabel, style: theme.textTheme.bodyLarge)),
        const SizedBox(width: 16),
        Text(repsLabel, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
