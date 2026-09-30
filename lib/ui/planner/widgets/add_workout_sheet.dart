import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/result.dart';
import '../../../domain/models/workout_template.dart';
import '../planner_cubit.dart';

Future<void> showAddWorkoutSheet(BuildContext context) {
  final cubit = context.read<PlannerCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return BlocProvider.value(value: cubit, child: const _AddWorkoutSheet());
    },
  );
}

class _AddWorkoutSheet extends StatelessWidget {
  const _AddWorkoutSheet();

  @override
  Widget build(BuildContext context) {
    final workouts = context.read<PlannerCubit>().workoutRepository;
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
                'Add workout',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: StreamBuilder<Result<List<WorkoutTemplate>>>(
                stream: workouts.watchAll(),
                builder: (context, snapshot) {
                  final result = snapshot.data;
                  if (result == null) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (result case Err(:final failure)) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(failure.message),
                    );
                  }
                  final templates = (result as Ok<List<WorkoutTemplate>>).value;
                  if (templates.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No active workouts yet. Create a template first.',
                        semanticsLabel:
                            'No active workouts yet. Create a template first.',
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      return ListTile(
                        title: Text(template.name),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await context.read<PlannerCubit>().addWorkout(
                            template.id,
                          );
                        },
                      );
                    },
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
