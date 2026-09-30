import 'package:flutter/material.dart';

import '../../../domain/models/calendar_date.dart';

Future<CalendarDate?> showMoveEntrySheet({
  required BuildContext context,
  required CalendarDate selectedDate,
  required CalendarDate today,
}) {
  return showModalBottomSheet<CalendarDate>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _MoveEntrySheet(selectedDate: selectedDate, today: today);
    },
  );
}

class _MoveEntrySheet extends StatelessWidget {
  const _MoveEntrySheet({required this.selectedDate, required this.today});

  final CalendarDate selectedDate;
  final CalendarDate today;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final options = [
      for (var offset = -14; offset <= 21; offset++) today.addDays(offset),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Move to date',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final date = options[index];
                  final label = localizations.formatMediumDate(
                    DateTime(date.year, date.month, date.day),
                  );
                  final isCurrent = date == selectedDate;
                  return ListTile(
                    title: Text(label),
                    trailing: isCurrent
                        ? const Icon(Icons.check, semanticLabel: 'Current date')
                        : null,
                    enabled: !isCurrent,
                    onTap: isCurrent
                        ? null
                        : () => Navigator.of(context).pop(date),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
