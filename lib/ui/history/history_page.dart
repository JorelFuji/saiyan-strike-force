import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/result.dart';
import '../../domain/models/calendar_date.dart';
import 'history_list_cubit.dart';
import 'history_list_state.dart';
import 'widgets/history_date_group_header.dart';
import 'widgets/history_filter_bar.dart';
import 'widgets/history_session_tile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryListCubit, HistoryListState>(
      builder: (context, state) {
        final cubit = context.read<HistoryListCubit>();
        return Scaffold(
          appBar: AppBar(title: const Text('History')),
          body: Column(
            children: [
              HistoryFilterBar(
                nameQuery: state.nameQuery,
                startDate: state.startDate,
                endDate: state.endDate,
                onNameQueryChanged: cubit.setNameQuery,
                onPickDateRange: () => _pickDateRange(context, state),
                onClearDateRange: cubit.clearDateRange,
              ),
              const Divider(height: 1),
              Expanded(child: _HistoryBody(state: state)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    HistoryListState state,
  ) async {
    final now = DateTime.now();
    final initialStart = state.startDate == null
        ? DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 30))
        : DateTime(
            state.startDate!.year,
            state.startDate!.month,
            state.startDate!.day,
          );
    final initialEnd = state.endDate == null
        ? DateTime(now.year, now.month, now.day)
        : DateTime(
            state.endDate!.year,
            state.endDate!.month,
            state.endDate!.day,
          );
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );
    if (range == null || !context.mounted) {
      return;
    }
    final startResult = CalendarDate.create(
      year: range.start.year,
      month: range.start.month,
      day: range.start.day,
    );
    final endResult = CalendarDate.create(
      year: range.end.year,
      month: range.end.month,
      day: range.end.day,
    );
    if (startResult case Err()) return;
    if (endResult case Err()) return;
    context.read<HistoryListCubit>().setDateRange(
      start: (startResult as Ok<CalendarDate>).value,
      end: (endResult as Ok<CalendarDate>).value,
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.state});

  final HistoryListState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HistoryListCubit>();
    return switch (state.loadPhase) {
      HistoryListLoadPhase.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      HistoryListLoadPhase.failure => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.failureMessage ?? 'Unable to load history.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: cubit.retry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
      HistoryListLoadPhase.empty => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.allSummaries.isEmpty
                ? 'No completed sessions yet.'
                : 'No sessions match these filters.',
            textAlign: TextAlign.center,
            semanticsLabel: state.allSummaries.isEmpty
                ? 'No completed sessions yet'
                : 'No sessions match these filters',
          ),
        ),
      ),
      HistoryListLoadPhase.ready => ListView.builder(
        itemCount: state.dateGroups.fold<int>(
          0,
          (sum, group) => sum + 1 + group.sessions.length,
        ),
        itemBuilder: (context, index) {
          var remaining = index;
          for (final group in state.dateGroups) {
            if (remaining == 0) {
              return HistoryDateGroupHeader(date: group.date);
            }
            remaining--;
            if (remaining < group.sessions.length) {
              final summary = group.sessions[remaining];
              return HistorySessionTile(
                summary: summary,
                massUnit: state.massUnit,
                onTap: () => context.push('/history/session/${summary.id}'),
              );
            }
            remaining -= group.sessions.length;
          }
          return const SizedBox.shrink();
        },
      ),
    };
  }
}
