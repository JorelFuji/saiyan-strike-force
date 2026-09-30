import 'package:flutter/material.dart';

import '../../../domain/models/calendar_date.dart';

class HistoryFilterBar extends StatefulWidget {
  const HistoryFilterBar({
    required this.nameQuery,
    required this.startDate,
    required this.endDate,
    required this.onNameQueryChanged,
    required this.onPickDateRange,
    required this.onClearDateRange,
    super.key,
  });

  final String nameQuery;
  final CalendarDate? startDate;
  final CalendarDate? endDate;
  final ValueChanged<String> onNameQueryChanged;
  final VoidCallback onPickDateRange;
  final VoidCallback onClearDateRange;

  @override
  State<HistoryFilterBar> createState() => _HistoryFilterBarState();
}

class _HistoryFilterBarState extends State<HistoryFilterBar> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.nameQuery);
  }

  @override
  void didUpdateWidget(covariant HistoryFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nameQuery != _nameController.text) {
      _nameController.value = TextEditingValue(
        text: widget.nameQuery,
        selection: TextSelection.collapsed(offset: widget.nameQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRange = widget.startDate != null || widget.endDate != null;
    final rangeLabel = hasRange
        ? '${widget.startDate?.toIso() ?? '…'} – ${widget.endDate?.toIso() ?? '…'}'
        : 'Date range';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          TextField(
            key: const Key('history_name_filter'),
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Workout name',
              hintText: 'Filter by name',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: widget.onNameQueryChanged,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Filter by date range',
                  child: OutlinedButton.icon(
                    key: const Key('history_date_range_button'),
                    onPressed: widget.onPickDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(rangeLabel),
                  ),
                ),
              ),
              if (hasRange) ...[
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: 'Clear date range filter',
                  child: IconButton(
                    key: const Key('history_clear_date_range'),
                    onPressed: widget.onClearDateRange,
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear date range',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
