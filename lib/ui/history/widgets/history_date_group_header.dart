import 'package:flutter/material.dart';

import '../../../domain/models/calendar_date.dart';
import 'history_session_tile.dart';

class HistoryDateGroupHeader extends StatelessWidget {
  const HistoryDateGroupHeader({required this.date, super.key});

  final CalendarDate date;

  @override
  Widget build(BuildContext context) {
    final label = formatHistoryDateHeading(date);
    return Semantics(
      header: true,
      label: label,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(label, style: Theme.of(context).textTheme.titleSmall),
      ),
    );
  }
}
